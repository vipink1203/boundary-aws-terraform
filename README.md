# HashiCorp Boundary AWS Deployment

This repository contains Terraform code to deploy HashiCorp Boundary in AWS for production use with enterprise licensing.

## Overview

[HashiCorp Boundary](https://www.hashicorp.com/products/boundary) provides secure access to hosts and services with fine-grained authorization without requiring direct network access. This project sets up a production-ready Boundary deployment in AWS, using your existing VPC and database infrastructure, with separate controller and worker nodes.

### Features

- Production-ready (non-dev mode) deployment
- Enterprise license support
- Separate controller and worker nodes
- AWS KMS integration for encryption
- Support for custom AMIs
- Integration with existing VPC and PostgreSQL database

## Prerequisites

- AWS account with appropriate permissions
- Terraform 1.5 or later
- HashiCorp Boundary Enterprise license
- SSH key pair for accessing target hosts
- AWS CLI configured with appropriate credentials
- **Existing VPC** with public and private subnets
- **Existing PostgreSQL database** (version 12+)
- (Optional) Custom AMIs for controller and worker instances

## Architecture

This deployment creates:

1. **Security Groups**: For controller, worker, and load balancer components
2. **Boundary Controller**: EC2 instance running the Boundary controller service
3. **Boundary Worker**: EC2 instance running the Boundary worker service
4. **KMS Keys**: For data encryption
5. **Load Balancers**: For high availability and secure access

## Deployment Steps

See the [Deployment Guide](docs/deployment_guide.md) for step-by-step instructions.

## Target Management

See the [Target Management Guide](docs/target_management.md) for instructions on adding and configuring targets.

## User Management

See the [User Management Guide](docs/user_management.md) for instructions on managing users and authentication methods.

## License

This project is licensed under the [MIT License](LICENSE).
