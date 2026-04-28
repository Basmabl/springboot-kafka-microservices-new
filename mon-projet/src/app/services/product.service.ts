import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { ApiResponse, PageResponse, Product } from '../model/product.model';

@Injectable({ providedIn: 'root' })
export class ProductService {
//private API_URL = 'http://localhost:4200/api/v1/products';
private API_URL = '/api/v1/products';
  constructor(private http: HttpClient) {}

  getProducts(page: number = 0, size: number = 10): Observable<ApiResponse<PageResponse<Product>>> {
    console.log(`📡 Appel Gateway: ${this.API_URL}?page=${page}&size=${size}`);
    
    return this.http.get<ApiResponse<PageResponse<Product>>>(`${this.API_URL}?page=${page}&size=${size}`)
      .pipe(
        tap({
          next: (res) => console.log('✅ Data reçue du Backend:', res.data.content),
          error: (err) => console.error('❌ Erreur de connexion Gateway:', err)
        })
      );
  }
}