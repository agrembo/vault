pipeline {
  agent any
  parameters {
        choice(
            choices: ['apply' , 'destroy'],
            description: '',
            name: 'REQUESTED_ACTION')
    }
  environment {
    TF_WORKSPACE = 'default'
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
        sh "${env.TERRAFORM_HOME}/terraform apply -input=false tfplan"
        sleep(time:120,unit:"SECONDS")
      }
    }
   
   stage('Terraform Destroy') {
      when {
                  expression { params.REQUESTED_ACTION == 'destroy' }
        }
      steps {
        sh "${env.TERRAFORM_HOME}/terraform destroy -input=false -auto-approve"
      }
    }

  }
  post { 
        always { 
            cleanWs()
        }
    }
}
