# Boundary AWS Deployment Guide

This guide provides step-by-step instructions for deploying HashiCorp Boundary in AWS using Terraform.

## Prerequisites

Before you begin, ensure you have:

1. AWS account with appropriate permissions
2. Terraform 1.5 or later installed
3. AWS CLI installed and configured
4. HashiCorp Boundary Enterprise license
5. SSH key pair for EC2 instances

## Step 1: Clone the Repository

```bash
git clone https://github.com/vipink1203/boundary-aws-terraform.git
cd boundary-aws-terraform
```

## Step 2: Configure Deployment Variables

1. Create a `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit the `terraform.tfvars` file with your specific configuration values:

```hcl
# AWS Configuration
aws_region     = "us-east-1"
vpc_cidr       = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

# Boundary Configuration
boundary_version = "0.15.0+ent"
boundary_license_path = "./license.hclic"

# Database Configuration
db_username = "boundary"
db_password = "your-secure-password" # Change this!
db_instance_type = "db.t3.medium"

# EC2 Configuration
controller_instance_type = "t3.medium"
worker_instance_type = "t3.medium"
ssh_key_name = "your-key-name"

# Admin Credentials
initial_admin_username = "admin"
initial_admin_password = "your-secure-admin-password" # Change this!
```

## Step 3: Add Your Boundary Enterprise License

1. Place your Boundary Enterprise license file in the root directory as `license.hclic`
2. Ensure the file path matches the `boundary_license_path` variable in your `terraform.tfvars`

## Step 4: Initialize Terraform

```bash
terraform init
```

## Step 5: Review the Deployment Plan

```bash
terraform plan
```

Review the plan carefully to ensure it meets your requirements.

## Step 6: Apply the Terraform Configuration

```bash
terraform apply
```

Confirm the deployment by typing `yes` when prompted.

## Step 7: Record the Outputs

After successful deployment, Terraform will output important information including:

- Boundary Controller URL
- Worker's Public IP
- Database Endpoint
- Admin credentials

Save these values for future reference.

## Step 8: Verify the Deployment

1. Install the Boundary CLI if you haven't already:

```bash
# For MacOS with Homebrew
brew install boundary

# For Linux
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install boundary
```

2. Log in to Boundary using the Controller URL and admin credentials:

```bash
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin \
  -password=your-secure-admin-password
```

3. Verify connection by listing scopes:

```bash
boundary scopes list
```

## Step 9: Configure DNS (Optional but Recommended)

For production deployments, configure a proper DNS name for your Boundary controller:

1. Create a DNS record pointing to the Boundary controller's load balancer.
2. Update the Boundary controller's configuration to use this DNS name.

## Step 10: Set Up Monitoring and Logging

For production environments, set up:

1. AWS CloudWatch for logs and metrics
2. AWS CloudTrail for API auditing
3. AWS SNS for alerts

## Troubleshooting

If you encounter issues during deployment:

1. Check the Terraform logs
2. Verify AWS permissions
3. Check EC2 instance logs via:
   ```bash
   ssh -i your-key.pem ec2-user@controller-public-ip
   sudo journalctl -u boundary
   ```

## Next Steps

- [Add and manage target hosts](target_management.md)
- [Set up user accounts and authentication](user_management.md)
- [Configure high availability](high_availability.md) (if needed)
