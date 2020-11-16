pipeline {
  agent any
  parameters {
        choice(
            choices: ['apply' , 'destroy'],
            description: '',
            name: 'REQUESTED_ACTION')
        booleanParam(name: 'VERIFY_VAULT', defaultValue: false, description: 'Verify vault service by creating user, policy and secrets (exprimental)')
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
        sleep(time:300,unit:"SECONDS")
        script {
        env.ELB_DNS_NAME = sh(script: 'terraform output elb_dns_name', returnStdout: true).trim() 
        env.VAULT_ADDR="http://${ELB_DNS_NAME}:8200/"
        env.CONSUL_ADDR="http://${ELB_DNS_NAME}:8500"
        env.VAULT_STATE = sh( script: '/usr/local/bin/vault status -format yaml | grep initialized | cut -c 14-', returnStdout: true).trim()   
        }
        echo "VAULT_STATE = ${env.VAULT_STATE}"
        sh "vault status"
      }
    }


    stage('Verify Vault') {
      when { 
              expression { params.VERIFY_VAULT == 'true' }
        }
      steps {

      echo "Configure vault"
      script {
          env.ROOT_TOKEN = sh( script: "curl -sf ${CONSUL_ADDR}/v1/kv/service/vault/root-token?raw", returnStdout: true).trim()
      }

      sh "vault login ${env.ROOT_TOKEN}"
      /*
      sh "vault auth enable userpass"
      sh "vault policy write dev-access policy.hcl"
      sh "vault kv put auth/userpass/users/akwa policies=dev-access password=akwa"
      sh "vault login -method=userpass username=akwa password=akwa"
      */
      sh "vault kv put secret/hello foo=world"

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
            echo "Vault successfully deployed"
            echo "To Access VAULT UI : ${env.VAULT_ADDR}"
            echo "To Access Consul UI : ${env.CONSUL_ADDR}"
        }
    }
}
