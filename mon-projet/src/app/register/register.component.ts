import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  // IMPORTANTE : On ajoute FormsModule pour le lien avec le HTML
  imports: [CommonModule, FormsModule, RouterModule], 
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss'
})
export class RegisterComponent {
  
  // MIROIR EXACT de ton SignUpRequest.java
  registerData = {
    name: '',
    email: '',
    password: '',
    roles: ['CUSTOMER'] // Le Backend attend un Set<String>, donc un tableau []
  };

  constructor(private authService: AuthService, private router: Router) {}

  onRegister() {
    // On appelle la méthode register du service
    this.authService.register(this.registerData).subscribe({
      next: (response) => {
        console.log('Inscription réussie', response);
        alert('Compte créé avec succès !');
        this.router.navigate(['/login']); // On redirige vers la connexion
      },
      error: (err) => {
        console.error('Erreur inscription', err);
        alert('Erreur : Vérifiez que l\'email n\'est pas déjà utilisé.');
      }
    });
  }
}