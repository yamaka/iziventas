import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';

import { NewsService } from '../../../core/services/news.service';
import { CategoryService } from '../../../core/services/category.service';
import { AuthService } from '../../../core/services/auth.service';
import { NewsPost } from '../../../shared/models/news-post';
import { Category } from '../../../shared/models/category';

@Component({
  selector: 'app-news-form',
  templateUrl: './news-form.component.html',
  styleUrls: ['./news-form.component.scss'],
})
export class NewsFormComponent implements OnInit {
  newsForm!: FormGroup;
  categories: Category[] = [];
  isEditMode = false;
  postId: string | null = null;
  isLoading = false;
  submitAttempted = false;

  constructor(
    private fb: FormBuilder,
    private newsService: NewsService,
    private categoryService: CategoryService,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.initializeForm();
    this.loadCategories();

    // Check if we're in edit mode
    this.route.params.subscribe((params) => {
      if (params['id']) {
        this.postId = params['id'];
        this.isEditMode = true;
        this.loadPostData(this.postId);
      }
    });
  }

  initializeForm(): void {
    this.newsForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(5)]],
      content: ['', [Validators.required, Validators.minLength(20)]],
      categoryId: ['', Validators.required],
      imageUrl: [''],
    });
  }

  loadCategories(): void {
    this.categoryService.getCategories().subscribe(
      (categories) => {
        this.categories = categories;
      },
      (error) => {
        console.error('Error loading categories:', error);
        this.showError('Failed to load categories');
      }
    );
  }

  loadPostData(id: string): void {
    this.isLoading = true;
    this.newsService.getPostById(id).subscribe(
      (post) => {
        if (post) {
          this.newsForm.patchValue({
            title: post.title,
            content: post.content,
            categoryId: post.categoryId,
            imageUrl: post.imageUrl || '',
          });
        } else {
          this.showError('Post not found');
          this.router.navigate(['/admin/news']);
        }
        this.isLoading = false;
      },
      (error) => {
        console.error('Error loading post data:', error);
        this.showError('Failed to load post data');
        this.isLoading = false;
      }
    );
  }

  onSubmit(): void {
    this.submitAttempted = true;

    if (this.newsForm.invalid) {
      return;
    }

    this.isLoading = true;
    const formData = this.newsForm.value;
    const currentUser = this.authService.currentUser;

    const newsPost: NewsPost = {
      ...formData,
      creator: currentUser?.name || 'Unknown',
      date: new Date(),
    };

    if (this.isEditMode && this.postId) {
      // Update existing post
      newsPost.id = this.postId;
      this.newsService.updatePost(newsPost).subscribe(
        (updatedPost) => {
          this.showSuccess('Post updated successfully');
          this.router.navigate(['/admin/news']);
          this.isLoading = false;
        },
        (error) => {
          console.error('Error updating post:', error);
          this.showError('Failed to update post');
          this.isLoading = false;
        }
      );
    } else {
      // Create new post
      this.newsService.addPost(newsPost).subscribe(
        (newPost) => {
          this.showSuccess('Post created successfully');
          this.router.navigate(['/admin/news']);
          this.isLoading = false;
        },
        (error) => {
          console.error('Error creating post:', error);
          this.showError('Failed to create post');
          this.isLoading = false;
        }
      );
    }
  }

  cancel(): void {
    this.router.navigate(['/admin/news']);
  }

  private showSuccess(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 3000,
      panelClass: ['success-snackbar'],
    });
  }

  private showError(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 3000,
      panelClass: ['error-snackbar'],
    });
  }
}
