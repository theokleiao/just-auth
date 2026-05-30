# Setup Just Auth Infrastructure and Runtime Environment using Terraform 

## Prerequisites

- AWS Account with admin access: run `aws sts get-caller-identity` to verify
- AWS CLI installed and configured: run `aws configure` to configure
- Terraform installed: run `terraform version` to verify

## Steps

1. Inspect and review `backend-bootstrap.sh` script.

2. Run `bash backend-bootstrap.sh` to create the S3 bucket for the Terraform state management and lock.

3. Inspect and review `backend.tf` file. Ensure to replace the specified `bucket` name with your actual bucket name as gotten from Step 2.

4. Run `terraform init` to initialize the Terraform backend.

5. Define variables in `variables.tf` file to consume actual values in `terraform.tfvars` file for the infrastructure deployment.

6. Write `vpc.tf`, `ec2.tf`, and `rds.tf` files for infrastructure and runtime setup.

7. Write `outputs.tf` to output relevant values from the infrastructure setup.

8. Run `terraform validate` followed by `terraform plan` to preview the infrastructure deployment.

9. Run `terraform apply` to deploy the infrastructure. Take note of the outputs: `ec2_public_ip` and `rds_endpoint`.

10. Connect to the EC2 instance using SSH and port 22: `ssh -i ~/.ssh/id_rsa ubuntu@<ec2_public_ip>`

11. From the EC2 instance, connect to the RDS instance using the following credentials: 

```bash
psql -h <rds_endpoint> -U justauthadmin -d justauthdb
```

12. Run `terraform destroy -auto-approve` to destroy the infrastructure.
