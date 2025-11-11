# ============================================
# VERIFICAR EJECUCIONES DE EVENTBRIDGE
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION DE EVENTBRIDGE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$region = "us-east-1"

# 1. Estado de EventBridge
Write-Host "1. Estado de EventBridge Rule:" -ForegroundColor Yellow
$rule = aws events describe-rule --name crud-app-email-scheduler --region $region 2>$null | ConvertFrom-Json
if ($rule) {
    Write-Host "   Nombre: $($rule.Name)" -ForegroundColor White
    Write-Host "   Estado: $($rule.State)" -ForegroundColor Green
    Write-Host "   Schedule: $($rule.ScheduleExpression)" -ForegroundColor Green
    Write-Host "   Descripcion: $($rule.Description)" -ForegroundColor Gray
} else {
    Write-Host "   ERROR: No se encontro la regla" -ForegroundColor Red
}

Write-Host ""

# 2. Target configurado
Write-Host "2. Target (Lambda) configurado:" -ForegroundColor Yellow
$targets = aws events list-targets-by-rule --rule crud-app-email-scheduler --region $region 2>$null | ConvertFrom-Json
if ($targets.Targets) {
    Write-Host "   Lambda ARN: $($targets.Targets[0].Arn)" -ForegroundColor Green
} else {
    Write-Host "   ERROR: No hay targets configurados" -ForegroundColor Red
}

Write-Host ""

# 3. Logs de CloudWatch (ultimos 15 minutos)
Write-Host "3. Logs de CloudWatch (ultimos 15 minutos):" -ForegroundColor Yellow
Write-Host ""

$logs = aws logs tail /aws/lambda/crud-app-email-lambda --since 15m --region $region --format short 2>$null

if ($logs) {
    Write-Host $logs
    Write-Host ""
    Write-Host "   Ejecuciones encontradas!" -ForegroundColor Green
} else {
    Write-Host "   No hay logs recientes (espera 5 minutos desde el despliegue)" -ForegroundColor Yellow
}

Write-Host ""

# 4. Ultima ejecucion
Write-Host "4. Informacion de ultima ejecucion:" -ForegroundColor Yellow
$lastEvent = aws logs describe-log-streams --log-group-name /aws/lambda/crud-app-email-lambda --order-by LastEventTime --descending --max-items 1 --region $region 2>$null | ConvertFrom-Json

if ($lastEvent.logStreams) {
    $timestamp = [DateTimeOffset]::FromUnixTimeMilliseconds($lastEvent.logStreams[0].lastEventTime).LocalDateTime
    Write-Host "   Ultima actividad: $($timestamp.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Green
} else {
    Write-Host "   Aun no hay ejecuciones" -ForegroundColor Yellow
}

Write-Host ""

# 5. Metricas de EventBridge
Write-Host "5. Metricas de EventBridge (ultima hora):" -ForegroundColor Yellow
$endTime = Get-Date
$startTime = $endTime.AddMinutes(-60)

$metrics = aws cloudwatch get-metric-statistics --namespace AWS/Events --metric-name Invocations --dimensions Name=RuleName,Value=crud-app-email-scheduler --start-time $startTime.ToString("yyyy-MM-ddTHH:mm:ss") --end-time $endTime.ToString("yyyy-MM-ddTHH:mm:ss") --period 300 --statistics Sum --region $region 2>$null | ConvertFrom-Json

if ($metrics.Datapoints) {
    Write-Host "   Invocaciones totales: $($metrics.Datapoints.Sum)" -ForegroundColor Green
    Write-Host "   Puntos de datos: $($metrics.Datapoints.Count)" -ForegroundColor Gray
} else {
    Write-Host "   Sin metricas aun (espera la primera ejecucion)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "RESUMEN:" -ForegroundColor Yellow
Write-Host ""

if ($rule.State -eq "ENABLED") {
    Write-Host "EventBridge: ACTIVO y funcionando" -ForegroundColor Green
    Write-Host "Frecuencia: Cada 5 minutos" -ForegroundColor Green
    Write-Host "Proximo envio: En los proximos 5 minutos" -ForegroundColor Green
} else {
    Write-Host "EventBridge: DESHABILITADO" -ForegroundColor Red
}

Write-Host ""
Write-Host "Para ver ejecuciones en tiempo real:" -ForegroundColor Cyan
Write-Host "  aws logs tail /aws/lambda/crud-app-email-lambda --follow --region us-east-1" -ForegroundColor Gray
Write-Host ""
Write-Host "Para ver en AWS Console:" -ForegroundColor Cyan
Write-Host "  CloudWatch: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group//aws/lambda/crud-app-email-lambda" -ForegroundColor Gray
Write-Host ""

Write-Host "Revisa tu Gmail: alexfrank.af04@gmail.com" -ForegroundColor Yellow
Write-Host "Asunto: 'Correo Automatizado - EventBridge'" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
