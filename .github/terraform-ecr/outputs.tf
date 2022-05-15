output "app_repository_name" {
  value     = aws_ecr_repository.ecr-app-repo.name
  sensitive = true
}

output "nginx_repository_name" {
  value     = aws_ecr_repository.ecr-nginx-repo.name
  sensitive = true
}
