resource "aws_sns_topic" "email_topic" {
  name = "${var.project_name}-email-topic"

  tags = {
    Name        = "${var.project_name}-email-topic"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "email_dlq" {
  name                       = "${var.project_name}-email-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 300

  tags = {
    Name        = "${var.project_name}-email-dlq"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "email_queue" {
  name                       = "${var.project_name}-email-queue"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.email_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.project_name}-email-queue"
    Environment = var.environment
  }
}

resource "aws_sqs_queue_policy" "email_queue_policy" {
  queue_url = aws_sqs_queue.email_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.email_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.email_topic.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email_sqs_subscription" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.email_queue.arn

  depends_on = [aws_sqs_queue_policy.email_queue_policy]
}

resource "aws_iam_role" "email_lambda_role" {
  name = "${var.project_name}-email-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-email-lambda-role"
  }
}

resource "aws_iam_policy" "email_lambda_policy" {
  name = "${var.project_name}-email-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-email-lambda:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.email_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.email_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "email_lambda_policy_attach" {
  role       = aws_iam_role.email_lambda_role.name
  policy_arn = aws_iam_policy.email_lambda_policy.arn
}

data "archive_file" "email_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../infra/lambdas/email_lambda"
  output_path = "${path.module}/../infra/lambdas/email_lambda.zip"
}

resource "aws_lambda_function" "email_lambda" {
  filename         = data.archive_file.email_lambda_zip.output_path
  function_name    = "${var.project_name}-email-lambda"
  role             = aws_iam_role.email_lambda_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.email_lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name = "${var.project_name}-email-lambda"
  }
}

resource "aws_lambda_event_source_mapping" "email_sqs_trigger" {
  event_source_arn = aws_sqs_queue.email_queue.arn
  function_name    = aws_lambda_function.email_lambda.arn
  batch_size       = 10
  enabled          = true
}

resource "aws_cloudwatch_log_group" "email_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-email-lambda"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-email-lambda-logs"
  }
}
