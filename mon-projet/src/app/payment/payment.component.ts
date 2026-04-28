import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

// CORRECTION DES CHEMINS (un seul ../ au lieu de deux)
import { CartService } from '../services/cart.service'; 
import { OrderService } from '../services/order.service';

@Component({
  selector: 'app-payment',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './payment.component.html',
  styleUrls: ['./payment.component.scss']
})
export class PaymentComponent {
  total: number = 0;
  paymentSuccess: boolean = false;

  constructor(
    private cartService: CartService, 
    private orderService: OrderService,
    private router: Router
  ) {
    this.total = this.cartService.getTotalPrice();
  }
isLoading: boolean = false;
 
confirmPayment() {
  if (this.isLoading) return;  // ← bloque les doubles clics
  this.isLoading = true;        // ← désactive
  
  const userEmail = localStorage.getItem('userEmail');
  const orderData = {
    orderItems: this.cartService.getCartItems().map((item: any) => ({
      productId: item.id,
      quantity: 1,
      price: item.price
    })),
    paymentMethod: 'CREDIT_CARD',
    status: 'PAID',
    email: userEmail
  };

  this.orderService.placeOrder(orderData).subscribe({
    next: (res: any) => {
      alert("Paiement validé ! Email envoyé à " + userEmail);
      this.cartService.clearCart();
      this.router.navigate(['/products']);
    },
    error: (err: any) => {
      console.error("Erreur commande :", err);
      alert("Échec du paiement.");
      this.isLoading = false;  // ← réactive en cas d'erreur
    }
  });
}
}