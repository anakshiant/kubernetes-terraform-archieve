module "littra-push-backend" {
  source = "./littra-push-backend"

  environment = var.environment
  image_tag   = var.image_tag

  environment_variables = var.environment_variables
}


