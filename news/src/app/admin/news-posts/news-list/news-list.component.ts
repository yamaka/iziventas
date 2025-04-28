import { Component, OnInit, ViewChild } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';

import { NewsService } from '../../../core/services/news.service';
import { CategoryService } from '../../../core/services/category.service';
import { NewsPost } from '../../../shared/models/news-post';
import { Category } from '../../../shared/models/category';

@Component({
  selector: 'app-news-list',
  templateUrl: './news-list.component.html',
  styleUrls: ['./news-list.component.scss'],
})
export class NewsListComponent implements OnInit {
  dataSource = new MatTableDataSource<NewsPost>([]);
  displayedColumns: string[] = [
    'title',
    'category',
    'date',
    'creator',
    'actions',
  ];
  isLoading = true;
  categories: Category[] = [];

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(
    private newsService: NewsService,
    private categoryService: CategoryService,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.loadNewsData();
    this.loadCategories();
  }

  ngAfterViewInit(): void {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;
  }

  loadNewsData(): void {
    this.isLoading = true;
    this.newsService.getPosts().subscribe(
      (posts) => {
        this.dataSource.data = posts;
        this.isLoading = false;
      },
      (error) => {
        console.error('Error loading news posts:', error);
        this.isLoading = false;
        this.showError('Failed to load news posts');
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
    return category ? category.name : 'Unknown';
  }

  applyFilter(event: Event): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();

    if (this.dataSource.paginator) {
      this.dataSource.paginator.firstPage();
    }
  }

  deletePost(id: string): void {
    if (confirm('Are you sure you want to delete this post?')) {
      this.newsService.deletePost(id).subscribe(
        (success) => {
          if (success) {
            this.loadNewsData(); // Refresh the data
            this.snackBar.open('Post deleted successfully', 'Close', {
              duration: 3000,
            });
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

  private showError(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 3000,
      panelClass: ['error-snackbar'],
    });
  }
}
