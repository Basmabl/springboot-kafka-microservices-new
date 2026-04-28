# Integration Guide - Frontend & Backend

Ce guide explique comment intégrer le frontend Angular avec le backend Spring Microservices.

## 🔗 Configuration et Démarrage

### 1. Démarrer le Backend

```bash
# Terminal 1: Aller au répertoire root du projet
cd spring-microservices-kafka-api-gateway

# Démarrer Docker Compose avec tous les services
docker-compose up -d

# Vérifier les services
docker-compose ps
```

**Services démarrés:**
- 🗄️ MySQL (ports: 3307, 3308, 3309, 3310, 3311)
- 🔴 Redis (port: 6379)
- 🎫 Kafka (port: 9092, 29092)
- 🧩 Service Registry/Eureka (port: 8761)
- 🌐 API Gateway (port: 8080)
- 🛍️ Product Service (port: 8001)
- 📦 Order Service (port: 8002)
- 💳 Payment Service (port: 8003)
- 👤 Identity Service (port: 8004)
- ✉️ Email Service (port: 8005)

### 2. Démarrer le Frontend

```bash
# Terminal 2: Aller au répertoire frontend
cd frontend

# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm start
```

**Frontend accessible à:** `http://localhost:4200`

## 🌉 Architecture d'Intégration

```
┌─────────────────┐
│   Frontend      │ (Angular 17)
│   localhost:4200│
└────────┬────────┘
         │
         │ API Calls
         │ (port 8080)
         ▼
┌─────────────────────┐
│   API Gateway       │
│   localhost:8080    │
└────────┬────────────┘
         │
    ┌────┴───┬──────┬──────┬──────┐
    ▼        ▼      ▼      ▼      ▼
 Products Order Payment Identity Email
 Service  Service Service Service  Service
```

## 🔌 Configuration des URLs

### Frontend

**Fichier:** `frontend/src/environments/environment.ts`

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api/v1'  // API Gateway
};
```

**Production:** `frontend/src/environments/environment.prod.ts`

```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.yourdomain.com/api/v1'  // Your domain
};
```

### Backend CORS

Assurez-vous que le API Gateway accepte les requêtes CORS du frontend.

**Mise à jour requise dans API Gateway configuration:**

```java
@Configuration
public class CorsConfig {
    
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                    .allowedOrigins(
                        "http://localhost:4200",      // Dev
                        "https://yourdomain.com"      // Production
                    )
                    .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                    .allowedHeaders("*")
                    .allowCredentials(true)
                    .maxAge(3600);
            }
        };
    }
}
```

## 📡 Endpoints et Services

### 1. Authentication Service

**Login**
```typescript
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "123",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "role": "USER"
    }
  },
  "status": 200
}
```

**Register**
```typescript
POST /api/v1/auth/register
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

### 2. Products Service

**Get All Products**
```typescript
GET /api/v1/products?page=0&size=12

Response:
{
  "data": {
    "content": [
      {
        "id": "123",
        "name": "Product Name",
        "description": "Description",
        "price": 99.99,
        "stock": 10,
        "imageUrl": "url",
        "categoryId": "cat123"
      }
    ],
    "page": 0,
    "size": 12,
    "totalElements": 100
  },
  "status": 200
}
```

**Get Product by ID**
```typescript
GET /api/v1/products/:id

Response:
{
  "data": {
    "id": "123",
    "name": "Product Name",
    "description": "Description",
    "price": 99.99,
    "stock": 10,
    "imageUrl": "url",
    "variants": [...],
    "attributes": [...]
  },
  "status": 200
}
```

**Get Categories**
```typescript
GET /api/v1/categories

Response:
{
  "data": [
    {
      "id": "cat1",
      "name": "Electronics",
      "description": "Electronic products",
      "children": [...]
    }
  ],
  "status": 200
}
```

### 3. Orders Service

**Place Order**
```typescript
POST /api/v1/order
Authorization: Bearer {token}
Content-Type: application/json

{
  "items": [
    {
      "productId": "prod123",
      "variantId": "var123",
      "quantity": 2,
      "price": 99.99
    }
  ],
  "totalAmount": 199.98,
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Riyadh",
    "state": "Riyadh",
    "postalCode": "12345",
    "country": "Saudi Arabia"
  },
  "billingAddress": {...}
}

Response:
{
  "data": {
    "id": "order123",
    "orderNumber": "ORD-001",
    "status": "PENDING",
    "totalAmount": 199.98,
    "createdAt": "2024-01-01T10:00:00Z"
  },
  "status": 201
}
```

**Get Order by ID**
```typescript
GET /api/v1/order/:id
Authorization: Bearer {token}

Response:
{
  "data": {
    "id": "order123",
    "orderNumber": "ORD-001",
    "status": "CONFIRMED",
    "items": [...],
    "totalAmount": 199.98,
    "paymentStatus": "COMPLETED",
    "shippingAddress": {...},
    "createdAt": "2024-01-01T10:00:00Z"
  },
  "status": 200
}
```

**Cancel Order**
```typescript
POST /api/v1/order/cancel/:id
Authorization: Bearer {token}

Response:
{
  "data": {...},
  "status": 200
}
```

### 4. Payment Service

**Get Payment Status**
```typescript
GET /api/v1/payment/:orderId
Authorization: Bearer {token}

Response:
{
  "data": {
    "id": "pay123",
    "orderId": "order123",
    "amount": 199.98,
    "status": "COMPLETED",
    "paymentMethod": "CARD",
    "transactionId": "txn123",
    "createdAt": "2024-01-01T10:05:00Z"
  },
  "status": 200
}
```

## 🔐 Authentication Flow

1. **Login**
   - User enters credentials
   - Frontend calls `/auth/login`
   - Backend returns JWT token
   - Frontend stores token in localStorage

2. **Token Usage**
   - Frontend includes token in every request header:
   ```
   Authorization: Bearer {jwt_token}
   ```
   - AuthInterceptor adds this automatically

3. **Token Validation**
   - Backend validates token with JWT secret
   - Returns 401 if invalid/expired
   - Frontend redirects to login

4. **Logout**
   - Frontend clears token from localStorage
   - Clears user data
   - Redirects to login page

## 🧪 Testing d'Intégration

### Test Credentials

```
Email: test@example.com
Password: password123
```

### Test Order Flow

1. **Register/Login**
   - Accéder à http://localhost:4200
   - Créer un compte ou se connecter

2. **Browse Products**
   - Aller à `/products`
   - Voir les produits depuis le backend

3. **Add to Cart**
   - Click "Add to Cart" button
   - Cart updated in header

4. **Checkout**
   - Go to `/cart`
   - Click "Proceed to Checkout"
   - Fill address information
   - Select payment method

5. **View Orders**
   - Go to `/orders`
   - See created orders
   - Click to view details

## 📊 Monitoring

### Backend Logs

```bash
# View service logs
docker-compose logs -f api-gateway
docker-compose logs -f product-service
docker-compose logs -f order-service

# Clear all logs
docker-compose logs --tail=0
```

### Database Access

```bash
# MySQL - Order Service
mysql -h 127.0.0.1 -P 3307 -u root -proot order_db

# MySQL - Product Service
mysql -h 127.0.0.1 -P 3310 -u root -proot product_db

# View tables
SHOW TABLES;
SELECT * FROM products;
```

### API Testing

Use Postman or cURL:

```bash
# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Get Products
curl -X GET http://localhost:8080/api/v1/products?page=0&size=12

# Get Token from response and use in next request
curl -X GET http://localhost:8080/api/v1/order/123 \
  -H "Authorization: Bearer {token}"
```

## 🐛 Troubleshooting

### Frontend ne peut pas atteindre le Backend

**Symptômes:**
- CORS errors dans la console
- Network errors en faisant des API calls

**Solutions:**
1. Vérifier que le backend est démarré: `docker-compose ps`
2. Vérifier l'URL API: `environment.ts`
3. Vérifier CORS config dans backend
4. Check firewall/port accessibility

### Base de données non accessible

**Solutions:**
1. Vérifier MySQL est en cours d'exécution: `docker-compose ps`
2. Vérifier le port: `docker-compose.yml`
3. Reset les volumes:
```bash
docker-compose down -v
docker-compose up -d
```

### JWT Token expiration

**Symptômes:**
- 401 Unauthorized errors
- Redirect to login page

**Solutions:**
1. Login again to get new token
2. Implement token refresh mechanism:
```typescript
// Add refresh logic in auth interceptor
if (status === 401) {
  // Try to refresh token
  // If fails, redirect to login
}
```

## 📝 Environment Variables

### Backend (Docker)

Variables définies dans `docker-compose.yml`:
- `MYSQL_ROOT_PASSWORD=root`
- `KAFKA_BROKER_ID=1`
- `REDIS_PORT=6379`

### Frontend

Variables définies dans `environment.ts`:
- `apiUrl`: URL du backend
- `apiTimeout`: Timeout des requêtes
- `logLevel`: Niveau de logging

## 🚀 Deployment

### Production Build

```bash
# Frontend
cd frontend
npm run build:prod

# Output: dist/ecommerce-banking-app/

# Serve with nginx
docker run -p 80:80 -v $(pwd)/dist:/usr/share/nginx/html nginx
```

### Docker Deployment

```dockerfile
# Dockerfile for frontend
FROM node:18 as builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build:prod

FROM nginx:latest
COPY --from=builder /app/dist/ecommerce-banking-app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 📖 Documentation additionnelle

- [Angular Documentation](https://angular.io/docs)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Docker Documentation](https://docs.docker.com/)

---

**Support**: Pour toute question, contactez l'équipe de développement.
