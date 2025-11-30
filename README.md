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

Defines the CI/CD pipeline:

```groovy
pipeline {
    agent any

    environment {
        // AWS credentials stored securely in Jenkins credentials store
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws_secret_access_key')

        // Amazon ECR repository URI (replace placeholders with actual values)
        ECR_REPO = 'YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/YOUR_ECR_REPO'

        // File used for versioning (Maven project)
        VERSION_FILE = 'pom.xml'
    }

    stages {

        stage('Increment Version') {
            steps {
                // Automatically increment the version stored in pom.xml
                // Uses Maven Versions plugin to bump the last digit
                // Appends Jenkins BUILD_NUMBER for unique Docker tagging
                sh 'mvn versions:set -DnewVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStandardOutput | awk -F. '\''{$NF+=1; OFS="."; print $0}'\'')-$BUILD_NUMBER'
            }
        }

        stage('Build App') {
            steps {
                // Clean previous artifacts and package the application
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image & Push to ECR') {
            steps {
                // Authenticate Docker with ECR
                // Build Docker image using BUILD_NUMBER as tag
                // Push image to ECR repository
                sh '''
                    $(aws ecr get-login --no-include-email --region YOUR_REGION)
                    docker build -t $ECR_REPO:$BUILD_NUMBER .
                    docker push $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                // Export Docker image tag for use in Kubernetes manifests
                // envsubst replaces environment variables in manifest templates
                // Apply updated Deployment and Service to EKS cluster
                sh '''
                    export IMAGE_TAG=$BUILD_NUMBER
                    envsubst < kubernetes/deployment.yaml | kubectl apply -f -
                    envsubst < kubernetes/service.yaml | kubectl apply -f -
                '''
            }
        }

        stage('Commit Version Update') {
            steps {
                // Commit updated pom.xml back to Git repo using stored credentials
                withCredentials([usernamePassword(credentialsId: 'gitlab-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh '''
                        git config user.name "$GIT_USERNAME"
                        git config user.email "your-email@example.com"
                        git add $VERSION_FILE
                        git commit -m "Incremented version to $BUILD_NUMBER"
                        git push https://$GIT_USERNAME:$GIT_PASSWORD@gitlab.com/YOUR_NAMESPACE/YOUR_REPO.git HEAD:main
                    '''
                }
            }
        }

    }
}

```

---

### 3.2. Dockerfile

```dockerfile
FROM amazoncorretto:8-alpine
WORKDIR /usr/app
COPY target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

---

### 3.4. Kubernetes Manifests

#### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-boot-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: spring-boot-app
  template:
    metadata:
      labels:
        app: spring-boot-app
    spec:
      containers:
      - name: spring-boot-app
        image: ${ECR_REPO}:${IMAGE_TAG}
        ports:
        - containerPort: 8080
```

#### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: spring-boot-app-service
spec:
  type: LoadBalancer
  selector:
    app: spring-boot-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

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
