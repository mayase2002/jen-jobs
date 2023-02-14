#!/usr/bin/env groovy
pipeline {
    agent any
    tools {
        maven 'maven-3.6'
    }
    environment {
        IMAGE_NAME = 'mayase2002/demo-app:java-maven-app-1.0'
    }
    stages {
        stage("build app") {
            steps {
                script {
                    echo "building the application"
                    sh "mvn clean package"
                }
            }
        }
        stage("build image") {
            steps {
                script {
                    echo "building the docker image"
                    withCredentials([usernamePassword(credentialsId: 'docker_cred', usernameVariable: 'USER', passwordVariable: 'PASS')])
                    sh "docker build -t $IMAGE_NAME ."
                    sh "echo $PASS | docker login -u $USER --passwordstdin"
                    sh "docker push $IMAGE_NAME"
                }
            }
        }
        stage("provision server") {
            environment {
                AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                        EC2_PUBLIC_IP = sh (
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()

                    }
                }
            }
        }
        stage("deploy") {
            environment {
                DOCKER_CREDS = credentials('docker_cred')
            }
            steps {
                script {
                    echo "deploying docker image to EC2"
                    echo "${EC2_PUBLIC_IP}"
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"
                    sshagent(['pem_key']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }
        }
    }
}
