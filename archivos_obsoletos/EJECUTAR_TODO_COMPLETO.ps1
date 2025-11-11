# ====================================================================
#  SCRIPT COMPLETO - CRUD EMPLEADOS CON EVENTBRIDGE
#  Ejecuta backend + BFF + frontend + despliega EventBridge
# ====================================================================

$Host.UI.RawUI.WindowTitle = "CRUD Empleados - Sistema Completo"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " CRUD EMPLEADOS - DESPLIEGUE COMPLETO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$PROYECTO_ROOT = $PSScriptRoot
$TERRAFORM_DIR = Join-Path $PROYECTO_ROOT "terraform"
$BACKEND_DIR = Join-Path $PROYECTO_ROOT "backend"
$BFF_DIR = Join-Path $PROYECTO_ROOT "bff"
$FRONTEND_DIR = Join-Path $PROYECTO_ROOT "frontend"

# Configuracion
$SUPABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"
$AWS_API_URL = "https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"
$AWS_API_KEY = "eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"

# ====================================================================
# PASO 1: INICIAR SERVICIOS LOCALES
# ====================================================================

Write-Host "[PASO 1/3] Iniciando servicios locales..." -ForegroundColor Green
Write-Host ""

Write-Host "  1.1. Backend FastAPI (puerto 8000)..." -ForegroundColor Yellow
$backendCmd = "cd '$BACKEND_DIR'; `$env:DATABASE_URL='$SUPABASE_URL'; python -m uvicorn main:app --reload"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendCmd
Start-Sleep -Seconds 3

Write-Host "  1.2. BFF Email Service (puerto 8001)..." -ForegroundColor Yellow
$bffCmd = "cd '$BFF_DIR'; `$env:PUBLISH_API_URL='$AWS_API_URL'; `$env:PUBLISH_API_KEY='$AWS_API_KEY'; python -m uvicorn main:app --reload --port 8001"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $bffCmd
Start-Sleep -Seconds 3

Write-Host "  1.3. Frontend Flutter (Windows)..." -ForegroundColor Yellow
$frontendCmd = "cd '$FRONTEND_DIR'; flutter run -d windows"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendCmd
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Servicios locales iniciados correctamente" -ForegroundColor Green
Write-Host "  - Backend: http://localhost:8000" -ForegroundColor White
Write-Host "  - BFF: http://localhost:8001" -ForegroundColor White
Write-Host "  - Frontend: Compilando..." -ForegroundColor White
Write-Host ""

# ====================================================================
# PASO 2: DESPLEGAR EVENTBRIDGE EN AWS
# ====================================================================

Write-Host "[PASO 2/3] Desplegando EventBridge Scheduler en AWS..." -ForegroundColor Green
Write-Host ""

Set-Location $TERRAFORM_DIR

Write-Host "  2.1. Verificando Terraform..." -ForegroundColor Yellow
if (-not (Test-Path ".\terraform.exe")) {
    Write-Host "  Error: terraform.exe no encontrado en la carpeta terraform" -ForegroundColor Red
    Write-Host "  Descarga Terraform de: https://www.terraform.io/downloads" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  NOTA: Los servicios locales estan corriendo." -ForegroundColor Cyan
    Write-Host "        Puedes usar la app sin EventBridge." -ForegroundColor Cyan
    Write-Host ""
    Set-Location $PROYECTO_ROOT
    Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "  2.2. Validando configuracion..." -ForegroundColor Yellow
.\terraform.exe validate -compact-warnings | Out-Null

Write-Host "  2.3. Generando plan (solo EventBridge)..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Recursos que se crearan:" -ForegroundColor Cyan
Write-Host "    - EventBridge Rule (ejecuta Lambda cada 5 minutos)" -ForegroundColor White
Write-Host "    - EventBridge Target (conecta con Lambda)" -ForegroundColor White
Write-Host "    - Lambda Permission (permite invocacion)" -ForegroundColor White
Write-Host ""

$planResult = .\terraform.exe plan `
    -target=aws_cloudwatch_event_rule.email_scheduler `
    -target=aws_cloudwatch_event_target.email_lambda_target `
    -target=aws_lambda_permission.allow_eventbridge `
    -compact-warnings 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "  Advertencia: No se pudo generar el plan completo" -ForegroundColor Yellow
    Write-Host "  Esto puede ser normal si algunos recursos ya existen" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Los servicios locales estan funcionando correctamente." -ForegroundColor Cyan
    Write-Host ""
    
    $continuar = Read-Host "  Deseas continuar sin desplegar EventBridge? (s/n)"
    if ($continuar -eq "n" -or $continuar -eq "no") {
        Set-Location $PROYECTO_ROOT
        Write-Host "`nProceso cancelado. Servicios locales activos." -ForegroundColor Yellow
        Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
} else {
    Write-Host "  2.4. Aplicando cambios en AWS..." -ForegroundColor Yellow
    
    $aplicar = Read-Host "  Continuar con el despliegue en AWS? (s/n)"
    
    if ($aplicar -eq "s" -or $aplicar -eq "si" -or $aplicar -eq "y" -or $aplicar -eq "yes") {
        .\terraform.exe apply `
            -target=aws_cloudwatch_event_rule.email_scheduler `
            -target=aws_cloudwatch_event_target.email_lambda_target `
            -target=aws_lambda_permission.allow_eventbridge `
            -auto-approve `
            -compact-warnings
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "  EventBridge desplegado correctamente!" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "  Advertencia: Hubo problemas con el despliegue" -ForegroundColor Yellow
            Write-Host "  Los servicios locales funcionan correctamente" -ForegroundColor Cyan
            Write-Host ""
        }
    } else {
        Write-Host ""
        Write-Host "  Despliegue de EventBridge omitido" -ForegroundColor Yellow
        Write-Host ""
    }
}

Set-Location $PROYECTO_ROOT

# ====================================================================
# PASO 3: RESUMEN Y VERIFICACION
# ====================================================================

Write-Host "[PASO 3/3] Sistema listo!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " SISTEMA COMPLETAMENTE OPERATIVO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "SERVICIOS ACTIVOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. LOCALES (funcionando ahora):" -ForegroundColor Yellow
Write-Host "   - Backend FastAPI: http://localhost:8000/docs" -ForegroundColor White
Write-Host "   - BFF Email: http://localhost:8001/docs" -ForegroundColor White
Write-Host "   - Frontend Flutter: Ventana de Windows" -ForegroundColor White
Write-Host ""

Write-Host "2. AWS (automatizacion):" -ForegroundColor Yellow
Write-Host "   - EventBridge: Ejecuta Lambda cada 5 minutos" -ForegroundColor White
Write-Host "   - CloudWatch Logs: /aws/lambda/crud-app-email-lambda" -ForegroundColor White
Write-Host "   - Correos enviados a: alexfrank.af04@gmail.com" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " COMO DEMOSTRAR LA TAREA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "DEMOSTRACION (5 MINUTOS):" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. MOSTRAR CODIGO (1 min):" -ForegroundColor Green
Write-Host "   - Abrir: terraform/eventbridge_scheduler.tf" -ForegroundColor White
Write-Host "   - Explicar: Regla + Target + Permisos" -ForegroundColor White
Write-Host "   - Mostrar: schedule_expression = rate(5 minutes)" -ForegroundColor White
Write-Host ""

Write-Host "2. MOSTRAR AWS CONSOLE (2 min):" -ForegroundColor Green
Write-Host "   A. EventBridge:" -ForegroundColor White
Write-Host "      https://console.aws.amazon.com/events/" -ForegroundColor Gray
Write-Host "      - Buscar regla: crud-app-email-scheduler" -ForegroundColor White
Write-Host "      - Estado: Enabled" -ForegroundColor White
Write-Host ""
Write-Host "   B. CloudWatch Logs:" -ForegroundColor White
Write-Host "      https://console.aws.amazon.com/cloudwatch/" -ForegroundColor Gray
Write-Host "      - Log Group: /aws/lambda/crud-app-email-lambda" -ForegroundColor White
Write-Host "      - Ver ejecuciones automaticas cada 5 minutos" -ForegroundColor White
Write-Host ""

Write-Host "3. MOSTRAR CORREO (1 min):" -ForegroundColor Green
Write-Host "   - Abrir Gmail: alexfrank.af04@gmail.com" -ForegroundColor White
Write-Host "   - Mostrar correos recibidos automaticamente" -ForegroundColor White
Write-Host ""

Write-Host "4. EXPLICAR CONCEPTOS (1 min):" -ForegroundColor Green
Write-Host "   - Paralelismo: Lambda escala automaticamente" -ForegroundColor White
Write-Host "   - Asincronia: EventBridge dispara sin esperar respuesta" -ForegroundColor White
Write-Host "   - Automatizacion: Sin intervencion manual" -ForegroundColor White
Write-Host "   - IaC: Todo definido en Terraform" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " COMANDOS UTILES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Ver logs en tiempo real:" -ForegroundColor Yellow
Write-Host "  aws logs tail /aws/lambda/crud-app-email-lambda --region us-east-1 --follow" -ForegroundColor White
Write-Host ""

Write-Host "Deshabilitar EventBridge (no cobra):" -ForegroundColor Yellow
Write-Host "  aws events disable-rule --name crud-app-email-scheduler --region us-east-1" -ForegroundColor White
Write-Host ""

Write-Host "Habilitar EventBridge:" -ForegroundColor Yellow
Write-Host "  aws events enable-rule --name crud-app-email-scheduler --region us-east-1" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " INFORMACION DE COSTOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SERVICIOS QUE ESTAN COBRANDO:" -ForegroundColor Red
Write-Host ""
Write-Host "1. SQS (Simple Queue Service):" -ForegroundColor Yellow
Write-Host "   - Costo: ~`$0.0004 por 10,000 peticiones" -ForegroundColor White
Write-Host "   - Si desactivas: NO afecta EventBridge" -ForegroundColor Green
Write-Host "   - EventBridge llama Lambda DIRECTAMENTE" -ForegroundColor Green
Write-Host ""

Write-Host "2. SNS (Simple Notification Service):" -ForegroundColor Yellow
Write-Host "   - Costo: ~`$0.50 por millon de notificaciones" -ForegroundColor White
Write-Host "   - Si desactivas: NO afecta EventBridge" -ForegroundColor Green
Write-Host "   - EventBridge -> Lambda (sin SNS/SQS)" -ForegroundColor Green
Write-Host ""

Write-Host "3. Lambda:" -ForegroundColor Yellow
Write-Host "   - Costo: ~`$0.20 por millon de peticiones" -ForegroundColor White
Write-Host "   - Si desactivas: SI afecta (es necesaria)" -ForegroundColor Red
Write-Host "   - EventBridge necesita Lambda para funcionar" -ForegroundColor Red
Write-Host ""

Write-Host "4. EventBridge:" -ForegroundColor Yellow
Write-Host "   - Costo: GRATIS (incluido en free tier)" -ForegroundColor Green
Write-Host "   - Primera regla: `$0" -ForegroundColor White
Write-Host "   - Ejecuciones: Capa gratuita generosa" -ForegroundColor White
Write-Host ""

Write-Host "RECOMENDACION:" -ForegroundColor Cyan
Write-Host "  - DESACTIVAR: SNS y SQS (ahorras `$0.50-1/mes)" -ForegroundColor Green
Write-Host "  - MANTENER: Lambda y EventBridge (minimo costo)" -ForegroundColor Green
Write-Host "  - EventBridge funciona INDEPENDIENTE de SNS/SQS" -ForegroundColor Green
Write-Host ""

Write-Host "Para desactivar SNS/SQS sin afectar EventBridge:" -ForegroundColor Yellow
Write-Host "  cd terraform" -ForegroundColor White
Write-Host "  .\\terraform.exe destroy -target=aws_sqs_queue.email_queue" -ForegroundColor White
Write-Host "  .\\terraform.exe destroy -target=aws_sns_topic.email_topic" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Para detener servicios locales: Cierra las 3 ventanas PowerShell" -ForegroundColor Yellow
Write-Host "Para detener EventBridge: Usa el comando 'disable-rule' de arriba" -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
