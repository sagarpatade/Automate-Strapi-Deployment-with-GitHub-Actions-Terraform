# 1. Create Security Group (Firewall)
resource "aws_security_group" "strapi_sg" {
  name        = "strapi_task5_sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Reference your PERMANENT key
resource "aws_key_pair" "deployer" {
  key_name   = "task5-permanent-key"
  public_key = var.public_key
}

# 3. Create EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  # Attached the company-provided IAM role for ECR access
  iam_instance_profile = "ec2-ecr-role" 

  # Increased disk size to 20GB for Docker layers
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # 4. User Data Script (Automates Setup & ECR Login)
  # 4. Automated User Data Script
  user_data = <<-EOF
              #!/bin/bash
              # 1. Create Swap and Install dependencies (Docker & AWS CLI)
              sudo fallocate -l 2G /swapfile
              sudo chmod 600 /swapfile
              sudo mkswap /swapfile
              sudo swapon /swapfile
              echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
              sudo apt-get update -y
              sudo apt-get install -y unzip curl
              curl -fsSL https://get.docker.com -o get-docker.sh
              sudo sh get-docker.sh
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip && sudo ./aws/install

              # 2. Login to ECR
              /usr/local/bin/aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 811738710312.dkr.ecr.us-east-1.amazonaws.com

              # 3. Pull and Run the DYNAMIC image tag
              # The variable ${var.docker_image_tag} will be filled by GitHub Actions
              sudo docker pull 811738710312.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:${var.docker_image_tag}
              sudo docker run -d -p 1337:1337 811738710312.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:${var.docker_image_tag}
              EOF

  tags = {
    Name = var.instance_name
  }
}