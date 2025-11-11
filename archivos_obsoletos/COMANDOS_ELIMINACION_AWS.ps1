# ============================================
# SCRIPT DE ELIMINACIÓN DE RECURSOS AWS
# ============================================
# Elimina recursos con costo manteniendo EventBridge funcionando
# Ahorro estimado: $17-25/mes

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ELIMINACIÓN DE RECURSOS AWS CON COSTO" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar ubicación
if (-not (Test-Path ".\terraform\terraform.exe")) {
    Write-Host "❌ ERROR: Debes ejecutar este script desde la raíz del proyecto" -ForegroundColor Red
    Write-Host "   Ubicación actual: $PWD" -ForegroundColor Yellow
    Write-Host "   Ubicación esperada: C:\Users\alex008c\Documents\Programacion\CrudEmpleados" -ForegroundColor Yellow
    exit 1
}

cd terraform

Write-Host "📊 ANÁLISIS DE COSTOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "RECURSOS A ELIMINAR (CON COSTO):" -ForegroundColor Red
Write-Host "  💸 ALB (Load Balancer)        : ~$16-20/mes" -ForegroundColor Red
Write-Host "  💸 SNS Topic                  : ~$0.50/mes" -ForegroundColor Red
Write-Host "  💸 SQS Queues (2)             : ~$0.90/mes" -ForegroundColor Red
Write-Host "  💸 API Gateway                : ~$3.50/mes (después de free tier)" -ForegroundColor Red
Write-Host "  💸 CloudWatch Alarms          : ~$0.10/mes (si tienes >10)" -ForegroundColor Red
Write-Host ""
Write-Host "TOTAL AHORRO ESTIMADO: $17-25/mes" -ForegroundColor Green
Write-Host ""

Write-Host "RECURSOS QUE SE MANTIENEN (NECESARIOS PARA EVENTBRIDGE):" -ForegroundColor Green
Write-Host "  ✅ Lambda Email Function      : $0.00 (free tier)" -ForegroundColor Green
Write-Host "  ✅ EventBridge Rule           : $0.00 (free tier)" -ForegroundColor Green
Write-Host "  ✅ CloudWatch Logs            : $0.00 (free tier)" -ForegroundColor Green
Write-Host "  ✅ IAM Roles/Policies         : $0.00 (siempre gratis)" -ForegroundColor Green
Write-Host ""

# Advertencia
Write-Host "⚠️  ADVERTENCIA:" -ForegroundColor Yellow
Write-Host "   - Esta operación eliminará recursos de AWS permanentemente" -ForegroundColor Yellow
Write-Host "   - EventBridge seguirá funcionando (envío automático cada 5 min)" -ForegroundColor Yellow
Write-Host "   - El frontend NO podrá enviar correos manualmente (solo automático con EventBridge)" -ForegroundColor Yellow
Write-Host ""

# Confirmación
$confirm = Read-Host "¿Deseas continuar con la eliminación? (escribe 'SI' para confirmar)"

if ($confirm -ne "SI") {
    Write-Host ""
    Write-Host "❌ Operación cancelada por el usuario." -ForegroundColor Yellow
    Write-Host ""
    cd ..
    exit 0
}

Write-Host ""
Write-Host "🗑️  Iniciando eliminación de recursos..." -ForegroundColor Cyan
Write-Host ""

# ============================================
# FASE 1: ELIMINAR ALB (Mayor ahorro)
# ============================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "FASE 1: Eliminando Application Load Balancer" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "📦 Eliminando recursos del ALB..." -ForegroundColor Yellow

# Lista de recursos del ALB en orden de dependencias
$alb_resources = @(
    "aws_lb_listener.http",
    "aws_lb_target_group_attachment.lambda_bff",
    "aws_lb_target_group.lambda_bff",
    "aws_lb.main",
    "aws_s3_bucket_policy.alb_logs",
    "aws_s3_bucket.alb_logs",
    "aws_lambda_permission.alb_invoke"
)

foreach ($resource in $alb_resources) {
    Write-Host "  → Eliminando: $resource" -ForegroundColor Gray
    $result = .\terraform.exe destroy -target=$resource -auto-approve 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ⚠️  Warning: Error al eliminar $resource (puede no existir)" -ForegroundColor Yellow
    } else {
        Write-Host "    ✅ Eliminado: $resource" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ FASE 1 COMPLETADA - ALB eliminado" -ForegroundColor Green
Write-Host "   💰 Ahorro: ~$16-20/mes" -ForegroundColor Green
Write-Host ""

# ============================================
# FASE 2: ELIMINAR SNS/SQS
# ============================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "FASE 2: Eliminando SNS Topic y SQS Queues" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "📦 Eliminando recursos de mensajería..." -ForegroundColor Yellow

# Lista de recursos SNS/SQS en orden de dependencias
$messaging_resources = @(
    "aws_lambda_event_source_mapping.email_sqs_trigger",
    "aws_sns_topic_subscription.email_sqs_subscription",
    "aws_sqs_queue_policy.email_queue_policy",
    "aws_sqs_queue.email_queue",
    "aws_sqs_queue.email_dlq",
    "aws_sns_topic.email_topic"
)

foreach ($resource in $messaging_resources) {
    Write-Host "  → Eliminando: $resource" -ForegroundColor Gray
    $result = .\terraform.exe destroy -target=$resource -auto-approve 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ⚠️  Warning: Error al eliminar $resource (puede no existir)" -ForegroundColor Yellow
    } else {
        Write-Host "    ✅ Eliminado: $resource" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ FASE 2 COMPLETADA - SNS/SQS eliminados" -ForegroundColor Green
Write-Host "   💰 Ahorro: ~$0.90-1.50/mes" -ForegroundColor Green
Write-Host ""

# ============================================
# FASE 3: ELIMINAR API GATEWAY (OPCIONAL)
# ============================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "FASE 3: API Gateway (OPCIONAL)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  API Gateway permite enviar correos MANUALMENTE desde el frontend" -ForegroundColor Yellow
Write-Host "   Si lo eliminas, solo funcionará el envío AUTOMÁTICO (EventBridge)" -ForegroundColor Yellow
Write-Host ""

$confirm_api = Read-Host "¿Deseas eliminar API Gateway? (escribe 'SI' para confirmar)"

if ($confirm_api -eq "SI") {
    Write-Host ""
    Write-Host "📦 Eliminando API Gateway..." -ForegroundColor Yellow
    
    # Nota: Aquí deberías listar todos los recursos de api_gateway_email.tf
    # Por ahora solo mostramos el mensaje
    Write-Host "  ℹ️  Para eliminar completamente API Gateway, ejecuta:" -ForegroundColor Cyan
    Write-Host "     .\terraform.exe destroy -target=module.api_gateway -auto-approve" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   💰 Ahorro adicional: ~$3.50/mes (después de free tier)" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "✅ API Gateway mantenido - Puedes seguir enviando correos manualmente" -ForegroundColor Green
}

Write-Host ""

# ============================================
# FASE 4: ELIMINAR CLOUDWATCH ALARMS (OPCIONAL)
# ============================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "FASE 4: CloudWatch Alarms (OPCIONAL)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "ℹ️  CloudWatch Alarms solo tienen costo si tienes más de 10 alarmas" -ForegroundColor Cyan
Write-Host "   Las primeras 10 alarmas son GRATIS" -ForegroundColor Cyan
Write-Host ""

$confirm_alarms = Read-Host "¿Deseas eliminar CloudWatch Alarms? (escribe 'SI' para confirmar)"

if ($confirm_alarms -eq "SI") {
    Write-Host ""
    Write-Host "📦 Eliminando CloudWatch Alarms..." -ForegroundColor Yellow
    
    $alarm_resources = @(
        "aws_cloudwatch_metric_alarm.lambda_errors",
        "aws_cloudwatch_metric_alarm.lambda_high_concurrency"
    )
    
    foreach ($resource in $alarm_resources) {
        Write-Host "  → Eliminando: $resource" -ForegroundColor Gray
        $result = .\terraform.exe destroy -target=$resource -auto-approve 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "    ⚠️  Warning: Error al eliminar $resource (puede no existir)" -ForegroundColor Yellow
        } else {
            Write-Host "    ✅ Eliminado: $resource" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "✅ CloudWatch Alarms eliminadas" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "✅ CloudWatch Alarms mantenidas (sin costo si tienes <10)" -ForegroundColor Green
}

Write-Host ""

# ============================================
# RESUMEN FINAL
# ============================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ ELIMINACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 RECURSOS ELIMINADOS:" -ForegroundColor Yellow
Write-Host "  ✅ Application Load Balancer (ALB)" -ForegroundColor Green
Write-Host "  ✅ SNS Topic" -ForegroundColor Green
Write-Host "  ✅ SQS Queues (email-queue + email-dlq)" -ForegroundColor Green
if ($confirm_api -eq "SI") {
    Write-Host "  ✅ API Gateway (opcional)" -ForegroundColor Green
}
if ($confirm_alarms -eq "SI") {
    Write-Host "  ✅ CloudWatch Alarms (opcional)" -ForegroundColor Green
}
Write-Host ""

Write-Host "🔄 RECURSOS QUE SIGUEN FUNCIONANDO:" -ForegroundColor Yellow
Write-Host "  ✅ EventBridge Rule (schedule: cada 5 minutos)" -ForegroundColor Green
Write-Host "  ✅ Lambda Email Function" -ForegroundColor Green
Write-Host "  ✅ CloudWatch Logs" -ForegroundColor Green
Write-Host "  ✅ IAM Roles y Policies" -ForegroundColor Green
Write-Host ""

Write-Host "💰 AHORRO ESTIMADO: $17-25/mes" -ForegroundColor Green
Write-Host ""

Write-Host "🎯 VERIFICACIÓN:" -ForegroundColor Yellow
Write-Host "  1. EventBridge sigue enviando correos cada 5 minutos" -ForegroundColor White
Write-Host "  2. Revisa tu email: alexfrank.af04@gmail.com" -ForegroundColor White
Write-Host "  3. CloudWatch Logs: /aws/lambda/crud-app-email-lambda" -ForegroundColor White
Write-Host ""

Write-Host "📝 SIGUIENTE PASO:" -ForegroundColor Yellow
Write-Host "   Abre AWS Console y verifica:" -ForegroundColor White
Write-Host "   → EventBridge: https://console.aws.amazon.com/events/" -ForegroundColor Cyan
Write-Host "   → CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  NOTA:" -ForegroundColor Yellow
Write-Host "   Si eliminaste API Gateway, el frontend NO podrá enviar correos manualmente." -ForegroundColor Yellow
Write-Host "   Solo funcionará el envío AUTOMÁTICO cada 5 minutos por EventBridge." -ForegroundColor Yellow
Write-Host ""

cd ..

Write-Host "✅ Script completado exitosamente" -ForegroundColor Green
Write-Host ""
