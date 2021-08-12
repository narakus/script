pipeline{
    agent any

    environment {
       GIT_ADDR = ""
       GIT_COMMON = ""
       GIT_DOCKERFILE = ""
       GIT_AUTH = ""
       HARBOR_URL = ""
       HARBOR_PROJECT_NAME = ""
       HARBOR_AUTH = ""
       NAMESPACE = ""
       BRANCH = ""
       PROJECT = ""
       TAG = sh (script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
    }

    tools {
        maven 'maven-3.5.2'
        jdk   'java_1.8.0_131'
    }

    parameters {
      choice choices: ['deploy', 'rollback'], description: '请选择操作的种类', name: 'WORK'
    } 

    stages {

        stage('准备'){
            steps{
                script{
                   //pipeline中的when不能直接调用参数化构建里面的参数。需要进行变量赋值。
                   ACTION = "${WORK}"
                }
            }
        }

        stage('执行deploy'){
             when {
              equals expected: 'deploy', 
              actual: ACTION
            }
                      
            
             steps {
                      echo '开始拉取公共代码.....'
                      checkout([$class: 'GitSCM', branches: [[name: "*/${env.branch}"]], extensions: [], userRemoteConfigs: [[credentialsId: "${env.GIT_AUTH}", url: "${env.GIT_COMMON}"]]])

                      echo '开始编译公共代码.....'
                      sh "/data/ops/app/apache-maven-3.5.2/bin/mvn clean install -Dmaven.test.skip=true -U"

                      echo '开始拉取主代码'  
                      checkout([$class: 'GitSCM', branches: [[name: "*/${env.branch}"]], extensions: [], userRemoteConfigs: [[credentialsId: "${env.GIT_AUTH}", url: "${env.GIT_ADDR}"]]]) 
                   
                      echo '开始编译公共代码.....'
                      sh "/data/ops/app/apache-maven-3.5.2/bin/mvn clean install -Dmaven.test.skip=true -U"

                      echo '开始拉取Dockerfile'
                      checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: "${env.GIT_AUTH}", url: "${env.GIT_DOCKERFILE}"]]])

                      //移动tar文件到dockerfile目录 
                      wrap([$class: 'BuildUser']) {
                        script {
                            CHECKOUT_FILENAME=sh(returnStdout: true, script: 'd=`find /data/ops/app/jenkins/workspace/test3/target/ -type f -name "*.tar.gz"  |xargs basename`;echo ${d%.tar.gz}' )
                            echo "CHECKOUT_FILENAME=${CHECKOUT_FILENAME}"
                            //DOCKER_FILENAME="xmh-${env.project}-${CHECKOUT_FILENAME}-docker"
                            //echo "${DOCKER_FILENAME}"
                            //sh "/usr/bin/find ${env.workspace}/target/ -type f -name '*.tar.gz' | xargs -i mv {} ${env.workspace}/${env.DOCKERFILE_FOLDER}/"
                            //test
                            sh "mv ./target/manager-message-center.tar.gz  xmh-pay-docker/xmh-pay-manager-message-center-docker/"
                            
                        }
                      }

                      
                      echo '构建image'
                      sh "cd ./xmh-pay-docker/xmh-pay-manager-message-center-docker/ && sudo docker build -t  ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:${env.TAG} ."
                      //sh "cd ${env.DOCKERFILE_FOLDER} && sudo docker build -t  ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:${env.TAG} ."

                      echo '登录并推送image'
                      withCredentials([usernamePassword(credentialsId: "${env.HARBOR_AUTH}", passwordVariable: 'password', usernameVariable: 'username')]) {
                            sh "sudo docker login -u ${username} -p ${password} ${env.HARBOR_URL}"
                            sh "sudo docker push ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:${env.TAG}"

                            //这里将上版本的latest打tag成rollback ，用于回滚使用
                            sh "sudo docker tag ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:latest ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:rollback" 

                            //这里将新上传的images tag ---> latest，用于生产部署用
                            sh "sudo docker tag ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:${env.TAG}  ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:latest"

                            //这里将tag后的images上传
                            sh "sudo docker push ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:rollback"
                            sh "sudo docker push ${env.HARBOR_URL}/${env.NAMESPACE}/${env.HARBOR_PROJECT_NAME}:latest"

                    }

            }
        }

        stage('部署到PRE环境K8s'){
             when {
              equals expected: 'deploy', 
              actual: ACTION
            }

            steps{
                echo '这里执行kubectl到预发'
            }
        }

        stage('验证后部署到PROD环境K8s'){
             when {
              equals expected: 'deploy', 
              actual: ACTION
            }

         input {
                message "确定要部署到生产环境吗"
                ok "Yes, we should."
                submitter "admin"
                parameters {
                    string(name: 'prod', defaultValue: 'deploy', description: '请在完成pre环境测试后再执行此操作')
                }
        }
        
        steps{
                echo '这里执行kubectl到生产'
            }
        }


        stage('执行rollback'){
            when {
              equals expected: 'rollback', 
              actual: ACTION
            }

            steps{
                echo '这里执行rollback'
            }
        }

        stage('推送构建消息'){

            when {
              equals expected: 'deploy', 
              actual: ACTION
            }

            steps{

                wrap([$class: 'BuildUser']) {
                    script{
                             sh "printenv"
                             env.COMMIT_ID = sh (script: 'git rev-parse --short HEAD ${GIT_COMMIT}', returnStdout: true).trim()
                             sh "/data/ops/scripts/Jenkins-WeChat.py --title=${env.JOB_NAME} --site=${env.JENKINS_URL} --giturl=${env.GIT_ADDR} --build_log=${env.BUILD_URL} --build_status='Successful' --git_commit=${env.COMMIT_ID} --new_tag=jenkins-tag-${env.BUILD_NUMBER} --build_number=${env.BUILD_NUMBER} --build_branch=${env.BRANCH} --build_user=${env.BUILD_USER_ID}"
                            }
                          }
            }

        }


    }  
}
