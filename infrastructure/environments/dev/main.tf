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



# Create a security group for the ALB
module "alb-sg" {
  source = "../../modules/alb_sec_grp"
  sg-name = "Cinema-alb-sg"
  vpc-id = module.vpc.vpc-id
  alb-port = 80
}


# Create a security group for frontend
module "sg-for-frontend" {
  source = "../../modules/sec_grp"
  sg-name = "Cinema-frontend-sg"
  vpc-id = module.vpc.vpc-id
  security-group-id = module.alb-sg.alb_security-group-id
  container-port = 5173
}



# Create a security group for gateway
module "sg-for-gateway" {
  source = "../../modules/sec_grp"
  sg-name = "Cinema-gateway-sg"
  vpc-id = module.vpc.vpc-id
  security-group-id = module.sg-for-frontend.security-group-id
  container-port = 80
}







# Create an ECS Task Definition and Service for FRONTEND
module "frontend-service" {
  source = "../../modules/ecs"
  ecs-task-family-name = "Cinema-frontend"
  cpu-size = "256"
  memory-size = "512"
  container-port = 5173
  container-environment-variables = [
    {
      name  = "API_URL"
      value = "http://cinema-gateway:8080"
    }
  ]

  ecs-service-name = "Cinema-frontend-service"
  ecs-cluster-id = module.ecs-cluster.cluster-id
  desired-count = 1
  public-subnet-01-id = module.vpc.public-subnet-01-id
  public-subnet-02-id = module.vpc.public-subnet-02-id
  security-group-id = module.sg-for-frontend.security-group-id
  alb_tar_grp_arn = module.alb-target-group.alb-targ-grp-arn
}



# Create an Application Load Balancer (ALB)
module "alb" {
  source = "../../modules/alb"
  alb-name = "Cinema-alb"
  security-group-id = module.alb-sg.alb_security-group-id
  public-subnet-01-id = module.vpc.public-subnet-01-id
  public-subnet-02-id = module.vpc.public-subnet-02-id
}



# Create an ALB Target Group
module "alb-target-group" {
  source = "../../modules/alb_target_grp"
  alb-target-group-name = "Cinema-alb-target-group"
  alb-target-group-port = 80
  alb-target-group-protocol = "HTTP"
  vpc-id = module.vpc.vpc-id
}


# Create an ALB Listener
module "alb-listener" {
  source = "../../modules/alb_listner"
  alb-arn = module.alb.alb-arn
  alb-port = 80
  alb-protocol = "HTTP"
  target-group-arn = module.alb-target-group.alb-targ-grp-arn
}