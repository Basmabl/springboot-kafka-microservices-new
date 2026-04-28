pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Récupératiion du code GitHub ==='
                checkout scm
            }
        }

        stage('Build common-lib') {
            steps {
                echo '=== Build common-lib ==='
                dir('common-lib') {
                    sh 'mvn clean install -DskipTests -Dgpg.skip=true'
                }
            }
        }

        stage('Build Services') {
            steps {
                script {
                    def services = [
                        'service-registry',
                        'api-gateway',
                        'identity-service',
                        'order-service',
                        'payment-service',
                        'product-service',
                        'email-service'
                    ]
                    services.each { svc ->
                        echo "=== Build: ${svc} ==="
                        dir(svc) {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }

        // stage('SonarQube Analysis') {
        //     steps {
        //         script {
        //             def services = [
        //                 'identity-service',
        //                 'order-service',
        //                 'payment-service',
        //                 'product-service',
        //                 'email-service'
        //             ]
        //             withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
        //                 services.each { svc ->
        //                     echo "=== SonarQube: ${svc} ==="
        //                     dir(svc) {
        //                         sh '''mvn sonar:sonar \
        //                             -Dsonar.projectKey=''' + svc + ''' \
        //                             -Dsonar.host.url=http://host.docker.internal:9000 \
        //                             -Dsonar.token=$SONAR_TOKEN'''
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Docker Build') {
            steps {
                echo '=== Build des images Docker ==='
                sh 'docker-compose -p myapp build'
            }
        }
    stage('Security Scan (Trivy)') {
    steps {
        script {
            def services = [
                'identity-service',
                'order-service',
                'payment-service',
                'product-service',
                'email-service',
                'api-gateway',
                'eureka-server'
            ]
            services.each { svc ->
                echo "=== Trivy Scan: ${svc} ==="
                def trivyStatus = sh(
                    script: """
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            -v trivy-cache:/root/.cache/trivy \
                            aquasec/trivy:0.48.3 image \
                            --timeout 20m \
                            --exit-code 1 \
                            --severity HIGH,CRITICAL \
                            springboot-kafka-microservices/${svc}:latest
                    """,
                    returnStatus: true
                )
                if (trivyStatus == 1) {
                    error "❌ Trivy: vulnérabilités CRITICAL/HIGH dans ${svc} !"
                }
            }
        }
    }
}

        stage('Deploy') {
            steps {
                echo '=== Déploiementt ==='
                sh 'docker-compose -p myapp down --remove-orphans || true'
                sh 'docker-compose -p myapp up -d'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline réussi !'
        }
        failure {
            echo '❌ Pipeline échoué !'
        }
    }
}