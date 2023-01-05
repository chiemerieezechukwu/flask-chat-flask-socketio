variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "suffix" {
  type    = string
  default = "flask-chatrrr"
}

variable "db_username" {
  type    = string
  default = "flask_db"
}

variable "db_name" {
  type    = string
  default = "webproddatabase"
}

variable "image_tag" {
  description = "Corresponds to a git tag."
  default     = "latest"
}

output "app_repository_name" {
  value     = aws_ecr_repository.ecr-app-repo.name
  sensitive = true
}

output "nginx_repository_name" {
  value     = aws_ecr_repository.ecr-nginx-repo.name
  sensitive = true
}
