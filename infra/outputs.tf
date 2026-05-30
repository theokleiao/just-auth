output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.justauth_ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint of the RDS PostgreSQL instance"
  value       = aws_db_instance.justauth_rds.endpoint
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.justauth_vpc.id
}