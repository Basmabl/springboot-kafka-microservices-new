# ===== STAGE 1 : Build Angular =====
FROM node:18-alpine AS builder

WORKDIR /app

# Copie les fichiers de dépendances d'abord (cache Docker)
COPY package*.json ./

# Installe les dépendances
RUN npm install --legacy-peer-deps

# Copie tout le code Angular
COPY . .

# Compile en production (génère le dossier dist/)
RUN npm run build -- --configuration production

# ===== STAGE 2 : Servir avec NGINX =====
FROM nginx:1.27-alpine

# Supprime la config NGINX par défaut
RUN rm /etc/nginx/conf.d/default.conf

# Copie notre config NGINX custom
COPY nginx.conf /etc/nginx/conf.d/

# Copie les fichiers compilés depuis le stage 1
COPY --from=builder /app/dist/mon-projet/browser /usr/share/nginx/html

# Expose le port 80 (HTTP standard)
EXPOSE 80

# Démarre NGINX en mode foreground
CMD ["nginx", "-g", "daemon off;"]