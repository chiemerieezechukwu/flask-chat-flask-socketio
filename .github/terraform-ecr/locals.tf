locals {
  ecr_app_repository_name   = "${terraform.workspace}-${var.suffix}-app-ecr-repo"
  ecr_nginx_repository_name = "${terraform.workspace}-${var.suffix}-nginx-ecr-repo"
}