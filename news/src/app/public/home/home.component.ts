import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { NewsService } from '../../core/services/news.service';
import { CategoryService } from '../../core/services/category.service';
import { AuthService } from '../../core/services/auth.service';
import { NewsPost } from '../../shared/models/news-post';
import { Category } from '../../shared/models/category';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss'],
})
export class HomeComponent implements OnInit {
  newsPosts: NewsPost[] = [];
  categories: Category[] = [];
  featuredPost: NewsPost | null = null;
  isLoading = true;
  isLoggedIn = false;

  constructor(
    private newsService: NewsService,
    private categoryService: CategoryService,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadPosts();
    this.loadCategories();
    this.isLoggedIn = this.authService.isLoggedIn();
  }

  loadPosts(): void {
    this.isLoading = true;
    this.newsService.getPosts().subscribe(
      (posts) => {
        this.newsPosts = posts.sort((a, b) => {
          return new Date(b.date).getTime() - new Date(a.date).getTime();
        });

        // Set the first post as featured if available
        if (this.newsPosts.length > 0) {
          this.featuredPost = this.newsPosts[0];
          // Remove the featured post from the main list
          this.newsPosts = this.newsPosts.slice(1);
        }

        this.isLoading = false;
      },
      (error) => {
        console.error('Error loading posts:', error);
        this.isLoading = false;
      }
    );
  }

  loadCategories(): void {
    this.categoryService.getCategories().subscribe(
      (categories) => {
        this.categories = categories;
      },
      (error) => {
        console.error('Error loading categories:', error);
      }
    );
  }

  getCategoryName(categoryId: string): string {
    const category = this.categories.find((c) => c.id === categoryId);
    return category ? category.name : 'Uncategorized';
  }

  navigateToDetail(postId: string): void {
    this.router.navigate(['/news', postId]);
  }

  navigateToLogin(): void {
    this.router.navigate(['/auth/login']);
  }

  navigateToAdmin(): void {
    this.router.navigate(['/admin']);
  }
}
