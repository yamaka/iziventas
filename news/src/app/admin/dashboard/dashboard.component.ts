import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { User } from '../../shared/models/user';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss'],
})
export class DashboardComponent implements OnInit {
  currentUser: User | null = null;
  isSidenavOpen = true;

  menuItems = [
    { icon: 'dashboard', label: 'Dashboard', route: '/admin' },
    { icon: 'article', label: 'News Posts', route: '/admin/news' },
    { icon: 'add_circle', label: 'Create News', route: '/admin/news/create' },
    { icon: 'category', label: 'Categories', route: '/admin/categories' },
  ];

  constructor(private authService: AuthService, private router: Router) {}

  ngOnInit(): void {
    this.currentUser = this.authService.currentUser;
  }

  toggleSidenav(): void {
    this.isSidenavOpen = !this.isSidenavOpen;
  }

  logout(): void {
    this.authService.logout();
  }
}
