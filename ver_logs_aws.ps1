# ============================================
# VERIFICAR RECURSOS AWS EN NAVEGADOR
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION DE RECURSOS AWS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$region = "us-east-1"

Write-Host "Abriendo consolas de AWS en tu navegador..." -ForegroundColor Yellow
Write-Host ""

Start-Sleep -Seconds 1

# 1. EventBridge
Write-Host "1. EventBridge Rules..." -ForegroundColor Yellow
Start-Process "https://console.aws.amazon.com/events/home?region=$region#/rules"
Start-Sleep -Seconds 2

# 2. Lambda Functions
Write-Host "2. Lambda Functions..." -ForegroundColor Yellow
Start-Process "https://console.aws.amazon.com/lambda/home?region=$region#/functions"
Start-Sleep -Seconds 2

# 3. CloudWatch Logs
Write-Host "3. CloudWatch Logs..." -ForegroundColor Yellow
Start-Process "https://console.aws.amazon.com/cloudwatch/home?region=$region#logsV2:log-groups"
Start-Sleep -Seconds 2

# 4. Load Balancers
Write-Host "4. Load Balancers (COSTO)..." -ForegroundColor Red
Start-Process "https://console.aws.amazon.com/ec2/v2/home?region=$region#LoadBalancers:"
Start-Sleep -Seconds 2

# 5. SNS Topics
Write-Host "5. SNS Topics (COSTO)..." -ForegroundColor Red
Start-Process "https://console.aws.amazon.com/sns/v3/home?region=$region#/topics"
Start-Sleep -Seconds 2

# 6. SQS Queues
Write-Host "6. SQS Queues (COSTO)..." -ForegroundColor Red
Start-Process "https://console.aws.amazon.com/sqs/v2/home?region=$region#/queues"
Start-Sleep -Seconds 2

# 7. API Gateway
Write-Host "7. API Gateway (COSTO)..." -ForegroundColor Red
Start-Process "https://console.aws.amazon.com/apigateway/main/apis?region=$region"
Start-Sleep -Seconds 2

# 8. Billing
Write-Host "8. Billing Dashboard..." -ForegroundColor Yellow
Start-Process "https://console.aws.amazon.com/billing/home#/"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "VERIFICAR:" -ForegroundColor Green
Write-Host "  EventBridge Rule: crud-app-email-scheduler (ENABLED)" -ForegroundColor White
Write-Host "  Lambda: crud-app-email-lambda" -ForegroundColor White
Write-Host "  CloudWatch Logs: /aws/lambda/crud-app-email-lambda" -ForegroundColor White
Write-Host ""

Write-Host "ELIMINAR SI EXISTE:" -ForegroundColor Red
Write-Host "  ALB Load Balancer (16-20 USD/mes)" -ForegroundColor White
Write-Host "  SNS Topics (0.50 USD/mes)" -ForegroundColor White
Write-Host "  SQS Queues (0.90 USD/mes)" -ForegroundColor White
Write-Host "  API Gateway (3.50 USD/mes)" -ForegroundColor White
Write-Host ""

Write-Host "Revisa tu Gmail: alexfrank.af04@gmail.com" -ForegroundColor Yellow
Write-Host "Si recibes correos cada 5 min: EventBridge funciona" -ForegroundColor Green
Write-Host ""
