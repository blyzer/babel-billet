provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "172.20.0.0/16"
  tags = {
    Name = "${var.environment_name}-vault-${var.environment}"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.20.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.environment_name}-public-subnet-${var.environment}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.20.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${var.environment_name}-public-subnet-2-${var.environment}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.environment_name}-io-${var.environment}"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment_name}-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group para ECS
resource "aws_security_group" "web_sg" {
  name        = "${var.environment_name}-sg-${var.environment}"
  description = "SG para ECS services"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-sg-${var.environment}"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.environment_name}-cluster-${var.environment}"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.environment_name}-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.environment == "dev" ? aws_iam_role.ecs_task_execution_role_dev.arn : (var.environment == "staging" ? aws_iam_role.ecs_task_execution_role_staging.arn : aws_iam_role.ecs_task_execution_role_production.arn)

  container_definitions = jsonencode([{
    name      = "${var.environment_name}-container-${var.environment}"
    image     = "${var.docker_image}:${var.environment}-latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    environment = [
      {
        name  = "DB_HOST"
        value = aws_db_instance.default.endpoint
      },
      {
        name  = "DB_USER"
        value = "admin"
      },
      {
        name  = "DB_PASSWORD"
        value = aws_secretsmanager_secret_version.db_secret.secret_string
      },
      {
        name  = "NODE_ENV"
        value = var.environment
      }
    ]
  }])
}

# ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "${var.environment_name}-web-${var.environment}"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.environment == "1" ? 2 : 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.web_sg.id]
    assign_public_ip = true
  }
}

# IAM Roles for ECS Task Execution (Dev)
resource "aws_iam_role" "ecs_task_execution_role_dev" {
  name = "${var.environment_name}-ecs-task-execution-role-dev"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_dev" {
  role       = aws_iam_role.ecs_task_execution_role_dev.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Roles for ECS Task Execution (Staging)
resource "aws_iam_role" "ecs_task_execution_role_staging" {
  name = "${var.environment_name}-ecs-task-execution-role-staging"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_staging" {
  role       = aws_iam_role.ecs_task_execution_role_staging.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Roles for ECS Task Execution (Production)
resource "aws_iam_role" "ecs_task_execution_role_production" {
  name = "${var.environment_name}-ecs-task-execution-role-production"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_production" {
  role       = aws_iam_role.ecs_task_execution_role_production.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for ECS Task Execution to access Secrets Manager
resource "aws_iam_role_policy" "ecs_task_secrets_policy" {
  name = "${var.environment_name}-ecs-task-secrets-policy-${var.environment}"
  role = var.environment == "dev" ? aws_iam_role.ecs_task_execution_role_dev.id : (var.environment == "staging" ? aws_iam_role.ecs_task_execution_role_staging.id : aws_iam_role.ecs_task_execution_role_production.id)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.db_secret.arn
      }
    ]
  })
}

# IAM Role for GitHub Actions to assume (Dev)
resource "aws_iam_role" "github_actions_role_dev" {
  name = "${var.environment_name}-github-actions-role-dev"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:ref:refs/heads/develop"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_policy_dev" {
  name = "${var.environment_name}-github-actions-policy-dev"
  role = aws_iam_role.github_actions_role_dev.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters"
        ]
        Resource = [
          aws_ecs_cluster.app_cluster.arn,
          aws_ecs_service.app_service.id
        ]
      }
    ]
  })
}

# IAM Role for GitHub Actions to assume (Staging)
resource "aws_iam_role" "github_actions_role_staging" {
  name = "${var.environment_name}-github-actions-role-staging"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_policy_staging" {
  name = "${var.environment_name}-github-actions-policy-staging"
  role = aws_iam_role.github_actions_role_staging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters"
        ]
        Resource = [
          aws_ecs_cluster.app_cluster.arn,
          aws_ecs_service.app_service.id
        ]
      }
    ]
  })
}

# IAM Role for GitHub Actions to assume (Production)
resource "aws_iam_role" "github_actions_role_production" {
  name = "${var.environment_name}-github-actions-role-production"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:ref:refs/heads/release/*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_policy_production" {
  name = "${var.environment_name}-github-actions-policy-production"
  role = aws_iam_role.github_actions_role_production.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters"
        ]
        Resource = [
          aws_ecs_cluster.app_cluster.arn,
          aws_ecs_service.app_service.id
        ]
      }
    ]
  })
}

# RDS
resource "aws_db_instance" "default" {
  engine               = "mysql"
  instance_class       = var.environment == "production" ? "db.t3.medium" : "db.t3.micro"
  allocated_storage    = 20
  db_name              = "db${substr(replace(lower(var.environment_name), "-", ""), 0, 10)}"
  identifier           = "${replace(var.environment_name, "-", "")}-${var.environment}"
  username             = "admin"
  password             = aws_secretsmanager_secret_version.db_secret.secret_string
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = var.environment != "production"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  multi_az             = var.environment == "production" ? true : false
}

# Subnet group para RDS
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.environment_name}-db-subnet-group-${var.environment}"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "${var.environment_name}-db-subnet-group-${var.environment}"
  }
}

# AWS Secrets Manager para DB Password
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "${var.environment_name}-db-password-${var.environment}-v2"
  recovery_window_in_days = 7 # Reduced recovery window for testing
}

resource "aws_secretsmanager_secret_version" "db_secret" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = var.db_password
}