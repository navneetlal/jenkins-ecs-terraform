resource "aws_ecs_cluster" "jenkins_ecs" {
  name = var.cluster_name
  # capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name] // NA
}

// Not required
# resource "aws_ecs_capacity_provider" "ecs_cp" {
#   name = "capacity-provider-test"
#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
#     managed_termination_protection = "ENABLED"

#     managed_scaling {
#       status          = "ENABLED"
#       target_capacity = 85
#     }
#   }
# }

resource "aws_ecs_task_definition" "jenkins_task_definition" {
  family                   = "jenkins-task-definition"
  task_role_arn            = aws_iam_role.jenkins_role.arn           // execution role 
  execution_role_arn       = aws_iam_role.jenkins_execution_role.arn // execution role
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "jenkins"
      image     = "tkgregory/jenkins-ecs-agents:latest"
      # cpu       = 10 // NA
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        },
        {
          containerPort = var.jnlp_port
          hostPort      = var.jnlp_port
          protocol      = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "jenkins-home"
          containerPath = "/var/jenkins_home"
        }
      ]
    }
  ])

  volume {
    name = "jenkins-home"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.jenkins_efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.jenkins_efs_ap.id
        iam             = "DISABLED" // Disabled
      }
    }
  }
}

resource "aws_ecs_service" "jenkins_ecs_service" {
  name                               = "jenkins_ecs_service"
  cluster                            = aws_ecs_cluster.jenkins_ecs.id
  task_definition                    = aws_ecs_task_definition.jenkins_task_definition.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"

  // NA
  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "jenkins"
    container_port   = 8080
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.jenkins_sg.id]
    subnets          = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.jenkins_discovery_svc.arn
    # port         = var.jnlp_port // Need attention
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_service_discovery_private_dns_namespace" "jenkins_dns" {
  name = "jenkins.intugine.local"
  vpc  = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "jenkins_discovery_svc" {
  name = "jenkins"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.jenkins_dns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 60
      type = "A"
    }
  }
}
