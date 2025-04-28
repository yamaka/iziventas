import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';

import { NewsService } from '../../../core/services/news.service';
import { CategoryService } from '../../../core/services/category.service';
import { NewsPost } from '../../../shared/models/news-post';
import { Category } from '../../../shared/models/category';

@Component({
  selector: 'app-news-detail',
  templateUrl: './news-detail.component.html',
  styleUrls: ['./news-detail.component.scss'],
})
export class NewsDetailComponent implements OnInit {
  newsPost: NewsPost | null = null;
  category: Category | null = null;
  isLoading = true;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private newsService: NewsService,
    private categoryService: CategoryService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe((params) => {
      if (params['id']) {
        this.loadPostData(params['id']);
      } else {
        this.router.navigate(['/admin/news']);
      }
    });
  }

  loadPostData(id: string): void {
    this.isLoading = true;
    this.newsService.getPostById(id).subscribe(
      (post) => {
        if (post) {
          this.newsPost = post;
          this.loadCategory(post.categoryId);
        } else {
          this.showError('Post not found');
          this.router.navigate(['/admin/news']);
        }
      },
      (error) => {
        console.error('Error loading post details:', error);
        this.showError('Failed to load post details');
        this.isLoading = false;
      }
    );
  }

  loadCategory(categoryId: string): void {
    this.categoryService.getCategoryById(categoryId).subscribe(
      (category) => {
        this.category = category || null;
        this.isLoading = false;
      },
      (error) => {
        console.error('Error loading category:', error);
        this.isLoading = false;
      }
    );
  }

  onEdit(): void {
    if (this.newsPost?.id) {
      this.router.navigate(['/admin/news/edit', this.newsPost.id]);
    }
  }

  onDelete(): void {
    if (!this.newsPost?.id) {
      return;
    }

    if (confirm('Are you sure you want to delete this post?')) {
      this.newsService.deletePost(this.newsPost.id).subscribe(
        (success) => {
          if (success) {
            this.snackBar.open('Post deleted successfully', 'Close', {
              duration: 3000,
            });
            this.router.navigate(['/admin/news']);
          } else {
            this.showError('Failed to delete post');
          }
        },
        (error) => {
          console.error('Error deleting post:', error);
          this.showError('Error deleting post');
        }
      );
    }
  }

  goBack(): void {
    this.router.navigate(['/admin/news']);
  }

  private showError(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 3000,
      panelClass: ['error-snackbar'],
    });
  }
}
