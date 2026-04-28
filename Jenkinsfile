pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }

    environment {
        CLUSTER_NAME = 'microservices-cluster'
        NAMESPACE    = 'microservices'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Récupération du code GitHub ==='
                checkout scm
            }
        }

        stage('Build common-lib') {
            steps {
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

        stage('Docker Build Backend') {
            steps {
                echo '=== Build images Docker backend ==='
                sh 'docker-compose -p myapp build'
            }
        }

        stage('Docker Build Frontend') {
            steps {
                echo '=== Build image Docker frontend ==='
                dir('mon-projet') {
                    sh 'docker build -t springboot-kafka-microservices/frontend:latest .'
                }
            }
        }

        stage('Security Scan Trivy') {
    steps {
        script {
            def images = [
                'identity-service',
                'order-service',
                'payment-service',
                'product-service',
                'email-service',
                'api-gateway',
                'eureka-server',
                'frontend'
            ]
            images.each { img ->
                echo "=== Trivy Scan: ${img} ==="
                def status = sh(
                    script: """
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            -v trivy-cache:/root/.cache/trivy \
                            aquasec/trivy:0.48.3 image \
                            --timeout 20m \
                            --exit-code 1 \
                            --severity HIGH,CRITICAL \
                            --scanners vuln \
                            --skip-java-db-update \
                            springboot-kafka-microservices/${img}:latest
                    """,
                    returnStatus: true
                )
                if (status == 1) {
                    error "Trivy: vulnerabilites CRITICAL/HIGH dans ${img}"
                }
            }
        }
    }
}
        stage('Load Images in KIND') {
            steps {
                script {
                    def images = [
                        'springboot-kafka-microservices/eureka-server:latest',
                        'springboot-kafka-microservices/api-gateway:latest',
                        'springboot-kafka-microservices/identity-service:latest',
                        'springboot-kafka-microservices/order-service:latest',
                        'springboot-kafka-microservices/payment-service:latest',
                        'springboot-kafka-microservices/product-service:latest',
                        'springboot-kafka-microservices/email-service:latest',
                        'springboot-kafka-microservices/frontend:latest'
                    ]
                    images.each { img ->
                        echo "=== Kind load: ${img} ==="
                        sh "kind load docker-image ${img} --name ${CLUSTER_NAME}"
                    }
                }
            }
        }

        stage('Setup NGINX Ingress') {
            steps {
                script {
                    def nginxExists = sh(
                        script: "kubectl get deployment ingress-nginx-controller -n ingress-nginx 2>/dev/null",
                        returnStatus: true
                    )

                    if (nginxExists != 0) {
                        echo '=== Installation NGINX Ingress ==='
                        sh """
                            kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
                        """

                        echo '=== Attente NGINX Running ==='
                        sh """
                            kubectl wait --namespace ingress-nginx \
                                --for=condition=ready pod \
                                --selector=app.kubernetes.io/component=controller \
                                --timeout=180s
                        """

                        echo '=== Patch NGINX sur control-plane ==='
                        sh """
                            kubectl patch deployment ingress-nginx-controller \
                                -n ingress-nginx \
                                --type=json \
                                --patch-file k8s/nginx-patch-json.json
                        """

                        echo '=== Suppression webhook ==='
                        sh """
                            kubectl delete validatingwebhookconfiguration \
                                ingress-nginx-admission 2>/dev/null || true
                        """

                        echo '=== Attente NGINX apres patch ==='
                        sh """
                            kubectl wait --namespace ingress-nginx \
                                --for=condition=ready pod \
                                --selector=app.kubernetes.io/component=controller \
                                --timeout=180s
                        """
                    } else {
                        echo '=== NGINX deja installe, skip ==='
                    }
                }
            }
        }

        stage('Deploy Kubernetes') {
            steps {
                echo '=== Apply namespace ==='
                sh "kubectl apply -f k8s/namespace.yaml"

                echo '=== Deploy infrastructure ==='
                sh "kubectl apply -f k8s/infrastructure/"

                echo '=== Attente infrastructure (30s) ==='
                sh "sleep 30"

                echo '=== Deploy microservices ==='
                sh "kubectl apply -f k8s/services/"

                echo '=== Deploy frontend ==='
                sh "kubectl apply -f k8s/frontend.yaml"

                echo '=== Deploy Ingress ==='
                sh "kubectl apply -f k8s/ingress/ingress.yaml"

                echo '=== Deploy Istio config ==='
                sh "kubectl apply -f k8s/istio/"
            }
        }

        stage('Rollout Restart') {
            steps {
                script {
                    def deployments = [
                        'api-gateway',
                        'identity-service',
                        'order-service',
                        'payment-service',
                        'product-service',
                        'email-service',
                        'service-registry',
                        'frontend'
                    ]
                    deployments.each { dep ->
                        echo "=== Restart: ${dep} ==="
                        sh "kubectl rollout restart deployment/${dep} -n ${NAMESPACE}"
                    }
                }
            }
        }

        stage('Verify') {
            steps {
                echo '=== Attente que tous les pods soient Ready ==='
                sh """
                    kubectl wait --for=condition=ready pod \
                        --all -n ${NAMESPACE} \
                        --timeout=300s
                """

                echo '=== Etat final des pods ==='
                sh "kubectl get pods -n ${NAMESPACE}"

                echo '=== Etat Ingress ==='
                sh "kubectl get ingress -n ${NAMESPACE}"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline reussi — app disponible sur http://localhost'
        }
        failure {
            echo '❌ Pipeline echoue'
            sh "PATH=/usr/local/bin:$PATH kubectl get pods -n ${NAMESPACE}"
            sh "PATH=/usr/local/bin:$PATH kubectl get events -n ${NAMESPACE} --sort-by=.lastTimestamp | tail -20"
    
        }
    }
}