# Eliminar servicios AWS con costo
# Mantiene EventBridge funcionando

Write-Host "Eliminando servicios AWS con costo..." -ForegroundColor Cyan
Write-Host ""

$region = "us-east-1"
$prefix = "crud-app"

# 1. ALB
Write-Host "1. Eliminando ALBs..." -ForegroundColor Yellow
aws elbv2 describe-load-balancers --region $region --output json > albs.json 2>$null
if (Test-Path albs.json) {
    $albs = Get-Content albs.json | ConvertFrom-Json
    foreach ($alb in $albs.LoadBalancers) {
        if ($alb.LoadBalancerName -like "*$prefix*") {
            Write-Host "  Eliminando: $($alb.LoadBalancerName)" -ForegroundColor Gray
            aws elbv2 delete-load-balancer --load-balancer-arn $alb.LoadBalancerArn --region $region
        }
    }
    Remove-Item albs.json
}

Start-Sleep -Seconds 5

# 2. Target Groups
Write-Host "2. Eliminando Target Groups..." -ForegroundColor Yellow
aws elbv2 describe-target-groups --region $region --output json > tgs.json 2>$null
if (Test-Path tgs.json) {
    $tgs = Get-Content tgs.json | ConvertFrom-Json
    foreach ($tg in $tgs.TargetGroups) {
        if ($tg.TargetGroupName -like "*$prefix*") {
            Write-Host "  Eliminando: $($tg.TargetGroupName)" -ForegroundColor Gray
            aws elbv2 delete-target-group --target-group-arn $tg.TargetGroupArn --region $region
        }
    }
    Remove-Item tgs.json
}

Start-Sleep -Seconds 3

# 3. SNS Topics
Write-Host "3. Eliminando SNS Topics..." -ForegroundColor Yellow
aws sns list-topics --region $region --output json > topics.json 2>$null
if (Test-Path topics.json) {
    $topics = Get-Content topics.json | ConvertFrom-Json
    foreach ($topic in $topics.Topics) {
        if ($topic.TopicArn -like "*$prefix*") {
            Write-Host "  Eliminando: $($topic.TopicArn)" -ForegroundColor Gray
            aws sns delete-topic --topic-arn $topic.TopicArn --region $region
        }
    }
    Remove-Item topics.json
}

Start-Sleep -Seconds 2

# 4. SQS Queues
Write-Host "4. Eliminando SQS Queues..." -ForegroundColor Yellow
aws sqs list-queues --region $region --output json > queues.json 2>$null
if (Test-Path queues.json) {
    $queues = Get-Content queues.json | ConvertFrom-Json
    if ($queues.QueueUrls) {
        foreach ($queue in $queues.QueueUrls) {
            if ($queue -like "*$prefix*") {
                Write-Host "  Eliminando: $queue" -ForegroundColor Gray
                aws sqs delete-queue --queue-url $queue --region $region
            }
        }
    }
    Remove-Item queues.json
}

Start-Sleep -Seconds 2

# 5. API Gateway
Write-Host "5. Eliminando API Gateways..." -ForegroundColor Yellow
aws apigateway get-rest-apis --region $region --output json > apis.json 2>$null
if (Test-Path apis.json) {
    $apis = Get-Content apis.json | ConvertFrom-Json
    if ($apis.items) {
        foreach ($api in $apis.items) {
            if ($api.name -like "*email*") {
                Write-Host "  Eliminando: $($api.name)" -ForegroundColor Gray
                aws apigateway delete-rest-api --rest-api-id $api.id --region $region
            }
        }
    }
    Remove-Item apis.json
}

Start-Sleep -Seconds 2

# 6. Lambda BFF
Write-Host "6. Eliminando Lambda BFF..." -ForegroundColor Yellow
$bffName = "$prefix-bff-lambda"
aws lambda get-function --function-name $bffName --region $region > lambdabff.json 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Eliminando: $bffName" -ForegroundColor Gray
    aws lambda delete-function --function-name $bffName --region $region
}
if (Test-Path lambdabff.json) { Remove-Item lambdabff.json }

Start-Sleep -Seconds 2

# 7. CloudWatch Alarms
Write-Host "7. Eliminando CloudWatch Alarms..." -ForegroundColor Yellow
aws cloudwatch describe-alarms --region $region --output json > alarms.json 2>$null
if (Test-Path alarms.json) {
    $alarms = Get-Content alarms.json | ConvertFrom-Json
    if ($alarms.MetricAlarms) {
        foreach ($alarm in $alarms.MetricAlarms) {
            if ($alarm.AlarmName -like "*$prefix*") {
                Write-Host "  Eliminando: $($alarm.AlarmName)" -ForegroundColor Gray
                aws cloudwatch delete-alarms --alarm-names $alarm.AlarmName --region $region
            }
        }
    }
    Remove-Item alarms.json
}

Start-Sleep -Seconds 2

# 8. S3 Buckets
Write-Host "8. Eliminando S3 Buckets..." -ForegroundColor Yellow
aws s3api list-buckets --output json > buckets.json 2>$null
if (Test-Path buckets.json) {
    $buckets = Get-Content buckets.json | ConvertFrom-Json
    if ($buckets.Buckets) {
        foreach ($bucket in $buckets.Buckets) {
            if ($bucket.Name -like "*$prefix*") {
                Write-Host "  Vaciando: $($bucket.Name)" -ForegroundColor Gray
                aws s3 rm "s3://$($bucket.Name)" --recursive --region $region 2>$null
                Write-Host "  Eliminando: $($bucket.Name)" -ForegroundColor Gray
                aws s3api delete-bucket --bucket $bucket.Name --region $region 2>$null
            }
        }
    }
    Remove-Item buckets.json
}

Write-Host ""
Write-Host "Verificando EventBridge y Lambda Email..." -ForegroundColor Cyan

# Verificar EventBridge
aws events describe-rule --name "$prefix-email-scheduler" --region $region > eb.json 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "EventBridge Rule: ACTIVA" -ForegroundColor Green
} else {
    Write-Host "EventBridge Rule: NO ENCONTRADA" -ForegroundColor Red
}
if (Test-Path eb.json) { Remove-Item eb.json }

# Verificar Lambda Email
aws lambda get-function --function-name "$prefix-email-lambda" --region $region > lambda.json 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Lambda Email: ACTIVA" -ForegroundColor Green
} else {
    Write-Host "Lambda Email: NO ENCONTRADA" -ForegroundColor Red
}
if (Test-Path lambda.json) { Remove-Item lambda.json }

Write-Host ""
Write-Host "COMPLETADO" -ForegroundColor Green
Write-Host "Ahorro estimado: 20-25 USD/mes" -ForegroundColor Green
Write-Host "EventBridge sigue enviando correos cada 5 min" -ForegroundColor Yellow
Write-Host ""
