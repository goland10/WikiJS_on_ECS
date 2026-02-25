# OpsGuru Hiring Assessment

## Problem

### Scenario

Your company is building an internal knowledge management platform for enterprise teams. The goal is to allow employees to collaborate on documentation, store company policies, and manage technical knowledge in a structured way.

To achieve this, your team has chosen [Wiki.js](https://js.wiki/), an open-source, self-hosted wiki platform that provides a powerful editor, authentication options, and content organization features.

### Objective

Your task is to design and deploy the infrastructure required to host Wiki.js on a cloud provider of your choice (AWS, GCP, or Azure) using Infrastructure as Code (Terraform, CDKs, Pulumi or cloud-specific IaC tools).

## Solution

### Requirements

Your deployment should ensure the following:

- Reliability: The solution should be highly available and able to handle multiple users.
- Security: The infrastructure should follow security best practices.
- Scalability: The deployment should accommodate growth over time.
- Observability: The system should have monitoring, logging, and alerting capabilities.
- Automation: The entire setup should be automated using IaC.

### Considerations

- Compute: Decide how you will run Wiki.js.
- Storage: Consider database and file storage requirements.
- Networking: Ensure the system is securely accessible.
- Scaling: Think about how to handle traffic spikes.
- Monitoring: Implement basic observability.

## Instructions

### Deliverables

1. Infrastructure as Code (IaC) implementation.
2. Architecture diagram showing the relevant components.
3. Deployment documentation, including instructions for setup and teardown.
4. Security considerations for handling sensitive data, authentication, and access control.

### Optional Resources

- [Wiki.js](https://js.wiki/)
- [Wiki.js Documentation](https://docs.requarks.io/)
- [Wiki.js GitHub Repository](https://github.com/Requarks/wiki)

## Documentation

Any candidate documentation for the solution should be placed in this section.

---

# WikiJS Infrastructure on AWS ECS Fargate with Terraform

This repository contains a production-ready Terraform configuration to deploy Wiki.js on AWS. It utilizes a modern, serverless architecture featuring Amazon ECS Fargate and Amazon RDS PostgreSQL, emphasizing security, scalability, and Infrastructure as Code (IaC) best practices.

## Overview

The project automates the deployment of a containerized Wiki.js application. 

Key components include:
* Networking: A custom VPC with public and private subnets across multiple Availability Zones.
* Compute: Amazon ECS using the Fargate (serverless) launch type for the application tier.
* Database: A Managed Amazon RDS instance running PostgreSQL 17.
* Traffic Management: An Application Load Balancer (ALB) to distribute traffic and handle health checks.
* Security: Private-link VPC Endpoints to ensure application traffic to * AWS services (ECR, S3, Secrets Manager) stays within the AWS network.
* Scalability: Target Tracking Autoscaling policies based on CPU utilization.

## Best Practices

This project demonstrates several high-level DevOps and security patterns:

- Zero-Trust Networking: All application components (ECS) and data components (RDS) are located in **private subnets with no direct internet access**.
- Security Groups - **Principle of Least Privilege**: Granular ingress/egress rules ensure, for example, that the database only accepts traffic from the ECS tasks on port 5432.
- Secret Management: **Database credentials are not hardcoded**. They are managed by AWS Secrets Manager and injected into the container at runtime via ECS secrets.
- High Availability: The RDS instance is configured for **Multi-AZ** deployment.
- Standardized Tagging: A *common_tags* local block ensures all resources are consistently labeled for **cost tracking** and management (p. 4).
- Environment Isolation: The configuration uses variables and local values to separate "Assessment" or "Production" environments.

## Architecture
[Diagram here](./docs/architecture.html)

The architecture follows a traditional three-tier web application model:
1. Web Tier: An internet-facing ALB in public subnets receives traffic on port 80/443 and forwards it to the application tier.
2. Application Tier: Wiki.js runs as a Fargate task in private subnets. It pulls its image from ECR and configuration from S3.
3. Data Tier: A PostgreSQL instance in private subnets stores application data.
Monitoring & Connectivity
- CloudWatch Logs capture application and system output.
- VPC Endpoints (Interface and Gateway) allow the private ECS tasks to communicate with S3, ECR, and Secrets Manager without a NAT Gateway, **reducing costs and increasing security**.

## Prerequisites
Before deploying this infrastructure, ensure you have the following:
- Terraform CLI (version ~> 1.0 recommended; provider uses ~> 6.0).
- AWS CLI configured with appropriate credentials.
- An S3 Bucket named wikijs-conf containing a wikijs.env file for application runtime configuration. [Instructions here](./docs/prerequisites.md)
- A Wiki.js Docker image pushed to an ECR repository. [Instructions here](./docs/prerequisites.md)

## Deployment instructions
1. prepare env file with your custom settings 
