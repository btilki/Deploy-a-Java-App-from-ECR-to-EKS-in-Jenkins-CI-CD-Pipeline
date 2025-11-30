#!/usr/bin/env groovy

pipeline {
    agent any  // Run on any available Jenkins agent

    tools {
        maven 'Maven'   // Use Jenkins’ configured Maven installation
    }

    environment {
        DOCKER_REPO_SERVER = '330673547330.dkr.ecr.eu-central-1.amazonaws.com'
        DOCKER_REPO = "${DOCKER_REPO_SERVER}/java-maven-app"  // Full ECR repo path
    }

    stages {

        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'

                    // Parse current pom.xml version and bump incremental (e.g., 1.0.3 -> 1.0.4)
                    sh '''
                        mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\${parsedVersion.majorVersion}.\\${parsedVersion.minorVersion}.\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit
                    '''

                    // Extract new version from pom.xml for tagging Docker image
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]

                    // IMAGE_NAME will look like: 1.0.4-35 (version-buildNumber)
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }

        stage('build app') {
            steps {
                script {
                    echo 'building the application...'

                    // Clean previous builds and package new JAR
                    sh 'mvn clean package'
                }
            }
        }

        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."

                    // Use stored credentials to log into AWS ECR
                    withCredentials([usernamePassword(
                        credentialsId: 'ecr-credentials',
                        passwordVariable: 'PASS',
                        usernameVariable: 'USER'
                    )]) {

                        // Build Docker image using application JAR created above
                        sh "docker build -t ${DOCKER_REPO}:${IMAGE_NAME} ."

                        // Login to ECR (password is auth token produced in Jenkins)
                        sh 'echo $PASS | docker login -u $USER --password-stdin ${DOCKER_REPO_SERVER}'

                        // Push image to repository so Kubernetes can pull it
                        sh "docker push ${DOCKER_REPO}:${IMAGE_NAME}"
                    }
                }
            }
        }

        stage('deploy') {
            environment {
                // Inject AWS credentials for kubectl to access the cluster
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws_secret_access_key')
                APP_NAME = 'java-maven-app'
            }
            steps {
                script {
                    echo 'deploying docker image...'

                    // Replace variables in YAML templates (IMAGE_NAME, APP_NAME, etc.)
                    // then apply the final manifest to the Kubernetes cluster
                    sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f -'
                    sh 'envsubst < kubernetes/service.yaml | kubectl apply -f -'
                }
            }
        }

        stage('commit version update') {
            steps {
                script {
                    // Push updated pom.xml version back to Git
                    withCredentials([usernamePassword(
                        credentialsId: 'gitlab-credentials',
                        passwordVariable: 'PASS',
                        usernameVariable: 'USER'
                    )]) {

                        // Reconfigure Git remote to authenticate with user/pass
                        sh "git remote set-url origin https://${USER}:${PASS}@gitlab.com/twn-devops-bootcamp/latest/11-eks/java-maven-app.git"

                        // Commit new version number
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:jenkins-jobs'  // Push to the branch used by Jenkins
                    }
                }
            }
        }
    }
}
