import { Injectable } from '@angular/core';
import { Product } from '../model/product.model';
import { BehaviorSubject } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class CartService {
  private cartItems: Product[] = [];
  
  // Observable pour mettre à jour le badge du panier en temps réel partout dans l'app
  private cartCount = new BehaviorSubject<number>(0);
  cartCount$ = this.cartCount.asObservable();

  constructor() {
    // Récupération automatique au démarrage de l'application
    const savedCart = localStorage.getItem('mon_panier');
    if (savedCart) {
      this.cartItems = JSON.parse(savedCart);
      this.cartCount.next(this.cartItems.length);
    }
  }

  // Retourne les produits actuels
  getCartItems(): Product[] {
    return this.cartItems;
  }

  // Calcul du montant total pour le paiement
  getTotalPrice(): number {
    return this.cartItems.reduce((acc, p) => acc + p.price, 0);
  }

  // Ajout d'un produit et sauvegarde immédiate
  addToCart(product: Product) {
    this.cartItems.push(product);
    this.saveCart();
  }

  // Suppression d'un article précis
  removeFromCart(index: number) {
    this.cartItems.splice(index, 1);
    this.saveCart();
  }

  // Vider le panier (appelé après un paiement réussi)
  clearCart() {
    this.cartItems = [];
    this.saveCart();
  }

  // Centralisation de la sauvegarde pour éviter la répétition de code
  private saveCart() {
    localStorage.setItem('mon_panier', JSON.stringify(this.cartItems));
    this.cartCount.next(this.cartItems.length);
  }
}