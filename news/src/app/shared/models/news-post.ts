export interface NewsPost {
  id?: string;
  title: string;
  content: string;
  date: Date;
  creator: string;
  categoryId: string;
  imageUrl?: string;
}
