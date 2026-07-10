terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}



# Create a VPC
module "vpc" {
  source         = "../../modules/vpc"
  vpc-name       = "Cinema-VPC"
  vpc_cidr_block = "20.0.0.0/16"

  public-subnet-01-name        = "Cinema-public-subnet-01"
  public-subnet-01-cidr-block  = "20.0.1.0/24"
  private-subnet-01-name       = "Cinema-private-subnet-01"
  private-subnet-01-cidr-block = "20.0.5.0/24"
  availability-zone-01         = "eu-north-1a"

  public-subnet-02-name        = "Cinema-public-subnet-02"
  public-subnet-02-cidr-block  = "20.0.2.0/24"
  private-subnet-02-name       = "Cinema-private-subnet-02"
  private-subnet-02-cidr-block = "20.0.6.0/24"
  availability-zone-02         = "eu-north-1b"
}

# Create a security group
module "sg-for-ecs" {
  source = "../../modules/sec_grp"
  sg-name = "Cinema-sg"
  vpc-id = module.vpc.vpc-id  
}

# Create an ECR repository
module "ecr-for-frontend" {
  source               = "../../modules/ecr"
  repository_name      = "cinema_frontend"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

module "ecr-for-gateway" {
  source               = "../../modules/ecr"
  repository_name      = "cinema_gateway"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

module "ecr-for-catalog-service" {
  source               = "../../modules/ecr"
  repository_name      = "cinema_catalog_service"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

module "ecr-for-user-service" {
  source               = "../../modules/ecr"
  repository_name      = "cinema_user_service"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

module "ecr-for-testing-puprose" {
  source               = "../../modules/ecr"
  repository_name      = "test-repo"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}



# Create an ECS Cluster
module "ecs-cluster" {
  source = "../../modules/ecs_cluster"
  ecs-cluster-name = "Cinema-Cluster"
}






# Create an ECS Task Definition and Service for FRONTEND
module "frontend-service" {
  source = "../../modules/ecs"
  ecs-task-family-name = "Cinema-frontend"
  cpu-size = "256"
  memory-size = "512"
  container-port = 5173

  ecs-service-name = "Cinema-frontend-service"
  ecs-cluster-id = module.ecs-cluster.cluster-id
  desired-count = 1
  public-subnet-01-id = module.vpc.public-subnet-01-id
  public-subnet-02-id = module.vpc.public-subnet-02-id
  security-group-id = module.sg-for-ecs.security-group-id
}