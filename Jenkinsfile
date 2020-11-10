pipeline {
  agent any
  parameters {
        choice(
            choices: ['apply' , 'destroy'],
            description: '',
            name: 'REQUESTED_ACTION')
    }
  environment {
    TF_WORKSPACE = 'dev' //Sets the Terraform Workspace
    TF_IN_AUTOMATION = 'true'
    TERRAFORM_HOME  = '/usr/local/bin/'
  }
  stages {
    stage('Terraform Init') {
      steps {
        sh "${env.TERRAFORM_HOME}/terraform init -input=false"
      }
    }
    stage('Terraform Plan') {
      steps {
        sh "${env.TERRAFORM_HOME}/terraform plan -out=tfplan -input=false"
      }
    }
    stage('Terraform Apply') {
      when { 
                  expression { params.REQUESTED_ACTION == 'apply' }
        }
      steps {
        input 'Apply Plan'
        sh "${env.TERRAFORM_HOME}/terraform apply -input=false tfplan"
      }
    }
   
   stage('Terraform Destroy') {
      when {
                  expression { params.REQUESTED_ACTION == 'destroy' }
        }
      steps {
        input 'Destroy Plan'
        sh "${env.TERRAFORM_HOME}/terraform destroy -input=false tfplan"
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
}
