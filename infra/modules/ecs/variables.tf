variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
  default     = "nginx:alpine"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Host port"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
}

variable "cpu" {
  description = "CPU units"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ALB security group ID"
  type        = string
}

variable "ecs_sg_id" {
  description = "ECS security group ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}