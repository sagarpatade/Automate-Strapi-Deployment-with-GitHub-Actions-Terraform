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
  public_key = file("${path.module}/task5-permanent.pub")
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
  # Optimized User Data for t2.micro (1GB RAM limits)
  user_data = <<-EOF
              #!/bin/bash
              # 1. Create 2GB Swap File IMMEDIATELY to prevent freezing
              sudo fallocate -l 2G /swapfile
              sudo chmod 600 /swapfile
              sudo mkswap /swapfile
              sudo swapon /swapfile
              echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

              # 2. Update and install unzip/curl
              sudo apt-get update -y
              sudo apt-get install -y unzip curl

              # 3. Install Docker using official script (more reliable for 24.04)
              curl -fsSL https://get.docker.com -o get-docker.sh
              sudo sh get-docker.sh
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # 4. Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install

              # 5. Login to ECR and Pull Image
              # The swap file will prevent the 'Out of Memory' crash during this 3.81GB pull
              /usr/local/bin/aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 811738710312.dkr.ecr.us-east-1.amazonaws.com
              sudo docker pull 811738710312.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:latest
              sudo docker run -d -p 1337:1337 811738710312.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:latest
              EOF

  tags = {
    Name = var.instance_name
  }
}