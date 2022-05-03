locals {
  ecr_app_repository_name   = "${terraform.workspace}-${var.suffix}-app-ecr-repo"
  ecr_nginx_repository_name = "${terraform.workspace}-${var.suffix}-nginx-ecr-repo"
  ecs_cluster_name          = "${terraform.workspace}-${var.suffix}-ecs-cluster"
  ecs_task_name             = "${terraform.workspace}-${var.suffix}-ecs-task"
  ecs_task_role             = "${terraform.workspace}-${var.suffix}-ecs-task-role"
  app_container_name        = "${terraform.workspace}-${var.suffix}-app-container"
  nginx_container_name      = "${terraform.workspace}-${var.suffix}-nginx-container"
  web_prod_log_group_name   = "${terraform.workspace}-${var.suffix}-web-prod-log-group"
  ecs_service_name          = "${terraform.workspace}-${var.suffix}-ecs-service"
}
