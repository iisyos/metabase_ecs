
locals {
  load_balancer = ["${aws_lb_target_group.main.arn}"]
}

resource "aws_ecs_cluster" "main" {
  name = "metabase"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "main" {
  family = "metabase"

  requires_compatibilities = ["FARGATE"]

  cpu    = "512"
  memory = "1024"

  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.metabase.arn

  container_definitions = <<EOL
[
  {
    "name": "metabase",
    "image": "metabase/metabase:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "metabase",
        "awslogs-group": "${aws_cloudwatch_log_group.metabase.name}"
      }
    },
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
EOL
}

resource "aws_security_group" "ecs" {
  name        = "metabase-ecs"
  description = "metabase ecs"

  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "metabase-ecs"
  }
}

resource "aws_security_group_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  source_security_group_id = aws_security_group.alb.id
}

resource "aws_ecs_service" "main" {
  name = "metabase"

  depends_on = ["aws_lb_listener_rule.main"]

  cluster = aws_ecs_cluster.main.name

  launch_type = "FARGATE"

  desired_count = "1"

  task_definition = aws_ecs_task_definition.main.arn

  network_configuration {
    assign_public_ip = true
    subnets          = ["${aws_subnet.public_a.id}", "${aws_subnet.public_c.id}"]
    security_groups  = ["${aws_security_group.ecs.id}"]
  }

  dynamic "load_balancer" {
    for_each = local.load_balancer
    content {
      target_group_arn = load_balancer.value
      container_name   = "metabase"
      container_port   = 3000
    }
  }
}
