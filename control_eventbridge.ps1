# Script de Control de EventBridge
# Permite activar/desactivar/verificar el sistema de envío automático de emails

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('activar', 'desactivar', 'estado', 'logs')]
    [string]$Accion = 'estado'
)

$ruleName = "crud-app-email-scheduler"
$region = "us-east-1"
$lambdaName = "crud-app-email-lambda"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   CONTROL EVENTBRIDGE - TAREA 3" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

switch ($Accion) {
    'activar' {
        Write-Host "🔄 Activando EventBridge..." -ForegroundColor Yellow
        aws events enable-rule --name $ruleName --region $region
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ EventBridge ACTIVADO" -ForegroundColor Green
            Write-Host "   - Los correos se enviarán cada 5 minutos" -ForegroundColor Gray
            Write-Host "   - Revisa los logs con: .\control_eventbridge.ps1 logs" -ForegroundColor Gray
        } else {
            Write-Host "❌ Error al activar EventBridge" -ForegroundColor Red
        }
    }
    
    'desactivar' {
        Write-Host "🛑 Desactivando EventBridge..." -ForegroundColor Yellow
        aws events disable-rule --name $ruleName --region $region
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ EventBridge DESACTIVADO" -ForegroundColor Green
            Write-Host "   - Los correos dejaron de enviarse" -ForegroundColor Gray
        } else {
            Write-Host "❌ Error al desactivar EventBridge" -ForegroundColor Red
        }
    }
    
    'estado' {
        Write-Host "📊 Consultando estado del sistema...`n" -ForegroundColor Yellow
        
        # Estado de EventBridge
        Write-Host "━━━ EventBridge Rule ━━━" -ForegroundColor Cyan
        $ruleInfo = aws events describe-rule --name $ruleName --region $region | ConvertFrom-Json
        
        $estado = $ruleInfo.State
        $color = if ($estado -eq "ENABLED") { "Green" } else { "Yellow" }
        
        Write-Host "  Estado: " -NoNewline
        Write-Host $estado -ForegroundColor $color
        Write-Host "  Schedule: $($ruleInfo.ScheduleExpression)" -ForegroundColor Gray
        Write-Host "  ARN: $($ruleInfo.Arn)" -ForegroundColor Gray
        
        # Estadísticas de SES
        Write-Host "`n━━━ Amazon SES Stats ━━━" -ForegroundColor Cyan
        $sesStats = aws sesv2 get-account --region $region | ConvertFrom-Json
        $quota = $sesStats.SendQuota
        
        Write-Host "  Enviados ultimas 24h: " -NoNewline
        Write-Host "$($quota.SentLast24Hours)" -ForegroundColor Green -NoNewline
        Write-Host " / $($quota.Max24HourSend)" -ForegroundColor Gray
        Write-Host "  Tasa máxima: $($quota.MaxSendRate) correos/segundo" -ForegroundColor Gray
        
        # Ultimas ejecuciones
        Write-Host "`n━━━ Ultimas 3 Ejecuciones ━━━" -ForegroundColor Cyan
        $logs = aws logs tail /aws/lambda/$lambdaName --since 30m --region $region --format short 2>$null
        
        if ($logs) {
            $successLogs = $logs | Select-String -Pattern 'Correo enviado correctamente' | Select-Object -Last 3
            if ($successLogs) {
                $successLogs | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
            } else {
                Write-Host "  No hay ejecuciones recientes en los ultimos 30 minutos" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  No se pudieron obtener los logs" -ForegroundColor Yellow
        }
        
        # Comandos útiles
        Write-Host "`n━━━ Comandos Disponibles ━━━" -ForegroundColor Cyan
        Write-Host '  Activar:     .\control_eventbridge.ps1 activar' -ForegroundColor White
        Write-Host '  Desactivar:  .\control_eventbridge.ps1 desactivar' -ForegroundColor White
        Write-Host '  Ver logs:    .\control_eventbridge.ps1 logs' -ForegroundColor White
        Write-Host '  Ver estado:  .\control_eventbridge.ps1 estado' -ForegroundColor White
    }
    
    'logs' {
        Write-Host "📋 Monitoreando logs en tiempo real..." -ForegroundColor Yellow
        Write-Host "   Presiona Ctrl+C para detener`n" -ForegroundColor Gray
        
        aws logs tail /aws/lambda/$lambdaName --follow --region $region --format short
    }
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
