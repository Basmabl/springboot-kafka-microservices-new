import { Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { RegisterComponent } from './register/register.component';
import { ProductListComponent } from './product-list/product-list.component';
import { PaymentComponent } from './payment/payment.component'; 
import { CartComponent } from './cart/cart.component';
import { authGuard } from './guards/auth.guard';
export const routes: Routes = [
  // 1. Authentification
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },

  // 2. Catalogue et Panier
  { path: 'products', component: ProductListComponent },
  { path: 'cart', component: CartComponent, canActivate: [authGuard] },
{ path: 'payment', component: PaymentComponent, canActivate: [authGuard] },
  // 4. Redirection par défaut : On affiche d'abord les produits
 

  // 5. Route "Wildcard" : Si l'utilisateur tape n'importe quoi, retour aux produits
  { path: '**', redirectTo: 'login' }
];