# Boundary AWS Deployment Guide

This guide provides step-by-step instructions for deploying HashiCorp Boundary in AWS using Terraform.

## Prerequisites

Before you begin, ensure you have:

1. AWS account with appropriate permissions
2. Terraform 1.5 or later installed
3. AWS CLI installed and configured
4. HashiCorp Boundary Enterprise license
5. SSH key pair for EC2 instances
6. Existing VPC with public and private subnets
7. Existing database instance
8. (Optional) Custom AMIs for controller and worker instances

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
aws_region = "us-east-1"

# Existing Infrastructure IDs
vpc_id             = "vpc-0123456789abcdef0" # Your existing VPC ID
public_subnet_ids  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"] # Your public subnet IDs
private_subnet_ids = ["subnet-0123456789abcdef2", "subnet-0123456789abcdef3"] # Your private subnet IDs
db_endpoint        = "boundary-db.abcdefghij.us-east-1.rds.amazonaws.com:5432" # Your DB endpoint
db_username        = "boundary" # Your DB username
db_password        = "your-secure-password" # Your DB password

# Boundary Configuration
boundary_version      = "0.15.0+ent"
boundary_license_path = "./license.hclic"

# AMI Configuration
controller_ami_id = "ami-01234567890abcdef" # Replace with your controller AMI ID
worker_ami_id     = "ami-01234567890abcdef" # Replace with your worker AMI ID

# EC2 Configuration
controller_instance_type = "t3.medium"
worker_instance_type     = "t3.medium"
ssh_key_name             = "your-key-name"

# Admin Credentials
initial_admin_username = "admin"
initial_admin_password = "your-secure-admin-password" # Change this!
```

### Using Custom AMIs

If you're using custom AMIs (which you've indicated in the AMI Configuration section):

1. Ensure your AMIs have the necessary prerequisites installed:
   - AWS CLI
   - jq
   - PostgreSQL client libraries
   - unzip
   - OpenSSL
   - CloudWatch agent

2. If your AMIs are based on an OS other than Amazon Linux 2, you may need to adjust the user data scripts in:
   - `modules/controller/templates/controller_user_data.tmpl`
   - `modules/worker/templates/worker_user_data.tmpl`

3. If your AMIs already have Boundary installed, you might need to modify the user data scripts to avoid reinstallation.

### Using Existing VPC and Database

This deployment is designed to work with your existing infrastructure:

1. Make sure your VPC has both public and private subnets properly configured
2. Ensure your database has:
   - PostgreSQL 12 or later
   - A database named "boundary" (or you'll need to create it)
   - Proper security group rules to allow connections from the controller instance
   - The specified user with appropriate permissions

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

### Common Issues with Custom AMIs

If you're using custom AMIs and encounter issues:

1. **User Data Not Executing**: Ensure your AMI is configured to run user data scripts on launch.

2. **Missing Dependencies**: Verify all required packages are installed on your AMI.

3. **Permission Issues**: Check if the AMI has the correct file system permissions for Boundary directories.

4. **Boundary Already Installed**: If Boundary is pre-installed on your AMI, you may see errors about reinstallation. Modify the user data scripts accordingly.

5. **OS Differences**: If your AMI uses a different OS than Amazon Linux 2, package installation commands may need updating.

### Common Issues with Existing VPC and Database

1. **Subnet Connectivity**: Make sure your private subnets can reach the database and your public subnets have internet access.

2. **Security Groups**: Ensure controller can connect to database, worker can connect to controller, and both can be accessed by the load balancer.

3. **Database Permissions**: Verify the database user has CREATE, ALTER, and other necessary permissions.

## Next Steps

- [Add and manage target hosts](target_management.md)
- [Set up user accounts and authentication](user_management.md)
- [Configure high availability](high_availability.md) (if needed)
