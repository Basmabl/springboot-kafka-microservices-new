import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Product } from '../model/product.model';
import { ProductService } from '../services/product.service';
import { CartService } from '../services/cart.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './product-list.component.html',
  styleUrls: ['./product-list.component.scss']
})
export class ProductListComponent implements OnInit {
  products: Product[] = [];

  constructor(
    private productService: ProductService,
    private cartService: CartService,
    private router: Router
  ) {}

  ngOnInit() {
    this.productService.getProducts().subscribe({
      next: (res: any) => this.products = res.data.content,
      error: (err: any) => console.error("Erreur backend", err)
    });
  }

  buyProduct(product: Product) {
    // 1. On l'ajoute au service persistant
    this.cartService.addToCart(product);
    // 2. On change de page vers le panier
    this.router.navigate(['/cart']);
  }
}