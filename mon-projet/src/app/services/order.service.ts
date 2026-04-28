import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { OrderRequestDto } from '../model/order.model';

@Injectable({ providedIn: 'root' })
export class OrderService {
  // 4200 est le port de ton Gateway qui redirige vers order-service
  //private API_URL = 'http://localhost:4200/api/v1/order';
private API_URL = '/api/v1/order';
  constructor(private http: HttpClient) {}

  placeOrder(orderData: OrderRequestDto): Observable<any> {
    // withCredentials: true est CRUCIAL pour envoyer le cookie de session au Backend
    return this.http.post(this.API_URL, orderData, { withCredentials: true });
  }
}