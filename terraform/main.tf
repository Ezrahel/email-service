terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket = "email-service-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# ── VPC ──────────────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-email-service-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "production"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Environment = var.environment, Service = "email-service" }
}

# ── ECS Cluster ──────────────────────────────────────────────
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-email-service"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Environment = var.environment, Service = "email-service" }
}

# ── RDS PostgreSQL ───────────────────────────────────────────
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.environment}-email-service-db"

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = true

  db_name  = "email_service"
  username = var.db_username
  password = random_password.db_password.result

  multi_az               = var.environment == "production"
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_window      = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"
  backup_retention_period = var.environment == "production" ? 30 : 7

  deletion_protection = var.environment == "production"

  tags = { Environment = var.environment, Service = "email-service" }
}

resource "random_password" "db_password" {
  length  = 32
  special = false
}

# ── ElastiCache Redis ────────────────────────────────────────
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.environment}-email-service-redis"
  description          = "Redis for Email Service"

  node_type            = var.redis_node_type
  num_cache_clusters   = var.environment == "production" ? 2 : 1
  port                 = 6379
  parameter_group_name = "default.redis7"
  engine               = "redis"
  engine_version       = "7.1"

  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  automatic_failover_enabled = var.environment == "production"
  multi_az_enabled           = var.environment == "production"

  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true

  tags = { Environment = var.environment, Service = "email-service" }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-email-service-redis-subnet"
  subnet_ids = module.vpc.private_subnets
}

# ── S3 ───────────────────────────────────────────────────────
resource "aws_s3_bucket" "storage" {
  bucket = "${var.environment}-email-service-storage"

  tags = { Environment = var.environment, Service = "email-service" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket_storage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "storage" {
  bucket = aws_s3_bucket_storage.bucket

  rule {
    id     = "expire-email-bodies"
    status = "Enabled"

    expiration {
      days = 365
    }

    filter {
      prefix = "emails/"
    }
  }
}

# ── Security Groups ──────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.environment}-email-service-rds"
  description = "RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.environment}-email-service-redis"
  description = "Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-email-service-ecs-tasks"
  description = "ECS tasks"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── IAM ──────────────────────────────────────────────────────
resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment}-email-service-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.environment}-email-service-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ecs_task" {
  name = "${var.environment}-email-service-ecs-task-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "ses:GetSendQuota"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.storage.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

# ── CloudWatch ───────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}-email-service"
  retention_in_days = 90
}
