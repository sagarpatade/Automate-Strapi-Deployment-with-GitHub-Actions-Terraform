#  Automated Strapi Deployment Pipeline
**Automating Infrastructure as Code (IaC) with GitHub Actions & Terraform**

---

##  Project Overview
This repository demonstrates a fully automated **CI/CD pipeline** designed to build and deploy a Strapi Headless CMS application to **AWS EC2**. This project moves away from manual server setup, ensuring a reliable, repeatable, and secure deployment process.


Project Walkthrough
[![Watch the Demo](https://cdn.loom.com/sessions/thumbnails/f73399229f9946b1a0e60e733029dace-00001.jpg)](https://www.loom.com/share/f73399229f9946b1a0e60e733029dace)


| Feature | Technology |
| :--- | :--- |
| **Cloud Provider** | AWS (EC2, ECR, IAM) |
| **Infrastructure** | Terraform |
| **Automation** | GitHub Actions |
| **Container** | Docker |

---

##  CI/CD Architecture

### **1. Continuous Integration (CI)**
* **Trigger:** Automated on every `push` to the `main` branch.
* **Workflow:**
  * Authenticates with the **ECR Registry** 
    * Builds a production-ready Docker image.
    * Pushes the image to the `sagar-patade-strapi-app` repository.

### **2. Continuous Deployment (CD)**
* **Trigger:** Manually via GitHub Actions `workflow_dispatch`.
* **Workflow:**
    * Injects **GitHub Secrets** into Terraform environment variables.
    * Provisions/Updates EC2 instance with an optimized **2GB Swap File** to prevent system freezes.
    * Automatically pulls the latest image from ECR and restarts the container.

---

##  Security & Optimization
* **Secret Management:** Sensitive data like `AWS_ACCESS_KEY` and `TF_VAR_public_key` are stored securely in GitHub Secrets.
* **IAM Roles:** The EC2 instance uses the `ec2-ecr-role` for secure, keyless communication with AWS ECR.
* **Performance:** Implemented a swap file to ensure the `t2.micro` instance stays healthy (2/2 status checks) during high-load Docker pulls.

---

##  How to Deploy
1. **Commit Code:** Push changes to `main` to trigger the Docker build.
2. **Run Pipeline:** Go to **Actions > CD - Terraform Deploy > Run Workflow**.
3. **Verify:** Access the application at `http://<PUBLIC_IP>:1337/admin`.