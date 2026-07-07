terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "devops-terraform-database" # ← New bucket name
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name       = var.environment
  container_port     = 80
  host_port          = 80
  container_image    = "nginx:alpine"
  desired_count      = var.desired_count
  cpu                = var.ecs_cpu
  memory             = var.ecs_memory
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.network.alb_sg_id
  ecs_sg_id          = module.network.ecs_sg_id
  environment        = var.environment
}

module "rds" {
  source = "../../modules/rds"

  engine                = "postgres"
  engine_version        = "15"
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  storage_encrypted     = true
  db_name               = "hoteldb"
  username              = var.db_username
  password              = var.db_password
  backup_retention_days = var.db_backup_retention
  deletion_protection   = var.db_deletion_protection
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_sg_id             = module.network.ecs_sg_id
  environment           = var.environment
}