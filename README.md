Deploy a Java App from ECR to EKS in Jenkins CI/CD Pipeline

1. Overview

This project demonstrates a complete CI/CD pipeline for a Java (Spring Boot) application using Jenkins, Docker, AWS Elastic Container Registry (ECR), and AWS Elastic Kubernetes Service (EKS).

2. Key Technologies

- Java (Spring Boot, Maven)
- Docker (for containerization)
- Jenkins (for pipeline automation)
- AWS ECR (for Docker image storage)
- AWS EKS (for Kubernetes hosting)
- Kubernetes (for deployment)

3. Project Structure

3.1. Jenkinsfile

Defines the CI/CD pipeline:
- Increment Version: Bumps the application version using Maven and appends the Jenkins build number for Docker image tagging.
- Build App: Uses Maven to build and package the Java application.
- Build Docker Image & Push to ECR:
  - Builds a Docker image from the application.
  - Authenticates using Jenkins credentials.
  - Pushes the image to AWS ECR.
- Deploy to EKS:
  - Uses AWS credentials via Jenkins secrets.
  - Templates and applies Kubernetes manifests for deployment (`deployment.yaml`, `service.yaml`) with `envsubst` for variable substitution.
- Commit Version Update:
  - Pushes the updated version information back to the GitLab repository using credentials.

3.2. Dockerfile

Defines how to build the Docker image:
- Uses Amazon Corretto 8 on Alpine Linux for the Java runtime.
- Exposes port `8080`.
- Copies the Maven-built JAR file into the image.
- Sets the working directory to `/usr/app`.
- Specifies the command to run the application using `java -jar`.

3.4. Kubernetes Manifests

Referenced in the pipeline (typically located in the `kubernetes/` directory):
- deployment.yaml: Describes the application's deployment details, such as the number of replicas, the Docker image to use, exposed ports, and labels.
- service.yaml: Defines how the application is exposed within the Kubernetes cluster, typically via a LoadBalancer on port 80 that forwards to the application's internal port 8080.

4. Pipeline Flow

1. Code Commit: Developers push code changes.
2. Jenkins Trigger: Jenkins pipeline starts automatically.
3. Build & Test: Application is built and tested.
4. Dockerization: A Docker image is built and tagged based on the incremented version and build number.
5. Push to ECR: Image is securely pushed to AWS ECR.
6. Deploy to EKS: The application is deployed/updated on the Kubernetes cluster.
7. Version Tracking: The new version is committed to the source repository.

5. Security and Best Practices

- All sensitive credentials (AWS, Docker/ECR, GitLab) are managed securely via Jenkins credentials.
- The pipeline uses dynamic variable injection for image tags and Kubernetes manifests.
- Amazon Corretto and Alpine Linux are used for a slim and secure runtime.

6. Getting Started

1. Clone the repository.
2. Ensure your Jenkins instance is set up with the required credentials (`ecr-credentials`, `jenkins_aws_access_key_id`, `jenkins-aws_secret_access_key`, `gitlab-credentials`).
3. Configure your EKS cluster and ECR repository.
4. Push changes to invoke the Jenkins pipeline and trigger the CI/CD flow.

Note: For the source code, Dockerfile, Jenkinsfile, and Kubernetes manifests, refer to their respective files in the repository.

License
MIT
