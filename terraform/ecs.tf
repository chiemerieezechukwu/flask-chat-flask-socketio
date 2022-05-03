resource "aws_ecr_repository" "web-prod-ecr-app-repo" {
  name                 = local.ecr_app_repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "web-prod-ecr-nginx-repo" {
  name                 = local.ecr_nginx_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "random_string" "SECRET_KEY" {
  length  = 128
  special = false
}

resource "aws_ecs_cluster" "web-prod-ecs-cluster" {
  name = local.ecs_cluster_name
}

resource "aws_cloudwatch_log_group" "web-prod-log-group" {
  name = local.web_prod_log_group_name
}

resource "aws_ecs_task_definition" "web-prod-task-definition" {
  family                   = local.ecs_task_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.web-prod-ecs-iam-role.arn
  container_definitions = jsonencode([
    {
      "name" : local.app_container_name,
      "image" : "${aws_ecr_repository.web-prod-ecr-app-repo.repository_url}:${var.image_tag}",
      "cpu" : 256,
      "memory" : 512,
      "essential" : true,
      "environment" : [
        {
          "name" : "MEDIUM_CONTAINER",
          "value" : "true"
        },
        {
          "name" : "POSTGRES_HOST",
          "value" : aws_db_instance.web-prod-db.address
        },
        {
          "name" : "POSTGRES_PORT",
          "value" : tostring(aws_db_instance.web-prod-db.port)
        },
        {
          "name" : "DATABASE_URL",
          "value" : "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.web-prod-db.endpoint}/${var.db_name}"
        },
        {
          "name" : "SECRET_KEY",
          "valueFrom" : random_string.SECRET_KEY.result
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.web-prod-log-group.name,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : "ecs"
        }
      },
      "portMappings" : [
        {
          "containerPort" : 5000
        }
      ],
      "mountPoints" : [
        {
          "sourceVolume" : "static_volume",
          "containerPath" : "/home/app/web/chezchat/static",
        }
      ]
    },
    {
      "name" : local.nginx_container_name,
      "image" : "${aws_ecr_repository.web-prod-ecr-nginx-repo.repository_url}:latest",
      "cpu" : 256,
      "memory" : 512,
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.web-prod-log-group.name,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : "ecs"
        }
      },
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        }
      ],
      "mountPoints" : [
        {
          "sourceVolume" : "static_volume",
          "containerPath" : "/home/app/web/chezchat/static"
        }
      ],
      "dependsOn" : [
        {
          "containerName" : local.app_container_name,
          "condition" : "START"
        }
      ]
    }
  ])

  volume {
    name = "static_volume"
  }
}

resource "aws_ecs_service" "web-prod-ecs-service" {
  name                               = local.ecs_service_name
  cluster                            = aws_ecs_cluster.web-prod-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.web-prod-task-definition.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  launch_type                        = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.web-prod-subnet-private-1.id]
    security_groups  = [aws_security_group.web-prod-ecs-sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web-prod-lb-tg.arn
    container_name   = local.nginx_container_name
    container_port   = 80
  }
}
