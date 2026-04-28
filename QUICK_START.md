# 🚀 Démarrage Rapide

Une solution complète d'e-commerce avec interface profession de style bancaire.

## ✅ Checklist Rapide

### Backend
- [ ] Installer Docker & Docker Compose
- [ ] Cloner le repo
- [ ] Démarrer: `docker-compose up -d`
- [ ] Vérifier: `docker-compose ps`

### Frontend
- [ ] Installer Node.js 18+
- [ ] `cd frontend`
- [ ] `npm install`
- [ ] `npm start`
- [ ] Accéder: `http://localhost:4200`

## 📱 Utiliser l'Application

1. **Créer un Compte**
   - Cliquer sur "Créer un compte"
   - Remplir les informations
   - Cliquer "S'inscrire"

2. **Se Connecter**
   - Entrer email/mot de passe
   - Cliquer "Connexion"

3. **Parcourir les Produits**
   - Aller à "Produits"
   - Cliquer sur un produit
   - "Ajouter au panier"

4. **Passer une Commande**
   - Aller au "Panier"
   - Vérifier les articles
   - "Passer la commande"
   - Remplir adresse de livraison
   - Sélectionner méthode de paiement
   - "Valider"

5. **Suivre les Commandes**
   - Aller à "Mes Commandes"
   - Cliquer sur une commande
   - Voir le statut et les détails

## 🔧 Configuration

### URLs des Services

```yaml
API Gateway:     http://localhost:8080
Frontend:        http://localhost:4200
Service Registry: http://localhost:8761
Kafka:           localhost:9092, localhost:29092
Redis:           localhost:6379
```

## 📧 Données de Test

```
Email: test@example.com
Password: password123
```

## 🐛 Aide

Pour voir les logs:
```bash
docker-compose logs -f
```

Pour arrêter:
```bash
docker-compose down
```

---

[📖 Lire la Documentation Complète](FRONTEND_INTEGRATION_GUIDE.md)
