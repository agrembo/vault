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
        script {
        env.ELB_DNS_NAME = sh(script: 'terraform output elb_dns_name', returnStdout: true).trim() 
        env.VAULT_ADDR="http://${ELB_DNS_NAME}:8200/"
        env.CONSUL_ADDR="http://${ELB_DNS_NAME}:8500"
        env.VAULT_STATE = sh( script: '/usr/local/bin/vault status -format yaml | grep initialized | cut -c 14-', returnStdout: true).trim()   
        }
        echo "VAULT_STATE = ${env.VAULT_STATE}"
      }
    }

    stage('Vault Init') {
      when { 
              expression { env.VAULT_STATE == 'false' }
        }
      steps {
        echo "VAULT_ADDR = ${env.VAULT_ADDR}"
        echo "Initializing VAULT"
        sh "vault operator init | tee vault.init"
        sh "for i in `cat vault.init | grep '^Unseal' | awk '{print \$4}'` ; do vault operator unseal \$i ; done"
        echo "Store vault unseal and root key in consul"
        sh "COUNTER=1 ; for i in `cat vault.init | grep '^Unseal' | awk '{print \$4}'` ; do curl -fX PUT ${CONSUL_ADDR}/v1/kv/service/vault/unseal-key-\$COUNTER -d \$i ;  COUNTER=\$((COUNTER + 1)) ; done"
        script {
          env.ROOT_TOKEN = sh(script: "cat vault.init | grep '^Initial' | awk '{print \$4}'", returnStdout: true )
        }
        echo "ROOT_TOKEN = ${ROOT_TOKEN}"
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
