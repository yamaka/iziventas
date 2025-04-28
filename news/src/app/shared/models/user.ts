export interface User {
  id?: string;
  name: string;
  email: string;
  password?: string;
  role: 'admin' | 'editor' | 'user';
  createdAt?: Date;
}
