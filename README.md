# Cinema Streaming Platform – DevOps & Cloud Architecture

![Architecture](https://img.shields.io/badge/Architecture-Microservices-blue)
![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=github-actions)
![Docker](https://img.shields.io/badge/Containers-Docker-2496ED?logo=docker)

A production-ready streaming platform explicitly developed to demonstrate modern **DevOps, Cloud Engineering, and Infrastructure as Code (IaC)** principles. The project is a highly scalable, containerized microservices ecosystem deployed on AWS.

---
<br>

##  Cloud Architecture & Infrastructure (AWS)

The entire cloud infrastructure is provisioned using **Terraform** (`/infrastructure`) for complete automation and reproducibility.

- **Compute (Amazon ECS on Fargate)**: Serverless container execution for the Gateway, Frontend, Catalog, and User services.
- **Networking (VPC & ALB)**: A custom VPC layout. An Application Load Balancer (ALB) routes public web traffic to the frontend and API gateway.
- **Service Discovery (Cloud Map)**: Enables internal microservices (like Gateway talking to User or Catalog services) to communicate securely without exposing them to the internet.
- **Container Registry (ECR)**: Securely stores version-tagged Docker images.
- **Security & Secrets**: AWS Secrets Manager handles sensitive environment variables and credentials securely. Security Groups manage strict inbound/outbound rules.

<img width="500" height="500" alt="Roboto Mono" src="https://github.com/user-attachments/assets/ca859ef8-6206-4ac4-a415-cdb300d32a8a"/>


---
<br>

##  CI/CD Pipeline (GitHub Actions)

A fully automated continuous integration and continuous deployment pipeline (`.github/workflows/CI_CD_Pipeline.yml`) ensures seamless rollouts:

1. **Trigger**: Automatically runs on pushes to the `main` branch.
2. **Build & Tag**: Builds Docker images for all services (Frontend, Gateway, Catalog, User) using the Git commit SHA as the image tag.
3. **Push to ECR**: Authenticates with AWS and pushes the newly built images to Elastic Container Registry.
4. **Deploy to ECS**: 
   - Downloads existing ECS task definitions.
   - Dynamically injects the new image tags into the JSON definitions.
   - Registers the new task definition revisions.
   - Triggers a rolling update on the ECS Cluster to ensure zero-downtime deployments.
   - Waits for service stability before completing the workflow.

---
<br>

##  Microservices Architecture

- **API Gateway (Nginx)**: The single entry point for API traffic. It routes requests dynamically and unifies the backend microservices.
- **Frontend Service (React/Vite)**: Lightweight, pure-UI presentation layer.
- **Catalog Service (Node.js)**: Stateless proxy service that interacts with the TMDB API to serve movie metadata.
- **User Service (Node.js)**: Stateful microservice responsible for user data (favorites, watch progress). It strictly validates JWTs using the Firebase Admin SDK.





<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
👨‍💻 Author


**Pasindu Abeysundara**
