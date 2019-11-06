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
        // PROJECT = "bitclave-base"
        APP_NAME = "my-app"
        FE_SVC_NAME = "${APP_NAME}-frontend"
        // CLUSTER = "base-first"
        CLUSTER = "jenkins-cd"
        CLUSTER_ZONE = "us-central1-f"
        BRANCH_NAME = "master"
        IMAGE_TAG = "gcr.io/bitclave-jenkins-ci/${APP_NAME}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
        JENKINS_CRED = "bitclave-jenkins-ci"
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
            // sh("echo here1")
            container('kubectl') {
              // Change deployed image in production to the one we just built
              sh("echo here2")
              sh("gcloud config get-value account")
              sh ("echo ${IMAGE_TAG}")
              // sh("gcloud container clusters list")
              // sh("gcloud container clusters get-credentials jenkins-cd --zone=us-central1-f")
              // sh("gcloud container clusters list")
              // sh("kubectl config current-context")
              // sh("gcloud container clusters get-credentials base-first --zone us-central1-f --project bitclave-jenkins-ci")
              // sh("gcloud config get-value account")
              sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#gcr.io/bitclave-jenkins-ci/my-app:master.26#' ./k8s/production/*.yaml")
              sh("echo here3")
              // sh("kubectl cluster-info")
              sh 'printenv'
              step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/production', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              sh("echo here4")
              sleep 10 // seconds
              sh("gcloud container clusters get-credentials jenkins-cd --zone us-central1-f --project ${env.PROJECT}")
              sh("echo here5")
              sh("echo `kubectl get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`")
            }
          }
        }
        stage ('Time to access the app') {
          steps {
            echo 'Waiting 3 minutes for deployment to complete prior starting smoke testing'
            sleep 100 // seconds
          }
        }
        stage('Cleanup Production') {
            // Production branch
            steps{
            // sh("echo here1")
            container('kubectl') {
              sh("gcloud container clusters get-credentials jenkins-cd --zone us-central1-f --project ${env.PROJECT}")
              sh("kubectl delete services my-app-backend my-app-frontend")
              sh("kubectl delete deployment my-app-backend-production my-app-frontend-production")
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
