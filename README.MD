Task 5: Strapi Deployment Automation with Terraform
This project automates the deployment of a Strapi CMS application on AWS using Terraform and Docker. It specifically addresses resource constraints common with the t2.micro instance type.

🚀 Features
Infrastructure as Code: Full AWS setup using Terraform (EC2, Security Groups, Key Pairs).

Automated Provisioning: user_data script to install Docker, pull the slim Strapi image, and start the container.

Storage Scaling: Root EBS volume increased to 20GB to accommodate Docker layers.

Memory Optimization: Automated 2GB Swap file creation to ensure stable performance during Strapi builds.

🛠️ Technical Implementation
1. Storage Fix
The default 8GB storage was insufficient for the Strapi Docker image and system logs. I scaled the root block device to 20GB using the root_block_device resource in main.tf.

2. Memory Management (Swap Space)
To prevent the application from crashing on a 1GB RAM instance, the following automation was added to the user_data script:

Bash

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
3. SSH Access
I implemented a permanent key-pair strategy to ensure consistent access to the instance, resolving the "Permission denied" errors encountered with temporary keys.

📦 How to Deploy
Initialize Terraform: terraform init

Validate configuration: terraform validate

Deploy infrastructure: terraform apply -var="public_key=$(cat task5-permanent.pub)"

🔗 Verification
Public IP: Accessible via the output variables.

Port: The application runs on port 1337.

Health Check: Run docker ps inside the instance to verify the container status.