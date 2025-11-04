# ========================================
# CLOUDWATCH MONITORING PARA ALB
# ========================================
# Métricas y alarmas para monitorear el Application Load Balancer

# 1. Alarma - Errores 5XX del ALB
# Se dispara si hay más de 10 errores 5XX en 5 minutos
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300  # 5 minutos
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alerta cuando hay más de 10 errores 5XX en el ALB"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${var.project_name}-alb-5xx-alarm"
  }
}

# 2. Alarma - Alto tiempo de respuesta
# Se dispara si el tiempo de respuesta promedio supera 1 segundo
resource "aws_cloudwatch_metric_alarm" "alb_high_response_time" {
  alarm_name          = "${var.project_name}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2  # 2 períodos consecutivos
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60  # 1 minuto
  statistic           = "Average"
  threshold           = 1.0  # 1 segundo
  alarm_description   = "Alerta cuando el tiempo de respuesta promedio supera 1 segundo"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${var.project_name}-alb-response-time-alarm"
  }
}

# 3. Alarma - Targets no saludables
# Se dispara si algún target está unhealthy
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${var.project_name}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0  # Cualquier target no saludable
  alarm_description   = "Alerta cuando hay targets no saludables en el ALB"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.lambda_bff.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${var.project_name}-alb-unhealthy-alarm"
  }
}

# 4. Dashboard de CloudWatch
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum", label = "Total Requests" }],
            [".", "HTTPCode_Target_2XX_Count", { stat = "Sum", label = "2XX Responses" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum", label = "5XX Errors" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB - Request Metrics"
          period  = 60
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average", label = "Avg Response Time" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "ALB - Response Time"
          period = 60
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Lambda Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Lambda Errors" }],
            [".", "Duration", { stat = "Average", label = "Avg Duration (ms)" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Lambda - Performance Metrics"
          period = 60
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "ProvisionedConcurrencyUtilization", { stat = "Average", label = "Concurrency Utilization" }],
            [".", "ProvisionedConcurrentExecutions", { stat = "Average", label = "Provisioned Concurrent Executions" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Lambda - Auto Scaling Metrics"
          period = 60
        }
      }
    ]
  })
}

# 5. Outputs
output "cloudwatch_dashboard_url" {
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
  description = "URL del dashboard de CloudWatch"
}

output "alb_metrics" {
  value = {
    request_count_metric   = "AWS/ApplicationELB:RequestCount"
    response_time_metric   = "AWS/ApplicationELB:TargetResponseTime"
    error_5xx_metric       = "AWS/ApplicationELB:HTTPCode_Target_5XX_Count"
    healthy_targets_metric = "AWS/ApplicationELB:HealthyHostCount"
  }
  description = "Nombres de las métricas del ALB en CloudWatch"
}
