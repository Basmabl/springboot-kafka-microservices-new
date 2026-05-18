pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
        // ← REMOVED: 'com.checkmarx.jenkins.CxScanConfig' 'CX_CLI'
        // Checkmarx AST Scanner does NOT need a tools declaration
    }

    stages {

        // STEP 1 — Checkout (mandatory before scan)
        stage('Checkout') {
            steps {
                echo '=== Fetching source code from GitHub ==='
                checkout scm
            }
        }

        // STEP 2 — Build common-lib (needed by other services)
        stage('Build common-lib') {
            steps {
                dir('common-lib') {
                    sh 'mvn clean install -DskipTests -Dgpg.skip=true'
                }
            }
        }

        // STEP 3 — Build all services (so Checkmarx can scan compiled code too)
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

        // STEP 4 — Checkmarx AST SAST scan
        stage('Security Scan (Checkmarx AST)') {
            steps {
                echo '=== Checkmarx AST Security Scan ==='
                checkmarxASTScanner(
                    projectName: 'springboot-kafka-microservices-intern',
                    serverUrl: 'https://eu.ast.checkmarx.net/',
                    credentialsId: 'checkmarx-credstesr'
                )
            }
        }

    }

    post {
        success {
            echo '✅ Pipeline succeeded — Checkmarx scan complete'
        }
        failure {
            echo '❌ Pipeline failed — check logs above'
        }
    }
}