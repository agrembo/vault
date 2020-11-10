pipeline {
  parameters {
  }
  environment {
    TF_WORKSPACE = 'dev' //Sets the Terraform Workspace
    TF_IN_AUTOMATION = 'true'
  }
  stages {
    stage('Terraform Init') {
      steps {
        sh "${env.TERRAFORM_HOME}/terraform init -input=false"
      }
    }
    stage('Terraform Plan') {
      steps {
        sh "${env.TERRAFORM_HOME}/terraform plan -out=tfplan -input=false '"
      }
    }
    stage('Terraform Apply') {
      steps {
        input 'Apply Plan'
        sh "${env.TERRAFORM_HOME}/terraform apply -input=false tfplan"
      }
    }
    stage('AWSpec Tests') {
      steps {
          sh '''#!/bin/bash -l
 echo "Test Cases"
'''

      }
    }
  }
}#
