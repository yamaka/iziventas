import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { Category } from '../../shared/models/category';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class CategoryService {
  // Mock data for demonstration
  private mockCategories: Category[] = [
    { id: '1', name: 'Technology', description: 'All about technology' },
    { id: '2', name: 'Business', description: 'Business and economics news' },
    {
      id: '3',
      name: 'Entertainment',
      description: 'Entertainment and media news',
    },
    { id: '4', name: 'Health', description: 'Health and wellness information' },
  ];

  private categoriesSubject = new BehaviorSubject<Category[]>(
    this.mockCategories
  );

  constructor() {}

  getCategories(): Observable<Category[]> {
    return this.categoriesSubject.asObservable();
  }

  getCategoryById(id: string): Observable<Category | undefined> {
    return this.categoriesSubject.pipe(
      map((categories) => categories.find((cat) => cat.id === id))
    );
  }

  addCategory(category: Category): Observable<Category> {
    const newCategory = {
      ...category,
      id: Date.now().toString(), // Generate a simple ID
    };

    const currentCategories = this.categoriesSubject.value;
    this.categoriesSubject.next([...currentCategories, newCategory]);

    return of(newCategory);
  }

  updateCategory(category: Category): Observable<Category> {
    const currentCategories = this.categoriesSubject.value;
    const index = currentCategories.findIndex((c) => c.id === category.id);

    if (index !== -1) {
      currentCategories[index] = { ...category };
      this.categoriesSubject.next([...currentCategories]);
    }

    return of(category);
  }

  deleteCategory(id: string): Observable<boolean> {
    const currentCategories = this.categoriesSubject.value;
    const filteredCategories = currentCategories.filter((cat) => cat.id !== id);

    if (filteredCategories.length !== currentCategories.length) {
      this.categoriesSubject.next(filteredCategories);
      return of(true);
    }

    return of(false);
  }
}
