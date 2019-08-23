pipeline {
    agent {
    kubernetes {
      label 'sample-app'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
labels:
  component: ci
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: cd-jenkins
  containers:
  - name: golang
    image: golang:1.10
    command:
    - cat
    tty: true
  - name: nodejs
    image: node:6-alpine
    command:
    - cat
    tty: true
  - name: gcloud
    image: gcr.io/cloud-builders/gcloud
    command:
    - cat
    tty: true
  - name: kubectl
    image: gcr.io/cloud-builders/kubectl
    command:
    - cat
    tty: true
"""
        }
    }
    environment {
        CI = 'true' 
        PROJECT = "jenkins-cd"
        APP_NAME = "my-app"
        FE_SVC_NAME = "${APP_NAME}-frontend"
        CLUSTER = "jenkins-cd"
        CLUSTER_ZONE = "us-east1-d"
        IMAGE_TAG = "gcr.io/${PROJECT}/${APP_NAME}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
        JENKINS_CRED = "${PROJECT}"
    }
    stages {
        // stage('Build') { 
        //     steps {
        //         sh 'echo hello'
        //         container('nodejs') {
        //             sh "npm install"
        //         }
        //     }
        // }
        // stage('Test') { 
        //     steps {
        //         container('nodejs') {
        //             sh './jenkins/scripts/test.sh' 
        //         }
        //     }
        // }
        stage('Build and push image with Container Builder') {
            steps {
                container('gcloud') {
                sh "PYTHONUNBUFFERED=1 gcloud builds submit -t ${IMAGE_TAG} ."
                }
            }
        }
        // stage('Deliver') { 
        //     steps {
        //         container('nodejs') {
        //             sh './jenkins/scripts/deliver.sh' 
        //             input message: 'Finished using the web site? (Click "Proceed" to continue)' 
        //             sh './jenkins/scripts/kill.sh' 
        //         }
        //     }
        // }
    }
}
