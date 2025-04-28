import { Component, Input } from '@angular/core';

interface NavItem {
  icon: string;
  label: string;
  route: string;
}

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss'],
})
export class SidebarComponent {
  @Input() isOpen = true;

  navItems: NavItem[] = [
    { icon: 'dashboard', label: 'Dashboard', route: '/admin' },
    { icon: 'article', label: 'News Posts', route: '/admin/news' },
    { icon: 'add_circle', label: 'Create News', route: '/admin/news/create' },
    { icon: 'category', label: 'Categories', route: '/admin/categories' },
    { icon: 'public', label: 'View Site', route: '/' },
  ];
}
