import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CartService } from '../services/cart.service';
import { Product } from '../model/product.model';
import { Router } from '@angular/router';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './cart.component.html',
  styleUrls: ['./cart.component.scss']
})
export class CartComponent implements OnInit {
  // 1. DOIT s'appeler 'cartItems' pour ton HTML
  cartItems: Product[] = []; 

  constructor(private cartService: CartService, private router: Router) {}

  ngOnInit() {
    this.loadCart();
  }

  loadCart() {
    // Utilise 'getCartItems()' (qu'on a ajouté au service tout à l'heure)
    this.cartItems = this.cartService.getCartItems();
  }

  // 2. DOIT s'appeler 'total' (getter) pour ton HTML
  get total(): number {
    return this.cartService.getTotalPrice();
  }

  // 3. DOIT s'appeler 'clear' pour ton HTML
  clear() {
    this.cartService.clearCart();
    this.loadCart(); // Rafraîchit la liste
  }

  // 4. DOIT s'appeler 'goToPayment' pour ton HTML
  goToPayment() {
    this.router.navigate(['/payment']);
  }

  removeItem(index: number) {
    this.cartService.removeFromCart(index);
    this.loadCart();
  }
}