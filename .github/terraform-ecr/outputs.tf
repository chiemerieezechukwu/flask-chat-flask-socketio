output "app_repository_name" {
  value = aws_ecr_repository.ecr-app-repo.name
}

output "nginx_repository_name" {
  value = aws_ecr_repository.ecr-nginx-repo.name
}