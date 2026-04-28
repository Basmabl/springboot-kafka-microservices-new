# =============================================================
# SCRIPT DE RECREATION COMPLETE DU CLUSTER MICROSERVICES
# A executer depuis le dossier racine du projet :
# D:\spring-microservices-kafka-api-gateway\spring-microservices-kafka-api-gateway
# =============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " RECREATION DU CLUSTER MICROSERVICES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ===== ETAPE 1 : Nettoyage =====
Write-Host "[1/9] Suppression des anciens containers..." -ForegroundColor Yellow
docker rm -f microservices-cluster-control-plane microservices-cluster-worker microservices-cluster-worker2 microservices-cluster-worker3 2>$null

Write-Host "[1/9] Suppression du cluster KIND..." -ForegroundColor Yellow
kind delete cluster --name microservices-cluster 2>$null

Start-Sleep -Seconds 5

# ===== ETAPE 2 : Recreation du cluster =====
Write-Host "[2/9] Creation du nouveau cluster KIND..." -ForegroundColor Yellow
kind create cluster --config k8s/kind-config.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR : Echec de creation du cluster. Arret." -ForegroundColor Red
    exit 1
}

Write-Host "Attente que les nodes soient prets..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# ===== ETAPE 3 : Reload des images Docker dans KIND =====
Write-Host "[3/9] Chargement des 7 images Spring Boot dans KIND..." -ForegroundColor Yellow

$images = @(
    "springboot-kafka-microservices/eureka-server:latest",
    "springboot-kafka-microservices/api-gateway:latest",
    "springboot-kafka-microservices/identity-service:latest",
    "springboot-kafka-microservices/order-service:latest",
    "springboot-kafka-microservices/payment-service:latest",
    "springboot-kafka-microservices/product-service:latest",
    "springboot-kafka-microservices/email-service:latest"
)

foreach ($img in $images) {
    Write-Host "  Loading $img..." -ForegroundColor Gray
    kind load docker-image $img --name microservices-cluster
}

# ===== ETAPE 4 : Namespace =====
Write-Host "[4/9] Creation du namespace microservices..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# ===== ETAPE 5 : Secret =====
Write-Host "[5/9] Creation du Secret app-secrets..." -ForegroundColor Yellow
kubectl create secret generic app-secrets -n microservices `
    --from-literal=mysql-password=root `
    --from-literal=mail-host=smtp.gmail.com `
    --from-literal=mail-port=587 `
    --from-literal=mail-username=basmaboulli2003@gmail.com `
    --from-literal=mail-password=zlgziogttpxnxouk `
    --from-literal=cloudinary-cloud-name=none `
    --from-literal=cloudinary-api-key=none `
    --from-literal=cloudinary-api-secret=none

# ===== ETAPE 6 : Infrastructure =====
Write-Host "[6/9] Deploiement de l'infrastructure (MySQL, Kafka, Redis)..." -ForegroundColor Yellow
kubectl apply -f k8s/infrastructure/

Write-Host "Attente des bases de donnees (60s)..." -ForegroundColor Gray
Start-Sleep -Seconds 60

# ===== ETAPE 7 : Microservices =====
Write-Host "[7/9] Deploiement des microservices Spring Boot..." -ForegroundColor Yellow
kubectl apply -f k8s/services/

# ===== ETAPE 8 : NGINX Ingress + patch =====
Write-Host "[8/9] Installation NGINX Ingress Controller..." -ForegroundColor Yellow
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

Write-Host "Attente NGINX (45s)..." -ForegroundColor Gray
Start-Sleep -Seconds 45

Write-Host "Application du patch NGINX..." -ForegroundColor Yellow
kubectl apply -f k8s/nginx-patch.yaml

Write-Host "Application des regles Ingress..." -ForegroundColor Yellow
kubectl apply -f k8s/ingress/ingress.yaml

# ===== ETAPE 9 : Donnees initiales =====
Write-Host "[9/9] Insertion des donnees initiales..." -ForegroundColor Yellow

Write-Host "Attente que MySQL soit pret (60s)..." -ForegroundColor Gray
Start-Sleep -Seconds 60

# Roles
Write-Host "Insertion des roles..." -ForegroundColor Gray
kubectl exec -it deployment/mysql-identity -n microservices -- mysql -uroot -proot user_db -e "INSERT IGNORE INTO roles (name) VALUES ('EMPLOYEE'),('ADMINISTRATOR'),('CUSTOMER');"

# Categories + Produits bancaires
Write-Host "Insertion des produits bancaires..." -ForegroundColor Gray
$sqlProducts = @"
INSERT INTO categories (id, name, version, created_at, updated_at) VALUES
('cat-cards', 'Cartes bancaires', 0, NOW(), NOW()),
('cat-virtual', 'Cartes virtuelles', 0, NOW(), NOW()),
('cat-loans', 'Credits et prets', 0, NOW(), NOW()),
('cat-savings', 'Comptes epargne', 0, NOW(), NOW());

INSERT INTO products (id, name, description, price, discount, image_url, version, created_at, updated_at) VALUES
('prod-1', 'Carte Visa Classic', 'Carte standard quotidien', 30.00, 0.00, 'https://cdn-icons-png.flaticon.com/512/179/179457.png', 0, NOW(), NOW()),
('prod-2', 'Carte Visa Gold', 'Carte premium avec assurances', 120.00, 10.00, 'https://cdn-icons-png.flaticon.com/512/179/179431.png', 0, NOW(), NOW()),
('prod-3', 'Carte Mastercard World', 'Carte internationale', 250.00, 20.00, 'https://cdn-icons-png.flaticon.com/512/349/349228.png', 0, NOW(), NOW()),
('prod-4', 'Carte virtuelle e-commerce', 'Carte securisee online', 0.00, 0.00, 'https://cdn-icons-png.flaticon.com/512/657/657093.png', 0, NOW(), NOW()),
('prod-5', 'Carte virtuelle prepayee', 'Rechargeable', 5.00, 0.00, 'https://cdn-icons-png.flaticon.com/512/2953/2953962.png', 0, NOW(), NOW()),
('prod-6', 'Credit personnel', 'Pret 1000 a 50000', 0.00, 0.00, 'https://cdn-icons-png.flaticon.com/512/2830/2830289.png', 0, NOW(), NOW()),
('prod-7', 'Compte epargne plus', 'Livret 3.5 pourcent', 0.00, 0.00, 'https://cdn-icons-png.flaticon.com/512/3135/3135679.png', 0, NOW(), NOW());

INSERT INTO product_variants (sku, price, discount, stock_quantity, reorder_level, product_id) VALUES
('SKU-P1', 30.00, 0, 100, 10, 'prod-1'),
('SKU-P2', 120.00, 10, 100, 10, 'prod-2'),
('SKU-P3', 250.00, 20, 100, 10, 'prod-3'),
('SKU-P4', 0, 0, 100, 10, 'prod-4'),
('SKU-P5', 5.00, 0, 100, 10, 'prod-5'),
('SKU-P6', 0, 0, 100, 10, 'prod-6'),
('SKU-P7', 0, 0, 100, 10, 'prod-7');
"@

kubectl exec -it deployment/mysql-product -n microservices -- mysql -uroot -proot product_db -e $sqlProducts

# Surcharge topic Kafka
Write-Host "Configuration du topic Kafka..." -ForegroundColor Gray
kubectl set env deployment/order-service -n microservices SPRING_KAFKA_CREATE-ORDER-TOPIC_NAME=order_topics

# ===== Verification finale =====
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " VERIFICATION FINALE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

kubectl get pods -n microservices

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " CLUSTER PRET !" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Test : curl http://localhost/api/v1/products -UseBasicParsing" -ForegroundColor Cyan
Write-Host ""
