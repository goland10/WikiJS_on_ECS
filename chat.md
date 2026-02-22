Below is a complete reference solution using AWS + Terraform to deploy a highly available, secure, and scalable Wiki.js platform for enterprise internal knowledge management.

1. Cloud Choice and Core Architecture

I’m choosing AWS because it provides mature managed services for containers, databases, networking, and observability.

Wiki.js will run as containers on Amazon Elastic Container Service (ECS Fargate) behind an Application Load Balancer.
The database will be Amazon Relational Database Service (RDS PostgreSQL).
Static uploads will be stored in Amazon Simple Storage Service (S3).
DNS and TLS will use **Amazon Route 53 and AWS Certificate Manager.

The deployment will be fully provisioned using Terraform.

2. High-Level Architecture

Architecture components:

VPC across 2–3 Availability Zones

Public subnets:

Application Load Balancer

Private subnets:

ECS Fargate service (Wiki.js containers)

RDS PostgreSQL (Multi-AZ)

S3 bucket (file uploads / backups)

CloudWatch (logs, metrics, alarms)

IAM roles for least privilege

Secrets Manager for DB credentials

Traffic Flow

User → Route53 DNS → ALB (HTTPS) → ECS Fargate → RDS
Uploads → S3
Logs → CloudWatch

3. Compute Design
Why ECS Fargate?

Serverless containers (no EC2 management)

Auto-scaling support

Native integration with ALB

Strong IAM boundary controls

ECS Setup

ECS cluster

Task definition:

Wiki.js Docker image (requarks/wiki:2)

CPU: 512–1024

Memory: 1024–2048 MB

Service:

Desired count: 2 (minimum for HA)

Auto Scaling target tracking on CPU or ALB request count

4. Storage Design
Database

Use RDS PostgreSQL:

Multi-AZ enabled

Encrypted at rest (KMS)

Storage autoscaling enabled

Backups retained 7–30 days

Private subnet only (no public access)

File Storage

Wiki.js supports S3 backend.

S3 bucket:

Versioning enabled

Server-side encryption (SSE-KMS)

Block public access

Lifecycle policies (optional)

5. Networking Design
VPC Layout

2 Public subnets (ALB)

2 Private subnets (ECS + RDS)

NAT Gateway for outbound internet from private subnets

Security Groups

ALB:

Allow 443 from corporate CIDR or VPN

Forward to ECS on port 3000

ECS:

Allow inbound only from ALB SG

Outbound to RDS and S3

RDS:

Allow inbound only from ECS SG

Internal Access

For internal-only wiki:

Restrict ALB access to:

Corporate public IPs

OR VPN

OR AWS Client VPN

OR PrivateLink

6. Scalability

ECS Service Auto Scaling:

Target CPU 60%

Scale min=2 max=10

Optional: scale on ALB request count

RDS:

Use storage autoscaling

Upgrade vertically if needed

S3:

Automatically scalable

7. Observability
Logging

ECS logs → CloudWatch Log Groups

ALB access logs → S3

RDS logs → CloudWatch

Monitoring

CloudWatch alarms:

High CPU (ECS)

High DB connections

ALB 5XX errors

SNS topic for alerts

Metrics to Monitor

ECS CPU/memory

ALB target response time

RDS free storage

RDS CPU

8. Security Best Practices

No public RDS.

Secrets stored in AWS Secrets Manager.

TLS enforced (HTTPS only).

IAM task roles with least privilege.

Encryption:

RDS encryption enabled

S3 SSE-KMS

WAF (optional) attached to ALB.

Use IAM authentication or SSO for Wiki.js login:

SAML or OIDC integration with corporate IdP.

9. Terraform Structure

Suggested structure:

terraform/
  main.tf
  variables.tf
  outputs.tf
  provider.tf

  modules/
    vpc/
    ecs/
    rds/
    alb/
    s3/
    monitoring/

10. Example Terraform Snippets
Provider
provider "aws" {
  region = var.region
}

RDS PostgreSQL
resource "aws_db_instance" "wiki" {
  identifier              = "wiki-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.medium"
  allocated_storage       = 50
  storage_encrypted       = true
  multi_az                = true
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.wiki.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = false
}

ECS Service
resource "aws_ecs_service" "wiki" {
  name            = "wiki-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.wiki.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.wiki.arn
    container_name   = "wiki"
    container_port   = 3000
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs.id]
  }
}

11. Deployment Instructions
Prerequisites

Terraform >= 1.5

AWS CLI configured

Domain registered

Steps

Clone repository.

Configure terraform.tfvars.

Run:

terraform init
terraform plan
terraform apply


After deployment:

Point Route53 record to ALB

Access Wiki.js via HTTPS

Complete initial admin setup

12. Teardown Instructions
terraform destroy


Important:

Ensure RDS final snapshot if needed.

Confirm S3 bucket empty (Terraform cannot delete non-empty buckets).

13. Architecture Diagram (Text Representation)
                Internet
                   |
             Route53 DNS
                   |
              HTTPS (443)
                   |
              Application
              Load Balancer
                   |
           -------------------
           |                 |
        ECS Task         ECS Task
         (AZ1)             (AZ2)
           |                 |
           -----------RDS------------
                    Multi-AZ
                       |
                      S3

14. Why This Meets Requirements

Reliability:

Multi-AZ RDS

Multiple ECS tasks

ALB health checks

Security:

Private subnets

IAM roles

Encryption everywhere

Secrets Manager

Scalability:

ECS Auto Scaling

Managed services

S3 infinite scale

Observability:

CloudWatch metrics

Logs centralized

Alerts via SNS

Automation:

100% Terraform

Modular reusable code