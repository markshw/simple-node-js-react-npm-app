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
        PROJECT = "bitclave-jenkins-ci"
        APP_NAME = "my-app"
        FE_SVC_NAME = "${APP_NAME}-frontend"
        CLUSTER = "jenkins-cd"
        CLUSTER_ZONE = "us-east1-d"
        BRANCH_NAME = "master"
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
                sh 'printenv'
                container('gcloud') {
                sh "PYTHONUNBUFFERED=1 gcloud builds submit -t ${IMAGE_TAG} ."
                }
            }
        }
        stage('Deploy Production') {
        // Production branch
        steps{
            sh("echo here1")
            container('kubectl') {
              // Change deployed image in production to the one we just built
              sh("echo here2")
              sh("kubectl config current-context")
              sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#${IMAGE_TAG}#' ./k8s/production/*.yaml")
              sh("echo here3")
              sh("kubectl cluster-info")
              // step([$class: 'KubernetesEngineBuilder',namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              // step([$class: 'KubernetesEngineBuilder',namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/production', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
              // sh("echo http://`kubectl --namespace=production get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${FE_SVC_NAME}")
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
