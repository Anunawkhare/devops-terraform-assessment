# devops-terraform-assessment

## 📖 Overview

This repository contains a **complete DevOps assessment solution** demonstrating:

-  **Infrastructure as Code** using Terraform for AWS (VPC, ALB, ECS/Fargate, RDS)
-  **Multi-environment** Terraform structure (development & production)
-  **Local Database** setup using Docker Compose with PostgreSQL
-  **Database Migration** and **Seed Data** (100+ hotel bookings)
-  **Query Optimization** with proper indexing
-  **Automated Backup & Restore** scripts
-  **CI/CD Pipeline** using GitHub Actions for Terraform validation

> **Note:** Actual AWS deployment is not required. Terraform is validated through `fmt`, `init`, `validate`, and `plan` commands.

---

## 🛠️ Tech Stack

| **Category** | **Technologies** |
|--------------|------------------|
| **Infrastructure as Code** | Terraform, AWS |
| **Containerization** | Docker, Docker Compose |
| **Database** | PostgreSQL 15 |
| **CI/CD** | GitHub Actions |
| **Scripting** | Bash, Shell Scripting |
| **Version Control** | Git, GitHub |

---

## 📁 Project Structure

devops-terraform-assessment/
│
├── infra/ # Terraform Infrastructure
│ ├── modules/
│ │ ├── network/ # VPC, Subnets, Security Groups
│ │ │ ├── main.tf
│ │ │ ├── variables.tf
│ │ │ └── outputs.tf
│ │ ├── ecs/ # ECS Cluster, Service, ALB
│ │ │ ├── main.tf
│ │ │ └── variables.tf
│ │ └── rds/ # RDS PostgreSQL Instance
│ │ ├── main.tf
│ │ └── variables.tf
│ └── envs/
│ ├── dev/ # Development Environment
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── terraform.tfvars
│ └── prod/ # Production Environment
│ ├── main.tf
│ ├── variables.tf
│ └── terraform.tfvars
│
├── docker-compose/ # Docker Compose Configuration
│ └── docker-compose.yml
│
├── database/ # Database Scripts
│ ├── migrations/ # Schema Migration
│ │ └── 001_init.sql
│ ├── seed/ # Seed Data
│ │ └── seed.sql
│ ├── scripts/ # Backup & Restore
│ │ ├── backup.sh
│ │ └── restore.sh
│ └── backups/ # Backup Storage (auto-created)
│
├── .github/ # GitHub Actions
│ └── workflows/
│ └── terraform.yml
│
├── .gitignore
└── README.md

# Terraform Commands

# Navigate to environment
cd infra/envs/dev

# Initialize (skip backend for local validation)
terraform init -backend=false

# Format code
terraform fmt

# Validate configuration
terraform validate

# Generate execution plan
terraform plan -refresh=false

# Apply (if deploying to AWS)
terraform apply -auto-approve

# 🐳 Database Setup

# Start Database
cd docker-compose
docker compose up -d

# Verify Database is Running
docker ps
docker exec -it hotel_db psql -U admin -d hoteldb -c "\dt"


# Database Connection Details

Host	localhost
Port	5432
Database	hoteldb
Username	admin
Password	admin123

# PgAdmin Access
URL: http://localhost:5050
Email: admin@example.com
Password: admin


# 💾 Backup & Restore

# Backup Script
cd database/scripts
chmod +x backup.sh restore.sh  # Git Bash / WSL
./backup.sh


# Restore Script

# List available backups
ls -la ./database/backups/

# Restore latest backup
LATEST_BACKUP=$(ls -t ./database/backups/*.sql.gz | head -1)
./restore.sh $LATEST_BACKUP

# Restore specific backup
./restore.sh ./database/backups/hoteldb_20260707_184729.sql.gz


# Verify Restore
bash
# Count bookings
docker exec -it hotel_db psql -U admin -d hoteldb -c "SELECT COUNT(*) FROM hotel_bookings;"

# Sample data
docker exec -it hotel_db psql -U admin -d hoteldb -c "SELECT * FROM hotel_bookings LIMIT 5;"

# Query performance
docker exec -it hotel_db psql -U admin -d hoteldb -c "EXPLAIN ANALYZE SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' GROUP BY org_id, status;"





