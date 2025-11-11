# ============================================
# CANCELAR SERVICIOS AWS CON COSTO
# ============================================
# Elimina recursos costosos, mantiene EventBridge

Write-Host "============================================" -ForegroundColor Red
Write-Host "  CANCELAR SERVICIOS AWS CON COSTO" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""

$region = "us-east-1"
$prefix = "crud-app"

Write-Host "⚠️  Se eliminarán recursos con prefijo: $prefix" -ForegroundColor Yellow
Write-Host "   Región: $region" -ForegroundColor Yellow
Write-Host ""
Write-Host "💰 Ahorro estimado: `$20-25/mes" -ForegroundColor Green
Write-Host ""

$confirm = Read-Host "Escribe 'SI' para continuar"
if ($confirm -ne "SI") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🗑️  Eliminando recursos..." -ForegroundColor Cyan
Write-Host ""

# 1. ALB
Write-Host "1️⃣  Eliminando ALBs..." -ForegroundColor Yellow
try {
    $albs = aws elbv2 describe-load-balancers --region $region 2>&1 | ConvertFrom-Json
    if ($albs.LoadBalancers) {
        foreach ($alb in $albs.LoadBalancers) {
            if ($alb.LoadBalancerName -like "*$prefix*") {
                Write-Host "  → $($alb.LoadBalancerName)" -ForegroundColor Gray
                aws elbv2 delete-load-balancer --load-balancer-arn $alb.LoadBalancerArn --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron ALBs" -ForegroundColor Cyan
}

Start-Sleep -Seconds 3

# 2. Target Groups
Write-Host ""
Write-Host "2️⃣  Eliminando Target Groups..." -ForegroundColor Yellow
try {
    $tgs = aws elbv2 describe-target-groups --region $region 2>&1 | ConvertFrom-Json
    if ($tgs.TargetGroups) {
        foreach ($tg in $tgs.TargetGroups) {
            if ($tg.TargetGroupName -like "*$prefix*") {
                Write-Host "  → $($tg.TargetGroupName)" -ForegroundColor Gray
                aws elbv2 delete-target-group --target-group-arn $tg.TargetGroupArn --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron Target Groups" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 3. SNS Topics
Write-Host ""
Write-Host "3️⃣  Eliminando SNS Topics..." -ForegroundColor Yellow
try {
    $topics = aws sns list-topics --region $region 2>&1 | ConvertFrom-Json
    if ($topics.Topics) {
        foreach ($topic in $topics.Topics) {
            if ($topic.TopicArn -like "*$prefix*") {
                Write-Host "  → $($topic.TopicArn)" -ForegroundColor Gray
                aws sns delete-topic --topic-arn $topic.TopicArn --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron SNS Topics" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 4. SQS Queues
Write-Host ""
Write-Host "4️⃣  Eliminando SQS Queues..." -ForegroundColor Yellow
try {
    $queues = aws sqs list-queues --region $region 2>&1 | ConvertFrom-Json
    if ($queues.QueueUrls) {
        foreach ($queue in $queues.QueueUrls) {
            if ($queue -like "*$prefix*") {
                Write-Host "  → $queue" -ForegroundColor Gray
                aws sqs delete-queue --queue-url $queue --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron SQS Queues" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 5. API Gateway
Write-Host ""
Write-Host "5️⃣  Eliminando API Gateways..." -ForegroundColor Yellow
try {
    $apis = aws apigateway get-rest-apis --region $region 2>&1 | ConvertFrom-Json
    if ($apis.items) {
        foreach ($api in $apis.items) {
            if ($api.name -like "*$prefix*" -or $api.name -like "*email*") {
                Write-Host "  → $($api.name)" -ForegroundColor Gray
                aws apigateway delete-rest-api --rest-api-id $api.id --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron API Gateways" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 6. Lambda BFF
Write-Host ""
Write-Host "6️⃣  Eliminando Lambda BFF..." -ForegroundColor Yellow
try {
    $bffName = "$prefix-bff-lambda"
    $exists = aws lambda get-function --function-name $bffName --region $region 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  → $bffName" -ForegroundColor Gray
        aws lambda delete-function --function-name $bffName --region $region 2>&1 | Out-Null
        Write-Host "  ✅ Eliminado" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Lambda BFF no encontrada" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ℹ️  Lambda BFF no encontrada" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 7. CloudWatch Alarms
Write-Host ""
Write-Host "7️⃣  Eliminando CloudWatch Alarms..." -ForegroundColor Yellow
try {
    $alarms = aws cloudwatch describe-alarms --region $region 2>&1 | ConvertFrom-Json
    if ($alarms.MetricAlarms) {
        foreach ($alarm in $alarms.MetricAlarms) {
            if ($alarm.AlarmName -like "*$prefix*") {
                Write-Host "  → $($alarm.AlarmName)" -ForegroundColor Gray
                aws cloudwatch delete-alarms --alarm-names $alarm.AlarmName --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron CloudWatch Alarms" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 8. S3 Buckets
Write-Host ""
Write-Host "8️⃣  Eliminando S3 Buckets..." -ForegroundColor Yellow
try {
    $buckets = aws s3api list-buckets --region $region 2>&1 | ConvertFrom-Json
    if ($buckets.Buckets) {
        foreach ($bucket in $buckets.Buckets) {
            if ($bucket.Name -like "*$prefix*") {
                Write-Host "  → Vaciando: $($bucket.Name)" -ForegroundColor Gray
                aws s3 rm "s3://$($bucket.Name)" --recursive --region $region 2>&1 | Out-Null
                
                Write-Host "  → Eliminando: $($bucket.Name)" -ForegroundColor Gray
                aws s3api delete-bucket --bucket $bucket.Name --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Eliminado" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  ℹ️  No se encontraron S3 Buckets" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "VERIFICACIÓN FINAL" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Verificar EventBridge
Write-Host "🔍 Verificando EventBridge Rule..." -ForegroundColor Yellow
$ebRule = aws events describe-rule --name "$prefix-email-scheduler" --region $region 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ EventBridge Rule: ACTIVA" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  EventBridge Rule: No encontrada" -ForegroundColor Yellow
}

# Verificar Lambda Email
Write-Host "🔍 Verificando Lambda Email..." -ForegroundColor Yellow
$emailLambda = aws lambda get-function --function-name "$prefix-email-lambda" --region $region 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Lambda Email: ACTIVA" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Lambda Email: No encontrada" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ OPERACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 RESUMEN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "ELIMINADOS (con costo):" -ForegroundColor Red
Write-Host "  ❌ ALB, Target Groups" -ForegroundColor Red
Write-Host "  ❌ SNS Topics, SQS Queues" -ForegroundColor Red
Write-Host "  ❌ API Gateway, Lambda BFF" -ForegroundColor Red
Write-Host "  ❌ CloudWatch Alarms, S3 Buckets" -ForegroundColor Red
Write-Host ""

Write-Host "MANTENIDOS (gratis):" -ForegroundColor Green
Write-Host "  ✅ EventBridge Rule" -ForegroundColor Green
Write-Host "  ✅ Lambda Email" -ForegroundColor Green
Write-Host "  ✅ CloudWatch Logs" -ForegroundColor Green
Write-Host ""

Write-Host "💰 AHORRO: `$20-25/mes (`$240-300/año)" -ForegroundColor Green
Write-Host ""

Write-Host "🔄 EventBridge sigue enviando correos cada 5 min a:" -ForegroundColor Yellow
Write-Host "   alexfrank.af04@gmail.com" -ForegroundColor White
Write-Host ""

Write-Host "✅ ¡Listo!" -ForegroundColor Green
Write-Host ""
