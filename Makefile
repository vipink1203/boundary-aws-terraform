.PHONY: init plan apply destroy fmt validate clean

# Default target
all: init fmt validate plan

# Initialize Terraform
init:
	terraform init

# Format Terraform files
fmt:
	terraform fmt -recursive

# Validate Terraform files
validate:
	terraform validate

# Plan Terraform changes
plan:
	terraform plan -out=tfplan.binary

# Apply Terraform changes
apply:
	terraform apply tfplan.binary

# Apply Terraform changes without a plan
apply-auto:
	terraform apply -auto-approve

# Destroy all resources
destroy:
	terraform destroy

# Clean up generated files
clean:
	rm -f tfplan.binary
	rm -f terraform.tfstate.backup
	rm -f .terraform.lock.hcl
	rm -rf .terraform/

# Show Terraform outputs
outputs:
	terraform output

# Generate documentation
docs:
	terraform-docs markdown . > TERRAFORM.md

# Show help
help:
	@echo "Available targets:"
	@echo "  all        - Initialize, format, validate, and plan"
	@echo "  init       - Initialize Terraform"
	@echo "  fmt        - Format Terraform files"
	@echo "  validate   - Validate Terraform files"
	@echo "  plan       - Plan Terraform changes"
	@echo "  apply      - Apply Terraform changes"
	@echo "  apply-auto - Apply Terraform changes without confirmation"
	@echo "  destroy    - Destroy all resources"
	@echo "  clean      - Clean up generated files"
	@echo "  outputs    - Show Terraform outputs"
	@echo "  docs       - Generate documentation"
	@echo "  help       - Show this help message"
