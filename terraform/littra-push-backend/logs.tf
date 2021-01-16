resource "aws_cloudwatch_log_group" "log_group" {
  name              = "littra-push-log-group"
  retention_in_days = 30

  tags = {
    Name        = "littra-push-log-group"
    Environment = var.environment
    Creator     = "Terraform"
  }
}