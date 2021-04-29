resource "aws_ecs_cluster" "project_push_cluster" {
  name = "project-push-cluster"

  tags = {
      Name        = "project-push-server"
      Environment = var.environment
      Creator     = "Terraform"
  }
}

data "template_file" "environment_variable" {
  template  = file("${path.module}/../templates/environment_variable.tpl.json")
  for_each  = var.environment_variables
  vars      = {
    name    = each.key
    value   = each.value
  }
}

resource "aws_ecs_task_definition" "project_push_task" {
  family                   = "project_push_task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "project_push_task",
      "image": "${data.aws_ecr_repository.project_push_server.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "project-push-log-group",
          "awslogs-region": "ap-south-1",
          "awslogs-stream-prefix": "ecs"
        }
    },
      "environment":[${join(",", [for i in data.template_file.environment_variable: i.rendered])}],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  tags = {
      Name        = "project-push-server"
      Environment = var.environment
      Creator     = "Terraform"
  }
}

resource "aws_ecs_service" "my_first_service" {
  name            = "project-push-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.project_push_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.project_push_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers we want deployed to 3
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.project_push_target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.project_push_task.family}"
    container_port   = 5000 # Specifying the container port
  }
  
  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
  tags = {
      Name        = "project-push-server"
      Environment = var.environment
      Creator     = "Terraform"
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}


resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
  tags = {
      Name        = "project-push-server"
      Environment = var.environment
      Creator     = "Terraform"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}