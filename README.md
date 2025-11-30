# Deploy a Java App from ECR to EKS in Jenkins CI/CD Pipeline

## 1. Overview

This project demonstrates a complete CI/CD pipeline for a Java (Spring Boot) application using Jenkins, Docker, AWS Elastic Container Registry (ECR), and AWS Elastic Kubernetes Service (EKS).

---

## 2. Key Technologies

- Java (Spring Boot, Maven)
- Docker (for containerization)
- Jenkins (for pipeline automation)
- AWS ECR (for Docker image storage)
- AWS EKS (for Kubernetes hosting)
- Kubernetes (for deployment)

---

## 3. Project Structure

### 3.1. Jenkinsfile

Defines the CI/CD pipeline.  
See the full Jenkins pipeline configuration in [Jenkinsfile](./Jenkinsfile).

---

### 3.2. Dockerfile

See the Docker build instructions in [Dockerfile](./Dockerfile).

---

### 3.4. Kubernetes Manifests

- [kubernetes/deployment.yaml](./kubernetes/deployment.yaml)
- [kubernetes/service.yaml](./kubernetes/service.yaml)

---

## 4. Pipeline Flow

1. **Code Commit:** Developers push code changes.
2. **Jenkins Trigger:** Jenkins pipeline starts automatically.
3. **Build & Test:** Application is built and tested.
4. **Dockerization:** A Docker image is built and tagged based on the incremented version and build number.
5. **Push to ECR:** Image is securely pushed to AWS ECR.
6. **Deploy to EKS:** The application is deployed/updated on the Kubernetes cluster.
7. **Version Tracking:** The new version is committed to the source repository.

---

## 5. Security and Best Practices

- All sensitive credentials (AWS, Docker/ECR, GitHub) are managed securely via Jenkins credentials.
- The pipeline uses dynamic variable injection for image tags and Kubernetes manifests.
- Amazon Corretto and Alpine Linux are used for a slim and secure runtime.

---

## 6. Getting Started

1. Clone the repository.
2. Ensure your Jenkins instance is set up with the required credentials (`ecr-credentials`, `jenkins_aws_access_key_id`, `jenkins-aws_secret_access_key`, `gitlab-credentials`).
3. Configure your EKS cluster and ECR repository.
4. Push changes to invoke the Jenkins pipeline and trigger the CI/CD flow.

**Note: For the source code, Dockerfile, Jenkinsfile, and Kubernetes manifests, refer to their respective files in the repository.**

---

## License

MIT
