resource "aws_cloudwatch_log_group" "log_group" {
  name              = "project-push-log-group"
  retention_in_days = 30

  tags = {
    Name        = "project-push-log-group"
    Environment = var.environment
    Creator     = "Terraform"
  }
}