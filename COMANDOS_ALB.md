# Comandos para Manejar el ALB

## 📊 Ver Estado del ALB

```powershell
# Ver información del ALB
aws elbv2 describe-load-balancers --names crud-app-alb --region us-east-1

# Ver DNS del ALB
aws elbv2 describe-load-balancers --names crud-app-alb --query 'LoadBalancers[0].DNSName' --output text --region us-east-1

# Ver salud del Target Group
aws elbv2 describe-target-health --target-group-arn "arn:aws:elasticloadbalancing:us-east-1:717119779211:targetgroup/crud-app-lambda-bff-tg/5ce50a88d5443ede" --region us-east-1
```

## 🧪 Probar el ALB

```powershell
# Probar endpoint /health
curl http://crud-app-alb-465693216.us-east-1.elb.amazonaws.com/health

# Probar endpoint raíz
curl http://crud-app-alb-465693216.us-east-1.elb.amazonaws.com/

# Prueba de carga simple (100 requests)
1..100 | ForEach-Object { 
    curl http://crud-app-alb-465693216.us-east-1.elb.amazonaws.com/health -UseBasicParsing | Out-Null
    Write-Host "Request $_"
}
```

## 📈 Ver Métricas en CloudWatch

```powershell
# Métricas del ALB (últimos 5 minutos)
aws cloudwatch get-metric-statistics `
  --namespace AWS/ApplicationELB `
  --metric-name RequestCount `
  --dimensions Name=LoadBalancer,Value=app/crud-app-alb/af2f12ad1830f680 `
  --start-time (Get-Date).AddMinutes(-5).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") `
  --end-time (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") `
  --period 60 `
  --statistics Sum `
  --region us-east-1

# Invocaciones de Lambda
aws cloudwatch get-metric-statistics `
  --namespace AWS/Lambda `
  --metric-name Invocations `
  --dimensions Name=FunctionName,Value=crud-app-bff-lambda `
  --start-time (Get-Date).AddMinutes(-5).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") `
  --end-time (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") `
  --period 60 `
  --statistics Sum `
  --region us-east-1
```

## 🔧 Modificar el ALB con Terraform

```powershell
cd terraform

# Ver cambios pendientes
terraform plan

# Aplicar cambios
$env:TF_VAR_external_db_url="postgresql://postgres.rpigihssudwpgldcmtsi:TFxHHkw3hYn0l3qr@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
terraform apply -auto-approve

# Ver estado actual
terraform state list | Select-String "aws_lb"
terraform show aws_lb.main
```

## 🗑️ DESTRUIR el ALB (para detener costos)

```powershell
cd terraform

# Ver qué se va a destruir
terraform plan -destroy -target=aws_lb.main -target=aws_lb_listener.http

# Destruir SOLO el ALB (mantener todo lo demás)
$env:TF_VAR_external_db_url="postgresql://postgres.rpigihssudwpgldcmtsi:TFxHHkw3hYn0l3qr@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
terraform destroy -target=aws_lb.main -target=aws_lb_listener.http -auto-approve

# Destruir TODO (ALB + VPC + Lambdas + todo)
terraform destroy -auto-approve
```

## 💰 Calcular Costos

```powershell
# Ver tiempo activo y costo
$createdTime = [DateTime]::Parse("2025-11-03T05:37:14.546000+00:00")
$now = [DateTime]::UtcNow
$horasActivas = ($now - $createdTime).TotalHours
$costoHora = 0.0225
$costoTotal = [Math]::Round($horasActivas * $costoHora, 4)
Write-Host "Tiempo activo: $([Math]::Round($horasActivas, 2)) horas"
Write-Host "Costo acumulado: `$$costoTotal USD"
Write-Host "Costo por día: `$$([Math]::Round(24 * $costoHora, 2)) USD"
Write-Host "Costo por mes: `$$([Math]::Round(720 * $costoHora, 2)) USD"
```

## 🌐 Enlaces AWS Console

**Load Balancers:**
https://console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:

**Target Groups:**
https://console.aws.amazon.com/ec2/home?region=us-east-1#TargetGroups:

**CloudWatch Dashboard:**
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=crud-app-dashboard

**CloudWatch Alarmas:**
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarmsV2:

**Lambda Functions:**
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

## 📸 Screenshots para la Tarea

1. **Load Balancer activo**: EC2 → Load Balancers → crud-app-alb → Estado "active"
2. **Target Group healthy**: EC2 → Target Groups → crud-app-lambda-bff-tg → Targets tab → Estado "healthy"
3. **CloudWatch métricas**: CloudWatch → Dashboards → crud-app-dashboard → Ver gráficas
4. **Alarmas configuradas**: CloudWatch → Alarms → Ver las 5 alarmas
5. **Prueba funcionando**: Screenshot de `curl` exitoso con HTTP 200

## 🎯 Archivos Terraform del ALB

- **terraform/alb.tf** - Configuración del ALB y listener
- **terraform/networking.tf** - VPC, subnets, security groups
- **terraform/bff_lambda.tf** - Lambda que responde al ALB
- **terraform/autoscaling.tf** - Configuración de auto-scaling
- **terraform/monitoring.tf** - CloudWatch alarmas y dashboard
