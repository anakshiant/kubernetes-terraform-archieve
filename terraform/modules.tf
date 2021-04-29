module "project-backend" {
  source = "./backend"

  environment = var.environment
  image_tag   = var.image_tag

  environment_variables = var.environment_variables
}


