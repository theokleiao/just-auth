# Lookup latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Key pair from provided public key
resource "aws_key_pair" "justauth_key" {
  key_name   = "${var.project}-key"
  public_key = var.public_key
}

# EC2 instance
resource "aws_instance" "justauth_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.justauth_key.key_name

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y postgresql15
    EOF

  tags = {
    Name        = "${var.project}-ec2"
    Environment = var.environment
  }
}