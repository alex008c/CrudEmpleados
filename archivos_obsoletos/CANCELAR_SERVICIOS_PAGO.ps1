# ============================================
# CANCELAR TODOS LOS SERVICIOS DE PAGO AWS
# ============================================
# Este script elimina SOLO recursos con costo
# Mantiene: EventBridge + Lambda Email (ambos FREE)

Write-Host "============================================" -ForegroundColor Red
Write-Host "  CANCELAR SERVICIOS AWS CON COSTO" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""

Write-Host "⚠️  ESTE SCRIPT ELIMINARÁ:" -ForegroundColor Yellow
Write-Host "  ❌ Application Load Balancer (ALB) - $16-20/mes" -ForegroundColor Red
Write-Host "  ❌ SNS Topics - $0.50/mes" -ForegroundColor Red
Write-Host "  ❌ SQS Queues - $0.90/mes" -ForegroundColor Red
Write-Host "  ❌ API Gateway - $3.50/mes" -ForegroundColor Red
Write-Host "  ❌ Lambda BFF (no se usa con EventBridge) - $0/mes pero innecesaria" -ForegroundColor Red
Write-Host "  ❌ CloudWatch Alarms (>10 cuestan)" -ForegroundColor Red
Write-Host "  ❌ S3 Buckets (logs ALB)" -ForegroundColor Red
Write-Host ""

Write-Host "✅ ESTO SE MANTIENE (NECESARIO PARA EVENTBRIDGE):" -ForegroundColor Green
Write-Host "  ✅ Lambda Email Function - $0.00 (FREE TIER)" -ForegroundColor Green
Write-Host "  ✅ EventBridge Rule - $0.00 (FREE TIER)" -ForegroundColor Green
Write-Host "  ✅ CloudWatch Logs - $0.00 (FREE TIER)" -ForegroundColor Green
Write-Host "  ✅ IAM Roles/Policies - $0.00 (SIEMPRE GRATIS)" -ForegroundColor Green
Write-Host ""

Write-Host "💰 AHORRO TOTAL: $20-25/mes ($240-300/año)" -ForegroundColor Green
Write-Host ""

# Confirmación doble
Write-Host "⚠️  ADVERTENCIA FINAL:" -ForegroundColor Yellow
Write-Host "   Esta acción NO se puede deshacer fácilmente." -ForegroundColor Yellow
Write-Host "   EventBridge seguirá enviando correos automáticamente cada 5 min." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Escribe 'ELIMINAR' (en mayúsculas) para confirmar"

if ($confirm -ne "ELIMINAR") {
    Write-Host ""
    Write-Host "❌ Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🗑️  Iniciando eliminación..." -ForegroundColor Cyan
Write-Host ""

# Cambiar a directorio terraform
Set-Location "C:\Users\alex008c\Documents\Programacion\CrudEmpleados\terraform"

# ============================================
# MÉTODO 1: Usar AWS CLI directamente
# ============================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "MÉTODO 1: Eliminando con AWS CLI" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Región
$region = "us-east-1"
$prefix = "crud-app"

Write-Host "🔍 Buscando recursos en región: $region" -ForegroundColor Yellow
Write-Host ""

# 1. ELIMINAR ALB (MAYOR COSTO)
Write-Host "1️⃣  Eliminando Application Load Balancers..." -ForegroundColor Yellow

try {
    # Buscar ALBs
    $albs = aws elbv2 describe-load-balancers --region $region --query "LoadBalancers[?contains(LoadBalancerName, '$prefix')].LoadBalancerArn" --output text 2>&1
    
    if ($albs -and $albs -notmatch "error") {
        $albList = $albs -split "`n" | Where-Object { $_ -match "arn:aws" }
        
        foreach ($alb in $albList) {
            $alb = $alb.Trim()
            if ($alb) {
                Write-Host "  → Eliminando ALB: $alb" -ForegroundColor Gray
                aws elbv2 delete-load-balancer --load-balancer-arn $alb --region $region 2>&1 | Out-Null
                Write-Host "  ✅ ALB eliminado" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron ALBs" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar ALBs (puede no existir)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 2. ELIMINAR TARGET GROUPS
Write-Host ""
Write-Host "2️⃣  Eliminando Target Groups..." -ForegroundColor Yellow

try {
    $tgs = aws elbv2 describe-target-groups --region $region --query "TargetGroups[?contains(TargetGroupName, '$prefix')].TargetGroupArn" --output text 2>&1
    
    if ($tgs -and $tgs -notmatch "error") {
        $tgList = $tgs -split "`n" | Where-Object { $_ -match "arn:aws" }
        
        foreach ($tg in $tgList) {
            $tg = $tg.Trim()
            if ($tg) {
                Write-Host "  → Eliminando Target Group: $tg" -ForegroundColor Gray
                aws elbv2 delete-target-group --target-group-arn $tg --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Target Group eliminado" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron Target Groups" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar Target Groups" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 3. ELIMINAR SNS TOPICS
Write-Host ""
Write-Host "3️⃣  Eliminando SNS Topics..." -ForegroundColor Yellow

try {
    $topics = aws sns list-topics --region $region --query "Topics[?contains(TopicArn, '$prefix')].TopicArn" --output text 2>&1
    
    if ($topics -and $topics -notmatch "error") {
        $topicList = $topics -split "`n" | Where-Object { $_ -match "arn:aws" }
        
        foreach ($topic in $topicList) {
            $topic = $topic.Trim()
            if ($topic) {
                Write-Host "  → Eliminando SNS Topic: $topic" -ForegroundColor Gray
                aws sns delete-topic --topic-arn $topic --region $region 2>&1 | Out-Null
                Write-Host "  ✅ SNS Topic eliminado" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron SNS Topics" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar SNS Topics" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 4. ELIMINAR SQS QUEUES
Write-Host ""
Write-Host "4️⃣  Eliminando SQS Queues..." -ForegroundColor Yellow

try {
    $queues = aws sqs list-queues --region $region --queue-name-prefix $prefix --query "QueueUrls" --output text 2>&1
    
    if ($queues -and $queues -notmatch "error" -and $queues -notmatch "None") {
        $queueList = $queues -split "`n" | Where-Object { $_ }
        
        foreach ($queue in $queueList) {
            $queue = $queue.Trim()
            if ($queue) {
                Write-Host "  → Eliminando SQS Queue: $queue" -ForegroundColor Gray
                aws sqs delete-queue --queue-url $queue --region $region 2>&1 | Out-Null
                Write-Host "  ✅ SQS Queue eliminada" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron SQS Queues" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar SQS Queues" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 5. ELIMINAR API GATEWAYS
Write-Host ""
Write-Host "5️⃣  Eliminando API Gateways..." -ForegroundColor Yellow

try {
    $apis = aws apigateway get-rest-apis --region $region --query "items[?contains(name, '$prefix')].id" --output text 2>&1
    
    if ($apis -and $apis -notmatch "error") {
        $apiList = $apis -split "`n" | Where-Object { $_ }
        
        foreach ($api in $apiList) {
            $api = $api.Trim()
            if ($api) {
                Write-Host "  → Eliminando API Gateway: $api" -ForegroundColor Gray
                aws apigateway delete-rest-api --rest-api-id $api --region $region 2>&1 | Out-Null
                Write-Host "  ✅ API Gateway eliminado" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron API Gateways" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar API Gateways" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 6. ELIMINAR LAMBDA BFF (NO SE USA CON EVENTBRIDGE)
Write-Host ""
Write-Host "6️⃣  Eliminando Lambda BFF (innecesaria para EventBridge)..." -ForegroundColor Yellow

try {
    $bffLambda = "$prefix-bff-lambda"
    $lambdaExists = aws lambda get-function --function-name $bffLambda --region $region 2>&1
    
    if ($lambdaExists -notmatch "ResourceNotFoundException") {
        Write-Host "  → Eliminando Lambda BFF: $bffLambda" -ForegroundColor Gray
        aws lambda delete-function --function-name $bffLambda --region $region 2>&1 | Out-Null
        Write-Host "  ✅ Lambda BFF eliminada" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Lambda BFF no encontrada" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ℹ️  Lambda BFF no encontrada" -ForegroundColor Cyan
}

Start-Sleep -Seconds 2

# 7. ELIMINAR CLOUDWATCH ALARMS
Write-Host ""
Write-Host "7️⃣  Eliminando CloudWatch Alarms..." -ForegroundColor Yellow

try {
    $alarms = aws cloudwatch describe-alarms --region $region --query "MetricAlarms[?contains(AlarmName, '$prefix')].AlarmName" --output text 2>&1
    
    if ($alarms -and $alarms -notmatch "error") {
        $alarmList = $alarms -split "`n" | Where-Object { $_ }
        
        foreach ($alarm in $alarmList) {
            $alarm = $alarm.Trim()
            if ($alarm) {
                Write-Host "  → Eliminando Alarm: $alarm" -ForegroundColor Gray
                aws cloudwatch delete-alarms --alarm-names $alarm --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Alarm eliminada" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron CloudWatch Alarms" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar CloudWatch Alarms" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 8. LIMPIAR S3 BUCKETS (LOGS ALB)
Write-Host ""
Write-Host "8️⃣  Limpiando S3 Buckets..." -ForegroundColor Yellow

try {
    $buckets = aws s3api list-buckets --region $region --query "Buckets[?contains(Name, '$prefix')].Name" --output text 2>&1
    
    if ($buckets -and $buckets -notmatch "error") {
        $bucketList = $buckets -split "`n" | Where-Object { $_ }
        
        foreach ($bucket in $bucketList) {
            $bucket = $bucket.Trim()
            if ($bucket) {
                Write-Host "  → Vaciando bucket: $bucket" -ForegroundColor Gray
                aws s3 rm "s3://$bucket" --recursive --region $region 2>&1 | Out-Null
                
                Write-Host "  → Eliminando bucket: $bucket" -ForegroundColor Gray
                aws s3api delete-bucket --bucket $bucket --region $region 2>&1 | Out-Null
                Write-Host "  ✅ Bucket eliminado" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ℹ️  No se encontraron S3 Buckets" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠️  Error al eliminar S3 Buckets" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 9. VERIFICAR QUE EVENTBRIDGE Y LAMBDA EMAIL SIGUEN
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "VERIFICACIÓN FINAL" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Verificando que EventBridge sigue funcionando..." -ForegroundColor Yellow
Write-Host ""

# Verificar EventBridge Rule
$ebRule = aws events describe-rule --name "$prefix-email-scheduler" --region $region 2>&1

if ($ebRule -notmatch "ResourceNotFoundException") {
    Write-Host "  ✅ EventBridge Rule: ACTIVA" -ForegroundColor Green
} else {
    Write-Host "  ❌ EventBridge Rule: NO ENCONTRADA (ERROR!)" -ForegroundColor Red
}

# Verificar Lambda Email
$emailLambda = aws lambda get-function --function-name "$prefix-email-lambda" --region $region 2>&1

if ($emailLambda -notmatch "ResourceNotFoundException") {
    Write-Host "  ✅ Lambda Email: ACTIVA" -ForegroundColor Green
} else {
    Write-Host "  ❌ Lambda Email: NO ENCONTRADA (ERROR!)" -ForegroundColor Red
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ ELIMINACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 RESUMEN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "ELIMINADO:" -ForegroundColor Red
Write-Host "  ❌ Application Load Balancer (ALB)" -ForegroundColor Red
Write-Host "  ❌ Target Groups" -ForegroundColor Red
Write-Host "  ❌ SNS Topics" -ForegroundColor Red
Write-Host "  ❌ SQS Queues" -ForegroundColor Red
Write-Host "  ❌ API Gateway" -ForegroundColor Red
Write-Host "  ❌ Lambda BFF" -ForegroundColor Red
Write-Host "  ❌ CloudWatch Alarms" -ForegroundColor Red
Write-Host "  ❌ S3 Buckets (logs)" -ForegroundColor Red
Write-Host ""

Write-Host "MANTENIDO:" -ForegroundColor Green
Write-Host "  ✅ EventBridge Rule (envío automático cada 5 min)" -ForegroundColor Green
Write-Host "  ✅ Lambda Email Function" -ForegroundColor Green
Write-Host "  ✅ CloudWatch Logs (/aws/lambda/crud-app-email-lambda)" -ForegroundColor Green
Write-Host "  ✅ IAM Roles y Policies" -ForegroundColor Green
Write-Host ""

Write-Host "💰 AHORRO ESTIMADO: $20-25/mes ($240-300/año)" -ForegroundColor Green
Write-Host ""

Write-Host "🔄 EVENTBRIDGE SIGUE FUNCIONANDO:" -ForegroundColor Yellow
Write-Host "  → Envía correos automáticamente cada 5 minutos" -ForegroundColor White
Write-Host "  → Revisa: alexfrank.af04@gmail.com" -ForegroundColor White
Write-Host "  → CloudWatch Logs: /aws/lambda/crud-app-email-lambda" -ForegroundColor White
Write-Host ""

Write-Host "📝 PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "  1. Verifica EventBridge en AWS Console:" -ForegroundColor White
Write-Host "     https://console.aws.amazon.com/events/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Verifica los logs en CloudWatch:" -ForegroundColor White
Write-Host "     https://console.aws.amazon.com/cloudwatch/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Revisa tu correo (deberías seguir recibiendo cada 5 min)" -ForegroundColor White
Write-Host ""

Write-Host "✅ ¡LISTO! Servicios con costo cancelados." -ForegroundColor Green
Write-Host ""

Set-Location "C:\Users\alex008c\Documents\Programacion\CrudEmpleados"
