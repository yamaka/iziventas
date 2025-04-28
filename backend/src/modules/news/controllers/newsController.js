import News from '../models/news.js';
import Category from '../../categories/models/category.js';
import { Op } from 'sequelize';

class NewsController {
  async createNews(req, res) {
    try {
      const { title, content, datePost, creator, categoryId } = req.body;

      const category = await Category.findByPk(categoryId);
      if (!category) {
        return res.status(404).json({ message: 'Category not found' });
      }

      const newNews = await News.create({
        title,
        content,
        datePost,
        creator,
        categoryId
      });

      res.status(201).json({
        message: 'News post created successfully',
        news: newNews
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error creating news post',
        error: error.message
      });
    }
  }

  async getAllNews(req, res) {
    try {
      const { page = 1, limit = 10, search = '' } = req.query;
      const offset = (page - 1) * limit;

      const news = await News.findAndCountAll({
        where: {
          [Op.or]: [
            { title: { [Op.like]: `%${search}%` } },
          ]
        },
        include: [
          {
            model: Category,
            as: 'category',
            where: {
              name: { [Op.like]: `%${search}%` }
            },
            required: false // Allow news without a category match
          }
        ],
        limit: Number(limit),
        offset: Number(offset),
        order: [['createdAt', 'DESC']]
      });

      res.json({
        news: news.rows,
        totalNews: news.count,
        totalPages: Math.ceil(news.count / limit),
        currentPage: Number(page)
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error fetching news posts',
        error: error.message
      });
    }
  }

  async getNewsById(req, res) {
    try {
      const { id } = req.params;
      const news = await News.findByPk(id, {
        include: [{ model: Category, as: 'category' }]
      });

      if (!news) {
        return res.status(404).json({
          message: 'News post not found'
        });
      }

      res.json(news);
    } catch (error) {
      res.status(500).json({
        message: 'Error fetching news post',
        error: error.message
      });
    }
  }

  async updateNews(req, res) {
    try {
      const { id } = req.params;
      const { title, content, datePost, creator, categoryId, status } = req.body;

      const news = await News.findByPk(id);

      if (!news) {
        return res.status(404).json({
          message: 'News post not found'
        });
      }

      if (categoryId) {
        const category = await Category.findByPk(categoryId);
        if (!category) {
          return res.status(404).json({ message: 'Category not found' });
        }
        news.categoryId = categoryId;
      }

      news.title = title || news.title;
      news.content = content || news.content;
      news.datePost = datePost || news.datePost;
      news.creator = creator || news.creator;
      news.status = status || news.status;

      await news.save();

      res.json({
        message: 'News post updated successfully',
        news
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error updating news post',
        error: error.message
      });
    }
  }

  async deleteNews(req, res) {
    try {
      const { id } = req.params;
      const news = await News.findByPk(id);

      if (!news) {
        return res.status(404).json({
          message: 'News post not found'
        });
      }

      await news.destroy();

      res.json({
        message: 'News post deleted successfully'
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error deleting news post',
        error: error.message
      });
    }
  }
}

export default new NewsController();