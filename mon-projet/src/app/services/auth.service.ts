import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { Observable, tap } from 'rxjs';
@Injectable({
  providedIn: 'root'
})
export class AuthService {
  // L'URL de ta Gateway Docker
//before integration de ecoker file kuber private baseUrl = 'http://localhost:4200/api/v1/auth';
private baseUrl = '/api/v1/auth';

  constructor(private http: HttpClient) { }

  register(data: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/register`, data);
  }

 // auth.service.ts
login(data: any): Observable<any> {
  return this.http.post(`${this.baseUrl}/token`, data, { 
    withCredentials: true // 👈 INDISPENSABLE pour que le navigateur accepte le Cookie
  });
}
}
