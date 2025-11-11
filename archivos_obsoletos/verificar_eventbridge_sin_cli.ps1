# ============================================
# GUÍA: VERIFICAR EVENTBRIDGE SIN AWS CLI
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERIFICAR EVENTBRIDGE SIN AWS CLI" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SITUACIÓN:" -ForegroundColor Yellow
Write-Host "  - AWS CLI no tiene credenciales configuradas" -ForegroundColor White
Write-Host "  - Necesitas Access Key y Secret Key para usar AWS CLI" -ForegroundColor White
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "OPCIÓN 1: VERIFICAR EN AWS CONSOLE (WEB)" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Esta es la forma MÁS RÁPIDA sin necesidad de credenciales:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Abre AWS Console en tu navegador:" -ForegroundColor White
Write-Host "   https://console.aws.amazon.com/" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. Inicia sesión con tu cuenta AWS" -ForegroundColor White
Write-Host ""

Write-Host "3. Ve a EventBridge:" -ForegroundColor White
Write-Host "   https://console.aws.amazon.com/events/home?region=us-east-1#/rules" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. Busca la regla: crud-app-email-scheduler" -ForegroundColor White
Write-Host ""

Write-Host "   SI LA VES:" -ForegroundColor Green
Write-Host "   ✅ EventBridge ESTÁ desplegado" -ForegroundColor Green
Write-Host "   ✅ Verifica que el estado sea ENABLED" -ForegroundColor Green
Write-Host "   ✅ Schedule debe ser: rate(5 minutes)" -ForegroundColor Green
Write-Host ""

Write-Host "   SI NO LA VES:" -ForegroundColor Red
Write-Host "   ❌ EventBridge NO está desplegado" -ForegroundColor Red
Write-Host "   ❌ Necesitas ejecutar: terraform apply" -ForegroundColor Red
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "OPCIÓN 2: REVISAR TU GMAIL" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Esta es la forma MÁS SIMPLE de verificar:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Abre tu Gmail: alexfrank.af04@gmail.com" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. Busca correos con asunto:" -ForegroundColor White
Write-Host "   'Correo Automatizado - EventBridge'" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. Revisa los timestamps:" -ForegroundColor White
Write-Host ""

Write-Host "   SI RECIBES CORREOS CADA 5 MINUTOS:" -ForegroundColor Green
Write-Host "   ✅ EventBridge FUNCIONA correctamente" -ForegroundColor Green
Write-Host "   ✅ Lambda está enviando correos automáticamente" -ForegroundColor Green
Write-Host "   ✅ Sistema completamente operativo" -ForegroundColor Green
Write-Host ""

Write-Host "   SI NO RECIBES CORREOS:" -ForegroundColor Red
Write-Host "   ❌ EventBridge NO está funcionando" -ForegroundColor Red
Write-Host "   ❌ O no está desplegado" -ForegroundColor Red
Write-Host "   ❌ O Lambda tiene un error" -ForegroundColor Red
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "OPCIÓN 3: CONFIGURAR AWS CLI" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Para usar scripts automáticos, necesitas configurar AWS CLI:" -ForegroundColor White
Write-Host ""

Write-Host "Paso 1: Obtener credenciales AWS" -ForegroundColor Yellow
Write-Host "  1. Ve a AWS Console: https://console.aws.amazon.com/" -ForegroundColor Gray
Write-Host "  2. IAM → Users → Tu usuario" -ForegroundColor Gray
Write-Host "  3. Security credentials tab" -ForegroundColor Gray
Write-Host "  4. Create access key" -ForegroundColor Gray
Write-Host "  5. Guarda Access Key ID y Secret Access Key" -ForegroundColor Gray
Write-Host ""

Write-Host "Paso 2: Configurar AWS CLI" -ForegroundColor Yellow
Write-Host "  aws configure" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Te pedirá:" -ForegroundColor Gray
Write-Host "  - AWS Access Key ID: (pega tu Access Key)" -ForegroundColor Gray
Write-Host "  - AWS Secret Access Key: (pega tu Secret Key)" -ForegroundColor Gray
Write-Host "  - Default region name: us-east-1" -ForegroundColor Gray
Write-Host "  - Default output format: json" -ForegroundColor Gray
Write-Host ""

Write-Host "Paso 3: Verificar" -ForegroundColor Yellow
Write-Host "  aws sts get-caller-identity" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Debería mostrar tu Account ID y User ARN" -ForegroundColor Gray
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "RECURSOS A VERIFICAR (AWS CONSOLE)" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ NECESARIOS (mantener):" -ForegroundColor Green
Write-Host ""
Write-Host "  EventBridge Rule" -ForegroundColor White
Write-Host "  - Nombre: crud-app-email-scheduler" -ForegroundColor Gray
Write-Host "  - Estado: ENABLED" -ForegroundColor Gray
Write-Host "  - Costo: FREE" -ForegroundColor Green
Write-Host "  - URL: https://console.aws.amazon.com/events/" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Lambda Email Function" -ForegroundColor White
Write-Host "  - Nombre: crud-app-email-lambda" -ForegroundColor Gray
Write-Host "  - Runtime: Python 3.11" -ForegroundColor Gray
Write-Host "  - Costo: FREE (free tier)" -ForegroundColor Green
Write-Host "  - URL: https://console.aws.amazon.com/lambda/" -ForegroundColor Cyan
Write-Host ""

Write-Host "  CloudWatch Logs" -ForegroundColor White
Write-Host "  - Log Group: /aws/lambda/crud-app-email-lambda" -ForegroundColor Gray
Write-Host "  - Debe tener logs cada 5 min" -ForegroundColor Gray
Write-Host "  - Costo: FREE (free tier)" -ForegroundColor Green
Write-Host "  - URL: https://console.aws.amazon.com/cloudwatch/" -ForegroundColor Cyan
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "❌ CON COSTO (eliminar si existen):" -ForegroundColor Red
Write-Host ""
Write-Host "  Load Balancer (ALB)" -ForegroundColor White
Write-Host "  - Costo: 16-20 USD/mes" -ForegroundColor Red
Write-Host "  - URL: https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:" -ForegroundColor Cyan
Write-Host ""

Write-Host "  SNS Topic" -ForegroundColor White
Write-Host "  - Costo: 0.50 USD/mes" -ForegroundColor Red
Write-Host "  - URL: https://console.aws.amazon.com/sns/" -ForegroundColor Cyan
Write-Host ""

Write-Host "  SQS Queues" -ForegroundColor White
Write-Host "  - Costo: 0.40-0.90 USD/mes" -ForegroundColor Red
Write-Host "  - URL: https://console.aws.amazon.com/sqs/" -ForegroundColor Cyan
Write-Host ""

Write-Host "  API Gateway" -ForegroundColor White
Write-Host "  - Costo: 3.50 USD/mes" -ForegroundColor Red
Write-Host "  - URL: https://console.aws.amazon.com/apigateway/" -ForegroundColor Cyan
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "FORMA MÁS RÁPIDA DE VERIFICAR:" -ForegroundColor Green
Write-Host "  1. Revisa tu Gmail (alexfrank.af04@gmail.com)" -ForegroundColor White
Write-Host "  2. Si recibes correos cada 5 min: EventBridge funciona ✅" -ForegroundColor Green
Write-Host "  3. Si no recibes correos: EventBridge no está desplegado ❌" -ForegroundColor Red
Write-Host ""

Write-Host "FORMA MÁS COMPLETA:" -ForegroundColor Green
Write-Host "  1. Abre AWS Console (web)" -ForegroundColor White
Write-Host "  2. Verifica EventBridge, Lambda, CloudWatch Logs" -ForegroundColor White
Write-Host "  3. Elimina recursos con costo (ALB, SNS, SQS, API Gateway)" -ForegroundColor White
Write-Host ""

Write-Host "PARA AUTOMATIZAR EN EL FUTURO:" -ForegroundColor Yellow
Write-Host "  1. Crea Access Key en AWS Console" -ForegroundColor White
Write-Host "  2. Ejecuta: aws configure" -ForegroundColor White
Write-Host "  3. Usa los scripts de verificación automática" -ForegroundColor White
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$respuesta = Read-Host "¿Quieres que abra las consolas AWS en tu navegador? (S/N)"

if ($respuesta -eq "S" -or $respuesta -eq "s") {
    Write-Host ""
    Write-Host "Abriendo consolas AWS..." -ForegroundColor Green
    Write-Host ""
    
    Start-Process "https://console.aws.amazon.com/events/home?region=us-east-1#/rules"
    Start-Sleep -Seconds 2
    Start-Process "https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions"
    Start-Sleep -Seconds 2
    Start-Process "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups"
    
    Write-Host "✅ Navegador abierto" -ForegroundColor Green
    Write-Host ""
    Write-Host "Revisa las pestañas y busca:" -ForegroundColor Yellow
    Write-Host "  - EventBridge: crud-app-email-scheduler" -ForegroundColor White
    Write-Host "  - Lambda: crud-app-email-lambda" -ForegroundColor White
    Write-Host "  - CloudWatch Logs: /aws/lambda/crud-app-email-lambda" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "OK. Puedes abrir manualmente cuando quieras." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
