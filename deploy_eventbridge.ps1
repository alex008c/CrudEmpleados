# ====================================================================
#  DESPLEGAR EVENTBRIDGE SCHEDULER
#  Automatiza el envío de correos con EventBridge + Lambda
# ====================================================================

$Host.UI.RawUI.WindowTitle = "Deploy EventBridge Scheduler"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " DEPLOY EVENTBRIDGE SCHEDULER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TERRAFORM_DIR = Join-Path $PSScriptRoot "terraform"

# Verificar que existe la carpeta terraform
if (-not (Test-Path $TERRAFORM_DIR)) {
    Write-Host "Error: No se encontro la carpeta terraform" -ForegroundColor Red
    exit 1
}

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  - Schedule: Cada 5 minutos" -ForegroundColor White
Write-Host "  - Destinatario: alexfrank.af04@gmail.com" -ForegroundColor White
Write-Host "  - Recursos: EventBridge Rule + Target + Lambda Permission" -ForegroundColor White
Write-Host ""

# Cambiar a directorio de terraform
Set-Location $TERRAFORM_DIR

Write-Host "[1/4] Validando configuracion de Terraform..." -ForegroundColor Green
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nError: Configuracion de Terraform invalida" -ForegroundColor Red
    exit 1
}

Write-Host "`n[2/4] Generando plan de ejecucion..." -ForegroundColor Green
terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nError: Fallo al generar plan" -ForegroundColor Red
    exit 1
}

Write-Host "`n[3/4] Aplicando cambios..." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE: Revisa los recursos que se crearan" -ForegroundColor Yellow
Write-Host "  - aws_cloudwatch_event_rule.email_scheduler" -ForegroundColor White
Write-Host "  - aws_cloudwatch_event_target.email_lambda_target" -ForegroundColor White
Write-Host "  - aws_lambda_permission.allow_eventbridge" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continuar con el despliegue? (si/no)"

if ($confirm -ne "si" -and $confirm -ne "s" -and $confirm -ne "yes" -and $confirm -ne "y") {
    Write-Host "`nDespliegue cancelado por el usuario" -ForegroundColor Yellow
    Remove-Item tfplan -ErrorAction SilentlyContinue
    exit 0
}

terraform apply tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nError: Fallo al aplicar cambios" -ForegroundColor Red
    exit 1
}

Write-Host "`n[4/4] Limpiando archivos temporales..." -ForegroundColor Green
Remove-Item tfplan -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "La Lambda se ejecutara automaticamente cada 5 minutos" -ForegroundColor Yellow
Write-Host ""
Write-Host "Verificacion:" -ForegroundColor Cyan
Write-Host "  1. AWS Console EventBridge:" -ForegroundColor White
Write-Host "     https://console.aws.amazon.com/events/" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. CloudWatch Logs:" -ForegroundColor White
Write-Host "     https://console.aws.amazon.com/cloudwatch/" -ForegroundColor Gray
Write-Host "     Log Group: /aws/lambda/crud-app-email-lambda" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Email:" -ForegroundColor White
Write-Host "     Revisa: alexfrank.af04@gmail.com" -ForegroundColor Gray
Write-Host ""
Write-Host "Para ver outputs:" -ForegroundColor Yellow
Write-Host "  terraform output" -ForegroundColor White
Write-Host ""
Write-Host "Para detener (deshabilitar):" -ForegroundColor Yellow
Write-Host "  aws events disable-rule --name crud-app-email-scheduler --region us-east-1" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Volver al directorio original
Set-Location $PSScriptRoot
