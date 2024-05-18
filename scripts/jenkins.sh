cat << EOF

pipeline {
    agent {
        label {
            label "${1}"
            customWorkspace "/var/lib/jenkins/workspace/job_name"
        }
    }
    options {
        skipDefaultCheckout()
    }
    parameters {
        choice(
            name: 'Deploy_Through',
            choices: ["Branch", "Image"],
            description: "You wanna deploy through Branch / Image!"
        )
        string(
            name: 'BRANCH',
            defaultValue: '${2}',
            description: 'git branch want to deploy'
        )
        string(
            name: 'image_version',
            defaultValue: 'image',
            description: 'Please left as default or pass image you want to deploy through image.'
        )
        string(
            name: 'COUNTRY_CODE',
            defaultValue: '${3}',
            description: 'Please left as default or pass COUNTRY_CODE you want to deploy through image.'
        )
        string(
            name: 'LANGUAGE_CODE',
            defaultValue: '${4}',
            description: 'Please left as default or pass LANGUAGE_CODE you want to deploy through image.'
        )
        string(
            name: 'APP_VERSION',
            defaultValue: '${5}',
            description: 'Please left as default or pass APP_VERSION you want to deploy through image.'
        )
        choice(
            name: 'Environment',
            choices: ["preprod"],
            description: "Environment!"
        )
        choice(
            name: 'Country',
            choices: ["${3}"],
            description: "Country!"
        )
    }

    stages {
        stage('Git checkout source code') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'CleanBeforeCheckout']],
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: '45650768-eed2-4d32-8f3e-a8ca8257028a', url: 'https://git.yo-digital.com/tv-frontend/web-ui.git']]
                ])
                script {
                    commit_id = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
            }
        }

        stage("set build name") {
            steps {
                script {
                    imageTag = "---"
                    imageTag = imageTag.toLowerCase()
                    currentBuild.displayName = imageTag
                    currentBuild.description = imageTag
                }
            }
        }

        stage('Git checkout K8s code') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'CleanCheckout'], [$class: 'RelativeTargetDirectory', relativeTargetDir: 'devops']],
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: '45650768-eed2-4d32-8f3e-a8ca8257028a', url: 'https://git.yo-digital.com/devops/tv/tv-eks-docker-code.git']]
                ])
            }
        }

        stage('Install Dependencies') {
            when {
                expression { params.Deploy_Through == 'Branch' }
            }
            steps {
                sh "yarn"
            }
        }

        stage('Run Test') {
            when {
                allOf {
                    expression { params.Deploy_Through == 'Branch' }
                    expression { params.SkipTest == 'No' }
                }
            }
            steps {
                sh "yarn test -- -u"
            }
        }

        stage('Build') {
            when {
                expression { params.Deploy_Through == 'Branch' }
            }
            steps {
                sh "${6}"
            }
        }

        stage('Image Build and upload to ECR') {
            when {
                expression { params.Deploy_Through == 'Branch' }
            }
            steps {
                sh '''
                imagename=tv-web-ui
                aws ecr get-login --region eu-central-1 --no-include-email | bash
                ./devops/dtdl_make_ecr_image_nonprod.sh  
                '''
            }
        }

        stage('Setup Prerequisites') {
            steps {
                script {
                    skipRemainingStages = false
                }
            }
        }

        stage('Deploy Preprod') {
            steps {          
                sh '''
                K8sENV=
                imagename=tv-web-ui
                release=--webui
                sed -i "s/COUNTRY_CODE1/\${COUNTRY_CODE}/g" devops/non-prod/\${ENVIRONMENT}-values.yml
                sed -i "s/LANGUAGE_CODE1/\${LANGUAGE_CODE}/g" devops/non-prod/\${ENVIRONMENT}-values.yml
                sed -i "s/APP_VERSION1/\${APP_VERSION}/g" devops/non-prod/\${ENVIRONMENT}-values.yml                    
                sed -i "s/:.*$/:/g" devops/non-prod/\${ENVIRONMENT}-values.yml
                sed -i "s/namespace:.*$/namespace: tv--/g" devops/non-prod/\${ENVIRONMENT}-values.yml
                export KUBECONFIG=/opt/kubernetes/tv-nonprod.yo-digital.com.kubeconfig
                helm upgrade --install \${imagename} devops/non-prod/\${release} --values devops/non-prod/\${ENVIRONMENT}-values.yml -n tv--\${K8sENV}
                '''
            }
        }

        stage('API Health Check') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    sh '''
                    imagename=tvweb-ui
                    sleep 20
                    time=1
                    while [ $time -lt 120 ]
                    do
                        sleep 5
                        time=$((time + 5))
                        httpstatus=$(curl -o /dev/null -s -w "%{http_code}\n" http://your-api-endpoint)
                        response=$(curl -s http://your-api-endpoint)
                        if [ -z "$response" ]
                        then
                            echo "Waiting for service to be up. waited $time sec"
                        elif [ "$response" == "OK" -a "$httpstatus" == 200 ]
                        then
                            echo "Service is UP"
                            exit 0
                        fi
                    done
                    if [ $time -ge 120 ]
                    then
                        echo "Service is not ready"
                        exit 1
                    fi
                    '''
                }
            }
        }
    }

    post {
        success {
            emailext to: "demo@telekom-digital.com", subject: "SUCCESS", body: "Job job_name build build_number\n More info at: build_url"
        }
        failure {
            emailext to: "demo@telekom-digital.com", subject: "FAILURE", body: "Job job_name build build_number\n More info at: build_url"
        }
        always {
            emailext subject: "Scan Report for build",
                      body: "Please find the attached scan report.",
                      attachmentsPattern: '**/report-scan.html',
                      to: "demo@telekom-digital.com"
        }
    }
}
 
EOF