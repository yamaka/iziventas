import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { User } from '../../shared/models/user';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  currentUser$ = this.currentUserSubject.asObservable();

  // Mock users for demonstration
  private users: User[] = [
    {
      id: '1',
      name: 'Admin User',
      email: 'admin@example.com',
      password: 'admin123',
      role: 'admin',
    },
    {
      id: '2',
      name: 'Editor User',
      email: 'editor@example.com',
      password: 'editor123',
      role: 'editor',
    },
  ];

  constructor(private router: Router) {
    // Check if user is stored in localStorage
    const storedUser = localStorage.getItem('currentUser');
    if (storedUser) {
      this.currentUserSubject.next(JSON.parse(storedUser));
    }
  }

  login(email: string, password: string): Observable<boolean> {
    // Find user
    const user = this.users.find(
      (u) => u.email === email && u.password === password
    );

    if (user) {
      // Remove password before storing
      const { password, ...secureUser } = user;
      this.currentUserSubject.next(secureUser as User);
      localStorage.setItem('currentUser', JSON.stringify(secureUser));
      return of(true);
    }

    return of(false);
  }

  logout(): void {
    localStorage.removeItem('currentUser');
    this.currentUserSubject.next(null);
    this.router.navigate(['/auth/login']);
  }

  isLoggedIn(): boolean {
    return !!this.currentUserSubject.value;
  }

  get currentUser(): User | null {
    return this.currentUserSubject.value;
  }
}
