resource "aws_ecr_repository" "ecr-app-repo" {
  name                 = local.ecr_app_repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr-nginx-repo" {
  name                 = local.ecr_nginx_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
