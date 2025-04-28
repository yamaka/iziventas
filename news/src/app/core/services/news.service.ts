import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { NewsPost } from '../../shared/models/news-post';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class NewsService {
  // Mock data for demonstration
  private mockPosts: NewsPost[] = [
    {
      id: '1',
      title: 'New Angular Features',
      content:
        'Angular has released exciting new features in its latest version...',
      date: new Date('2025-04-15'),
      creator: 'Admin User',
      categoryId: '1',
      imageUrl: 'https://via.placeholder.com/800x400',
    },
    {
      id: '2',
      title: 'Web Development Trends 2025',
      content:
        'The web development landscape continues to evolve with new technologies...',
      date: new Date('2025-04-20'),
      creator: 'Editor User',
      categoryId: '2',
      imageUrl: 'https://via.placeholder.com/800x400',
    },
  ];

  private postsSubject = new BehaviorSubject<NewsPost[]>(this.mockPosts);

  constructor() {}

  getPosts(): Observable<NewsPost[]> {
    return this.postsSubject.asObservable();
  }

  getPostById(id: string): Observable<NewsPost | undefined> {
    return this.postsSubject.pipe(
      map((posts) => posts.find((post) => post.id === id))
    );
  }

  addPost(post: NewsPost): Observable<NewsPost> {
    const newPost = {
      ...post,
      id: Date.now().toString(), // Generate a simple ID
      date: new Date(),
    };

    const currentPosts = this.postsSubject.value;
    this.postsSubject.next([...currentPosts, newPost]);

    return of(newPost);
  }

  updatePost(post: NewsPost): Observable<NewsPost> {
    const currentPosts = this.postsSubject.value;
    const index = currentPosts.findIndex((p) => p.id === post.id);

    if (index !== -1) {
      currentPosts[index] = { ...post };
      this.postsSubject.next([...currentPosts]);
    }

    return of(post);
  }

  deletePost(id: string): Observable<boolean> {
    const currentPosts = this.postsSubject.value;
    const filteredPosts = currentPosts.filter((post) => post.id !== id);

    if (filteredPosts.length !== currentPosts.length) {
      this.postsSubject.next(filteredPosts);
      return of(true);
    }

    return of(false);
  }
}
