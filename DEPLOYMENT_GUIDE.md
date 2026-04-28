# E-Commerce Banking App - Deployment Guide

## 🚀 Production Deployment

### Options de Deployment

#### Option 1: Nginx + Docker

```dockerfile
# Dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Build and run
docker build -t ecommerce-app .
docker run -p 80:80 ecommerce-app
```

#### Option 2: Docker Compose

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      - NGINX_HOST=yourdomain.com
      - NGINX_PORT=80
    depends_on:
      - backend

  backend:
    # Your existing backend services
```

#### Option 3: AWS S3 + CloudFront

```bash
# Build the app
npm run build

# Upload to S3
aws s3 sync dist/ecommerce-banking-app s3://your-bucket-name --delete

# Create CloudFront distribution for CDN
```

#### Option 4: Vercel/Netlify

```bash
# Deploy to Vercel
npm i -g vercel
vercel

# Deploy to Netlify
npm i -g netlify-cli
netlify deploy
```

### Configuration de Production

#### 1. Update Environment

**frontend/src/environments/environment.prod.ts**
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.yourdomain.com/api/v1'
};
```

#### 2. Build Optimization

```bash
# Production build with optimization
npm run build -- --configuration production

# Check bundle size
npm run build -- --stats-json
npx webpack-bundle-analyzer dist/ecommerce-banking-app/stats.json
```

#### 3. Security Headers

**nginx.conf**
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # HTTPS redirect
    if ($scheme != "https") {
        return 301 https://$server_name$request_uri;
    }

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(?:js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 4. HTTPS Configuration

```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/ssl/certs/yourdomain.crt;
    ssl_certificate_key /etc/ssl/private/yourdomain.key;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
}
```

### Performance Optimization

#### 1. Image Optimization

```bash
# Install image optimization tool
npm install --save-dev imagemin-webpack-plugin

# Optimize images
npx imagemin src/assets/images --out-dir=src/assets/images
```

#### 2. Lazy Loading

```typescript
// Already implemented in app.routes.ts using:
loadComponent: () => import('./feature/component').then(m => m.Component)
loadChildren: () => import('./feature/routes').then(m => m.FEATURE_ROUTES)
```

#### 3. Code Splitting

Automatically handled by Angular with lazy loading routes.

#### 4. Service Workers

```bash
# Generate service worker config
ng add @angular/service-worker

# Install dependencies
npm install
```

### Monitoring & Logging

#### 1. Error Tracking

```typescript
// Install Sentry
npm install --save @sentry/angular

// Configure in main.ts
import * as Sentry from "@sentry/angular";

Sentry.init({
  dsn: "YOUR_SENTRY_DSN",
  environment: "production",
  tracesSampleRate: 1.0,
});
```

#### 2. Analytics

```typescript
// Google Analytics
npm install --save @angular/google-analytics

// Or custom analytics
// Track page views, user actions, etc.
```

#### 3. Logging

```bash
# Use Winston or similar for backend/server logging
# Frontend: Use browser console + Sentry for errors
```

### CI/CD Pipeline

#### GitHub Actions Example

**.github/workflows/deploy.yml**
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: npm install
    
    - name: Build
      run: npm run build
    
    - name: Deploy to AWS S3
      run: |
        aws s3 sync dist/ecommerce-banking-app s3://${{ secrets.AWS_BUCKET }}
    
    - name: Invalidate CloudFront
      run: aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_DISTRIBUTION }} --paths "/*"
```

### Scaling & Load Balancing

```nginx
# Load balancer configuration
upstream backend {
    server api1.yourdomain.com;
    server api2.yourdomain.com;
    server api3.yourdomain.com;
}

server {
    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Database Backup & Recovery

```bash
# Backup all MySQL databases
docker-compose exec mysql-product-service mysqldump -u root -p'root' --all-databases > backup.sql

# Restore
docker-compose exec -T mysql-product-service mysql -u root -p'root' < backup.sql
```

### Maintenance & Updates

```bash
# Check for security vulnerabilities
npm audit

# Update dependencies
npm update

# Update major versions (carefully)
npm upgrade
```

## 📊 Checklist de Déploiement

- [ ] Environment variables configurées
- [ ] HTTPS activé
- [ ] Security headers configurés
- [ ] CDN configuré
- [ ] Cache enabled
- [ ] Backup strategie définie
- [ ] Monitoring setup
- [ ] Logging actif
- [ ] CI/CD pipeline créé
- [ ] Load balancing configuré
- [ ] SSL certificates valides
- [ ] DNS configuré correctement
- [ ] Performance optimisée
- [ ] Tests en production effectués

## 🎯 Objectifs de Performance

| Métrique | Cible |
|----------|-------|
| First Contentful Paint (FCP) | < 1.8s |
| Largest Contentful Paint (LCP) | < 2.5s |
| Cumulative Layout Shift (CLS) | < 0.1 |
| Time to Interactive (TTI) | < 3.8s |
| Bundle Size | < 500KB |

## 📞 Support en Production

- Monitor error rates
- Respond to alerts quickly
- Have rollback plan ready
- Maintain backup copies
- Document all changes
