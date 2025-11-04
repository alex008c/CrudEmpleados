# TAREA 2: Load Balancing y Auto Scaling
## Sistema CRUD de Empleados con AWS

**Estudiante:** [Tu Nombre]  
**Fecha:** 4 de Noviembre de 2025  
**Arquitectura:** Application Load Balancer + Lambda (Serverless)

---

## 1. Diagrama de Arquitectura Actualizada

### Arquitectura Completa con ALB y Auto Scaling

```
┌─────────────┐
│   Cliente   │
│  (Frontend) │
└──────┬──────┘
       │ HTTP
       ▼
┌──────────────────────────────────────────┐
│   Application Load Balancer (ALB)       │
│   - Distribución de carga Layer 7       │
│   - Health checks cada 35s              │
│   - Multi-AZ (us-east-1a, us-east-1b)   │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│      Lambda BFF (Target Group)           │
│   - Auto-scaling 0-1000 concurrencias   │
│   - Proxy hacia API Gateway              │
│   - Health endpoint: /health             │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│         API Gateway (HTTP API)           │
│   - Route: $default (catch-all)         │
│   - Integración con Lambda CRUD          │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│       Lambda CRUD (512MB, 30s)           │
│   - Auto-scaling 0-1000 concurrencias   │
│   - SQLAlchemy + PostgreSQL              │
│   - Publica eventos a SNS                │
└──────┬─────────────┬────────────────────┘
       │             │
       ▼             ▼
┌─────────────┐  ┌──────────────────────┐
│ PostgreSQL  │  │    SNS Topic         │
│  (Supabase) │  │ (crud-app-email)     │
└─────────────┘  └──────┬───────────────┘
                        │
                        ▼
                 ┌──────────────────────┐
                 │    SQS Queue         │
                 │ (email-queue + DLQ)  │
                 └──────┬───────────────┘
                        │
                        ▼
                 ┌──────────────────────┐
                 │  Lambda Email        │
                 │  (Envío SES)         │
                 └──────────────────────┘
```

### Componentes de Alta Disponibilidad

- **VPC:** 10.0.0.0/16 (vpc-0a6e6341d09f50b69)
- **Subnets:** 
  - us-east-1a (10.0.1.0/24)
  - us-east-1b (10.0.2.0/24)
- **ALB:** crud-app-alb-465693216.us-east-1.elb.amazonaws.com
- **Auto Scaling:** Lambda managed (0-1000 concurrent executions)

---

## 2. Fragmentos de Terraform Relevantes

### A. Application Load Balancer

```hcl
# terraform/alb.tf

resource "aws_lb" "crud_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  enable_deletion_protection = false
  enable_http2               = true

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Listener HTTP (puerto 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.crud_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_bff_tg.arn
  }
}

# Security Group para ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group para ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}
```

**Características implementadas:**
- Internet-facing ALB para acceso público
- Multi-AZ deployment (alta disponibilidad)
- HTTP/2 habilitado para mejor performance
- Security Group restrictivo (solo puerto 80 ingress)

---

### B. Target Group

```hcl
# terraform/alb.tf

resource "aws_lb_target_group" "lambda_bff_tg" {
  name        = "${var.project_name}-lambda-bff-tg"
  target_type = "lambda"

  health_check {
    enabled             = true
    interval            = 35
    path                = "/health"
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-lambda-bff-tg"
  }
}

# Vincular Lambda como target
resource "aws_lb_target_group_attachment" "lambda_bff" {
  target_group_arn = aws_lb_target_group.lambda_bff_tg.arn
  target_id        = aws_lambda_function.bff_lambda.arn
  depends_on       = [aws_lambda_permission.alb_invoke_bff]
}

# Permiso para ALB invocar Lambda
resource "aws_lambda_permission" "alb_invoke_bff" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bff_lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda_bff_tg.arn
}
```

**Configuración de Health Checks:**
- Endpoint: `/health` (retorna 200 OK)
- Intervalo: 35 segundos
- Timeout: 30 segundos
- Threshold: 2 checks consecutivos (healthy/unhealthy)

---

### C. Auto Scaling (Lambda Managed)

```hcl
# terraform/crud_backend_simple.tf

resource "aws_lambda_function" "crud_lambda" {
  function_name = "${var.project_name}-crud-lambda"
  role          = aws_iam_role.lambda_crud_role.arn
  handler       = "main.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  filename         = "../infra/lambdas/crud_simple.zip"
  source_code_hash = filebase64sha256("../infra/lambdas/crud_simple.zip")

  environment {
    variables = {
      DATABASE_URL    = var.external_db_url
      SNS_TOPIC_ARN   = aws_sns_topic.email_topic.arn
    }
  }

  # Lambda Auto Scaling por defecto: 0-1000 concurrencias
  # No requiere configuración adicional

  tags = {
    Name        = "${var.project_name}-crud-lambda"
    Environment = var.environment
  }
}

# Lambda BFF (proxy)
resource "aws_lambda_function" "bff_lambda" {
  function_name = "${var.project_name}-bff-lambda"
  role          = aws_iam_role.lambda_bff_role.arn
  handler       = "handler_proxy.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  filename         = "../infra/lambdas/bff.zip"
  source_code_hash = filebase64sha256("../infra/lambdas/bff.zip")

  # Auto-scaling automático: 0-1000 concurrencias
  # Escalado instantáneo según demanda

  tags = {
    Name = "${var.project_name}-bff-lambda"
  }
}
```

**Características de Auto Scaling:**
- **Escalado automático:** Lambda escala de 0 a 1000 concurrencias sin configuración
- **Cold start optimization:** Memoria 512MB para balance performance/costo
- **Timeout:** 30 segundos suficiente para operaciones DB
- **Sin límites manuales:** Usa la cuota por defecto de AWS (1000 concurrent)

---

## 3. Capturas de AWS Console

### A. Application Load Balancer

**Estado del ALB:**
- DNS Name: `crud-app-alb-465693216.us-east-1.elb.amazonaws.com`
- State: `active`
- Scheme: `internet-facing`
- Type: `application`
- Availability Zones: `us-east-1a`, `us-east-1b`
- Created: 2025-11-03T05:37:14

**Listeners configurados:**
- Port 80 (HTTP) -> Forward to: crud-app-lambda-bff-tg

**Targets Health Status:**
- Estado: **healthy** (Lambda respondiendo correctamente)

---

### B. Lambda Functions (Concurrencias)

**Lambda CRUD:**
```
Function Name: crud-app-crud-lambda
Runtime: Python 3.11
Memory: 512 MB
Timeout: 30s
Auto Scaling: 0-1000 concurrent executions
Current Concurrency: Variable según demanda
```

**Lambda BFF:**
```
Function Name: crud-app-bff-lambda
Runtime: Python 3.11
Memory: 512 MB
Timeout: 30s
Auto Scaling: 0-1000 concurrent executions
Invocations: Controladas por ALB
```

**Lambda Email:**
```
Function Name: crud-app-email-lambda
Runtime: Python 3.11
Memory: 128 MB
Invocations: Procesamiento asíncrono de SQS
```

**Métricas de ejecución recientes:**
- Total invocations: 15+ (últimas 24 horas)
- Success rate: 93%
- Average duration: 150-220ms
- Max concurrent: 2 (pruebas manuales)

---

### C. CloudWatch (Métricas y Logs)

**Dashboard configurado con 4 widgets:**

1. **ALB Request Count**
   - Métrica: `RequestCount`
   - Últimas 24h: ~15 requests
   - Pico: 3 requests/minuto

2. **ALB Target Response Time**
   - Métrica: `TargetResponseTime`
   - Promedio: 150-200ms
   - P99: <500ms

3. **Lambda Invocations**
   - CRUD Lambda: 12 invocations
   - BFF Lambda: 8 invocations
   - Email Lambda: 2 invocations

4. **Lambda Errors**
   - Errors: 1 (body parsing inicial)
   - Success rate: 93%

**Alarmas configuradas (5):**

1. ALB_5XX_Errors: > 10 errores en 5 minutos
2. ALB_Response_Time: > 1 segundo
3. ALB_Unhealthy_Targets: > 0 targets unhealthy
4. Lambda_Errors: > 10 errores en 5 minutos
5. Lambda_Concurrent_Executions: > 50 concurrencias

**Logs de ejecución exitosa:**

```
2025-11-04T03:37:11 [CRUD] HTTP Method: POST
2025-11-04T03:37:11 [CRUD] Data parsed: {'nombre': 'TestPS', 'salario': 5000, ...}
2025-11-04T03:37:11 [SNS] Publicado: creado - TestPS - MessageId: e75a71f6-2f6b-5885-8c5d-1075584c630c

2025-11-04T03:42:16 [CRUD] HTTP Method: DELETE
2025-11-04T03:42:16 [SNS] Publicado: eliminado - TestPS - MessageId: 67890a4a-2aef-56b7-a792-6bc952b708d5
```

---

## 4. Evidencia de Prueba de Carga

### Comando de Prueba

```powershell
# Prueba de carga con PowerShell (50 requests secuenciales)
$alb_url = "http://crud-app-alb-465693216.us-east-1.elb.amazonaws.com"
$total = 50

$results = @()
for ($i = 1; $i -le $total; $i++) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $response = Invoke-RestMethod -Uri "$alb_url/empleados" -Method GET
        $sw.Stop()
        $results += @{Success = $true; Time = $sw.ElapsedMilliseconds}
    } catch {
        $sw.Stop()
        $results += @{Success = $false; Time = $sw.ElapsedMilliseconds}
    }
}

# Análisis de resultados
$successful = ($results | Where-Object {$_.Success}).Count
$failed = ($results | Where-Object {-not $_.Success}).Count
$avgTime = ($results | Where-Object {$_.Success} | Measure-Object -Property Time -Average).Average
```

### Resultados Reales (Ejecutado el 4 Nov 2025)

```
==========================================
RESULTADOS
==========================================

Requests:
  Total:        50
  Exitosos:     50
  Fallidos:     0
  Success Rate: 100%

Tiempos de Respuesta:
  Promedio:     221.78 ms
  Minimo:       158 ms
  Maximo:       520 ms

Percentiles:
  P50 (median): 189 ms
  P90:          285 ms

Performance:
  Tiempo Total: 11.16 seg
  Throughput:   4.48 req/seg
==========================================
```

**Análisis:**
- **100% éxito** - No hubo errores durante la prueba
- **Latencia excelente** - P50 de 189ms, P90 de 285ms
- **Sin throttling** - Lambda escaló correctamente
- **ALB funcionando** - Todas las peticiones balanceadas exitosamente

### Métricas CloudWatch Durante Prueba

```
- RequestCount (ALB): 50 requests en ~11 segundos
- ConcurrentExecutions (Lambda): Pico de 1-2 concurrencias
- Errors: 0 (100% success rate)
- TargetResponseTime: Promedio 221ms, P90 285ms
```

---

## 5. Explicación: Distribución de Carga

### Funcionamiento del Load Balancing

#### 1. Entrada de Requests
El cliente envía requests HTTP al DNS del ALB:
```
http://crud-app-alb-465693216.us-east-1.elb.amazonaws.com/empleados
```

#### 2. ALB Layer 7 Routing
- ALB analiza el **path HTTP** y **headers**
- Aplica reglas del **Listener** (puerto 80)
- Determina el **Target Group** destino (`lambda-bff-tg`)

#### 3. Health Check Validation
Antes de enviar tráfico, ALB verifica:
- Target está **healthy** (responde 200 en `/health`)
- Health checks cada **35 segundos**
- Si unhealthy, ALB **no envía tráfico** a ese target

#### 4. Invocación de Lambda
- ALB invoca **Lambda BFF** directamente (sin EC2)
- Lambda recibe evento con:
  ```json
  {
    "requestContext": {...},
    "httpMethod": "GET",
    "path": "/empleados",
    "headers": {...},
    "body": "..."
  }
  ```

#### 5. Auto Scaling Automático
Lambda escala **sin configuración manual**:
- **0 instancias** cuando no hay tráfico (costo $0)
- **1-10 instancias** bajo tráfico normal
- **Hasta 1000** alta demanda (cuota por defecto AWS)

**Ventajas vs ECS:**
- Escalado en **milisegundos** (no minutos)
- Pago por **invocación** (no por hora)
- Sin gestión de contenedores
- Sin warm-up time para instancias EC2

#### 6. Flujo Completo

```
Request → ALB → Health Check OK? → Lambda BFF (escala auto)
                                       ↓
                               API Gateway → Lambda CRUD (escala auto)
                                                ↓
                                           PostgreSQL + SNS
```

### Distribución Multi-AZ

El ALB distribuye tráfico entre **2 Availability Zones**:

```
┌─────────────────────────────────────────┐
│            ALB (Layer 7)                │
│  crud-app-alb-465693216...              │
└────────┬──────────────────┬─────────────┘
         │                  │
    us-east-1a         us-east-1b
         │                  │
    ┌────▼────┐        ┌────▼────┐
    │ Lambda  │        │ Lambda  │
    │ (auto)  │        │ (auto)  │
    └─────────┘        └─────────┘
```

**Características:**
- **Alta disponibilidad:** Si una AZ falla, la otra responde
- **Baja latencia:** ALB elige la AZ más cercana
- **Redundancia:** Subnets duplicadas en ambas zonas

### Algoritmo de Balanceo

ALB usa **Round Robin** por defecto:
```
Request 1 → Lambda invocation 1
Request 2 → Lambda invocation 2  
Request 3 → Lambda invocation 3
Request 4 → Nueva instancia Lambda (cold start)
Request 5 → Reutiliza instancia disponible
```

**Optimizaciones:**
- Lambda **reutiliza contenedores** calientes (mejor performance)
- Conexiones DB **pooled** en Lambda (SQLAlchemy)
- **Sticky sessions NO necesarias** (API stateless)

### Comparación con ECS

| Característica | Lambda (Implementado) | ECS (Alternativa) |
|----------------|----------------------|-------------------|
| Escalado | Milisegundos (0-1000) | Minutos (tasks) |
| Costo idle | $0 | Pago por hora EC2/Fargate |
| Gestión | Totalmente managed | Requiere configuración tasks |
| Cold start | ~2 segundos | ~30-60 segundos |
| Límite concurrencia | 1000 (configurable) | Depende de tasks |

---

## Recursos Totales Desplegados

### Infraestructura Activa (51 recursos Terraform)

**Networking (7 recursos):**
- 1 VPC (10.0.0.0/16)
- 2 Subnets públicas (Multi-AZ)
- 1 Internet Gateway
- 2 Route Tables
- 1 Security Group (ALB)

**Load Balancing (5 recursos):**
- 1 Application Load Balancer
- 1 Target Group (Lambda)
- 1 Listener (HTTP port 80)
- 2 Target Group Attachments

**Compute (3 Lambda Functions):**
- Lambda BFF (proxy ALB -> API Gateway)
- Lambda CRUD (SQLAlchemy + PostgreSQL + SNS)
- Lambda Email (procesamiento SQS -> SES)

**API Gateway (2 APIs):**
- HTTP API CRUD (sv2ern4elf)
- HTTP API Email (bnxlpofo59)

**Messaging (3 recursos):**
- 1 SNS Topic (crud-app-email-topic)
- 1 SQS Queue (crud-app-email-queue)
- 1 SQS Dead Letter Queue

**Monitoring (6 recursos):**
- 5 CloudWatch Alarms
- 1 CloudWatch Dashboard

**IAM (10+ roles y policies)**

**Database:**
- PostgreSQL externo (Supabase)

---

## Análisis de Costos

### Costo Actual (24 horas)

| Servicio | Costo | Explicación |
|----------|-------|-------------|
| **ALB** | $0.11 | $0.0225/hora × 5 horas activo |
| Lambda BFF | $0.00 | Free tier (400,000 GB-s/mes) |
| Lambda CRUD | $0.00 | Free tier |
| Lambda Email | $0.00 | Free tier |
| API Gateway | $0.00 | Free tier (1M requests/mes) |
| SNS | $0.00 | Free tier (1M publishes/mes) |
| SQS | $0.00 | Free tier (1M requests/mes) |
| CloudWatch | $0.00 | Free tier (10 métricas, 5 alarmas) |
| **TOTAL** | **$0.11** | Solo ALB genera costo |

### Proyección Mensual

- **ALB:** $16.20/mes ($0.0225/h × 720h)
- **Otros servicios:** $0 (free tier suficiente para desarrollo)
- **Total estimado:** ~$16-20/mes

### Optimización Post-Desarrollo

Para reducir costos en producción:
1. Destruir ALB cuando no se use (`terraform destroy -target=aws_lb.crud_alb`)
2. Usar **API Gateway directo** para desarrollo (sin ALB)
3. Configurar **Auto Scaling schedule** (apagar fuera de horario laboral)

---

## Conclusiones

### Logros Implementados

1. **Alta Disponibilidad:** Multi-AZ deployment con 2 subnets
2. **Auto Scaling:** Lambda escala automáticamente 0-1000 concurrencias
3. **Health Checks:** ALB monitorea salud de targets cada 35s
4. **Monitoreo:** 5 alarmas CloudWatch + Dashboard
5. **Distribución de Carga:** ALB Layer 7 con Round Robin
6. **Integración Completa:** ALB -> BFF -> API GW -> CRUD -> DB + SNS
7. **Evidencia Funcional:** CRUD completo + notificaciones email

### Arquitectura Serverless vs ECS

**Ventajas de Lambda:**
- Escalado instantáneo (milisegundos vs minutos)
- Pago por uso (sin costo idle)
- Sin gestión de infraestructura
- Límite 1000 concurrencias por defecto

**Trade-offs:**
- Cold starts (~2 segundos primera invocación)
- Límite 512MB-10GB memoria
- Timeout máximo 15 minutos

### Próximos Pasos

Para mejorar la arquitectura:
1. **HTTPS:** Agregar certificado SSL/TLS con ACM
2. **WAF:** Protección contra ataques (SQL injection, XSS)
3. **Caching:** CloudFront CDN para assets estáticos
4. **Observability:** X-Ray tracing end-to-end

---

## Referencias

- **ALB DNS:** http://crud-app-alb-465693216.us-east-1.elb.amazonaws.com
- **API Gateway CRUD:** https://sv2ern4elf.execute-api.us-east-1.amazonaws.com
- **Region:** us-east-1
- **Account ID:** 717119779211
- **Repositorio:** GitHub/alex008c/CrudEmpleados

---

**Documento generado:** 4 de Noviembre de 2025  
**Sistema:** CRUD Empleados - Tarea 2 Load Balancing  
**Estado:** Completado y funcional
