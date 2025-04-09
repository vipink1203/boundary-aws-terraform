# HashiCorp Boundary AWS Deployment

This repository contains Terraform code to deploy HashiCorp Boundary in AWS for production use with enterprise licensing.

## Overview

[HashiCorp Boundary](https://www.hashicorp.com/products/boundary) provides secure access to hosts and services with fine-grained authorization without requiring direct network access. This project sets up a production-ready Boundary deployment in AWS, with separate controller and worker nodes.

### Features

- Production-ready (non-dev mode) deployment
- Enterprise license support
- Support for custom AMIs
- Uses existing VPC and database infrastructure
- Separate controller and worker nodes
- AWS KMS integration for encryption
- SSH key-based authentication for target hosts
- Password-based authentication for Boundary users

## Prerequisites

- AWS account with appropriate permissions
- Terraform 1.5 or later
- HashiCorp Boundary Enterprise license
- Existing VPC with public and private subnets
- Existing PostgreSQL database
- (Optional) Custom AMIs for controller and worker
- SSH key pair for accessing instances

## Architecture

This deployment creates:

1. **Boundary Controller**: EC2 instance running the Boundary controller service
2. **Boundary Worker**: EC2 instance running the Boundary worker service
3. **KMS Keys**: For data encryption
4. **Load Balancer**: For secure access
5. **Security Groups**: For controlling access to components

## Deployment Steps

See the [Deployment Guide](docs/deployment_guide.md) for step-by-step instructions.

## Target Management

See the [Target Management Guide](docs/target_management.md) for instructions on adding and configuring targets.

## User Management

See the [User Management Guide](docs/user_management.md) for instructions on managing users and authentication methods.

## License

This project is licensed under the [MIT License](LICENSE).
