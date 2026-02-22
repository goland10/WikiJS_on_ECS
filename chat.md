Architecture Overview (AWS)

Users access Wiki.js over HTTPS through an Application Load Balancer. Traffic flows into private subnets where multiple Wiki.js containers run on Amazon ECS Fargate. The application connects to Amazon RDS for PostgreSQL for structured data and Amazon S3 for file uploads and assets. Secrets are stored in AWS Secrets Manager. Observability is handled through CloudWatch (logs, metrics, alarms). DNS and TLS are managed with Route53 and ACM.

Main AWS components:

VPC with 2–3 Availability Zones

Public subnets (ALB)

Private subnets (ECS + RDS)

Amazon ECS (Fargate)

Amazon RDS for PostgreSQL

Amazon S3

AWS Secrets Manager

Application Load Balancer

CloudWatch + Alarms

Route53 + ACM

High-Level Architecture Diagram

Internet
↓
Route53 → ACM (TLS cert)
↓
Application Load Balancer (public subnets)
↓
ECS Fargate Service (private subnets, multi-AZ)
↓
RDS PostgreSQL (Multi-AZ)
↓
S3 (file storage)

Reliability

ECS service with minimum 2 tasks across multiple AZs.

ALB health checks.

RDS Multi-AZ deployment.

S3 provides durable object storage.

Auto Scaling based on CPU and memory.

Security

Private subnets for ECS and RDS.

Security groups: ALB → ECS → RDS only required ports.

TLS termination at ALB using ACM certificate.

IAM task roles for S3 access.

Database credentials stored in Secrets Manager.

Encryption enabled: RDS (at rest), S3 (SSE), EBS.

Optional: WAF in front of ALB.

SSO integration via SAML/OIDC (e.g., Okta, Azure AD).

Scalability

ECS Service Auto Scaling (target tracking on CPU).

ALB handles concurrent users.

RDS can scale vertically; optionally Aurora PostgreSQL for better scaling.

S3 scales automatically.

Observability

ECS logs → CloudWatch Logs.

RDS enhanced monitoring.

CloudWatch Alarms:

High CPU

RDS connections

5xx from ALB

Optional: AWS X-Ray tracing.

Centralized log retention policies.

Compute Choice Justification

ECS Fargate was selected because:

No server management.

Built-in HA across AZs.

Easy horizontal scaling.

Simpler than EKS for this workload.

Infrastructure as Code (Terraform Structure)

terraform/
main.tf
variables.tf
outputs.tf
modules/
vpc/
ecs/
rds/
alb/
s3/
monitoring/

Core resources:

aws_vpc

aws_subnet

aws_lb + aws_lb_listener

aws_ecs_cluster

aws_ecs_task_definition

aws_ecs_service

aws_db_instance

aws_s3_bucket

aws_secretsmanager_secret

aws_cloudwatch_metric_alarm

Deployment Steps

Configure AWS credentials.

terraform init

terraform plan

terraform apply

Update DNS in Route53.

Access Wiki.js via HTTPS domain.

Teardown

terraform destroy

Wiki.js Configuration

Environment variables in ECS task:

DB_TYPE=postgres

DB_HOST=RDS endpoint

DB_USER / DB_PASS from Secrets Manager

DB_NAME=wiki

STORAGE_TYPE=s3

S3_BUCKET=name

S3_REGION=region

Optional Enhancements

Blue/Green deployments using CodeDeploy.

Backup automation via AWS Backup.

WAF rate limiting.

CloudFront CDN in front of ALB.

Multi-region DR strategy.

Why This Design Works

It provides:

High availability (multi-AZ, auto-healing)

Secure isolation (private networking + IAM)

Elastic scaling (ECS + ALB)

Full automation (Terraform)

Production-grade observability