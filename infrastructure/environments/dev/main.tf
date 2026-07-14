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



# Create a DNS namespace
module "dns-namespace" {
  source = "../../modules/dns_namespace"
  namespace-name = "cinema.local"
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
  security-group-id = module.alb-sg.alb_security-group-id
  container-port = 80
}

# Create a security group for catalog service
module "sg-for-catalog" {
  source = "../../modules/sec_grp"
  sg-name = "Cinema-catalog-sg"
  vpc-id = module.vpc.vpc-id
  security-group-id = module.sg-for-gateway.security-group-id
  container-port = 5001
}

module "sg-for-user-service" {
  source = "../../modules/sec_grp"
  sg-name = "Cinema-user-service-sg"
  vpc-id = module.vpc.vpc-id
  security-group-id = module.sg-for-gateway.security-group-id
  container-port = 5002
}









# Create an ECS Task Definition and Service for Gateway
module "gateway-service" {
  source = "../../modules/ecs"
  ecs-task-family-name = "Cinema-gateway"
  cpu-size = "256"
  memory-size = "512"
  container-port = 80
  aws-region = "eu-north-1"

  ecs-service-name = "Cinema-gateway-service"
  ecs-cluster-id = module.ecs-cluster.cluster-id
  desired-count = 1
  public-subnet-01-id = module.vpc.public-subnet-01-id
  public-subnet-02-id = module.vpc.public-subnet-02-id
  security-group-id = module.sg-for-gateway.security-group-id
  alb_tar_grp_arn = module.alb-target-group-for-gateway.alb-targ-grp-arn
}




# Create a namespace service discovery for catalog service
module "catalog-discovery" {
  source = "../../modules/nam_space_serv_discovery"
  service-disc-name = "catalog-service"
  namespace-id = module.dns-namespace.namespace_id
}


# Create an ECS Task Definition and Service for Catalog Service
module "catalog-service" {
  source = "../../modules/ecs"
  ecs-task-family-name = "Cinema-catalog"
  cpu-size = "256"
  memory-size = "512"
  container-port = 5001
  aws-region = "eu-north-1"

  ecs-service-name = "Cinema-catalog-service"
  ecs-cluster-id = module.ecs-cluster.cluster-id
  desired-count = 1
  public-subnet-01-id = module.vpc.public-subnet-01-id
  public-subnet-02-id = module.vpc.public-subnet-02-id
  security-group-id = module.sg-for-catalog.security-group-id
  service-discovery-arn = module.catalog-discovery.arn
}




# Create a namespace service discovery for user service
module "user-service-discovery" {
  source = "../../modules/nam_space_serv_discovery"
  service-disc-name = "user-service"
  namespace-id = module.dns-namespace.namespace_id
}


# Create an ECS Task Definition and Service for User Service
module "user-service" {
  source = "../../modules/ecs"
  ecs-task-family-name = "Cinema-user-service"
  cpu-size = "256"
  memory-size = "512"
  container-port = 5002
  aws-region = "eu-north-1"

  ecs-service-name = "Cinema-user-service"
  ecs-cluster-id = module.ecs-cluster.cluster-id
  desired-count = 1
  public-subnet-01-id = module.vpc.public-subnet-01-id
  public-subnet-02-id = module.vpc.public-subnet-02-id
  security-group-id = module.sg-for-user-service.security-group-id
  service-discovery-arn = module.user-service-discovery.arn
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

  container-secrets = [
    {
      name      = "VITE_FIREBASE_API_KEY"
      valueFrom = module.Firebase-API-Key.secret-arn
    },
    {
      name      = "VITE_FIREBASE_AUTH_DOMAIN"
      valueFrom = module.Firebase-Auth-Domain.secret-arn
    },
    {
      name      = "VITE_FIREBASE_PROJECT_ID"
      valueFrom = module.Firebase-Project-Id.secret-arn
    },
    {
      name      = "VITE_FIREBASE_STORAGE_BUCKET"
      valueFrom = module.Firebase-Storage-Bucket.secret-arn
    },
    {
      name      = "VITE_FIREBASE_MESSAGING_SENDER_ID"
      valueFrom = module.Firebase-Messaging-Sender-Id.secret-arn
    },
    {
      name      = "VITE_FIREBASE_APP_ID"
      valueFrom = module.Firebase-app-id.secret-arn
    }
  ]
  aws-region = "eu-north-1"

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




# Create an ALB Target Group for Gateway Service
module "alb-target-group-for-gateway" {
  source = "../../modules/alb_target_grp"
  alb-target-group-name = "Cinema-gateway-alb-target-group"
  alb-target-group-port = 80
  alb-target-group-protocol = "HTTP"
  vpc-id = module.vpc.vpc-id  
}


# Create an ALB Listener Rule for Gateway Service
module "alb-listner-rule" {
  source = "../../modules/alb_listner_rule"
  alb_listener-arn = module.alb-listener.alb-listener-arn
  priority = 100
  target-group-arn = module.alb-target-group-for-gateway.alb-targ-grp-arn
  path-pattern = ["/api/*"]
}







module "Firebase-API-Key" {
  source = "../../modules/secret_manager"
  secret-name = "VITE_FIREBASE_API_KEY"
  secret-value = var.firebase-api-key
}

module "Firebase-Auth-Domain" {
  source = "../../modules/secret_manager"
  secret-name = "VITE_FIREBASE_AUTH_DOMAIN"
  secret-value = var.firebase-auth-domain
}

module "Firebase-Project-Id" {
  source = "../../modules/secret_manager"
  secret-name = "VITE_FIREBASE_PROJECT_ID"
  secret-value = var.firebase-project-id
}

module "Firebase-Storage-Bucket" {
  source = "../../modules/secret_manager"
  secret-name = "VITE_FIREBASE_STORAGE_BUCKET"
  secret-value = var.firebase-storage-bucket
}

module "Firebase-Messaging-Sender-Id" {
  source = "../../modules/secret_manager"
  secret-name = "VITE_FIREBASE_MESSAGING_SENDER_ID"
  secret-value = var.firebase-messaging-sender-id
}

module "Firebase-app-id" {
  source = "../../modules/secret_manager"
  secret-name = "VITE_FIREBASE_APP_ID"
  secret-value = var.firebase-app-id
}
