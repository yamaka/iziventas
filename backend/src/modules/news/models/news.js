import { DataTypes } from 'sequelize';
import sequelize from '../../../config/database.js';
import Category from '../../categories/models/category.js';

const News = sequelize.define('News', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  title: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      notEmpty: {
        msg: 'El título de la noticia no puede estar vacío'
      },
      len: {
        args: [6, 100],
        msg: 'El título de la noticia debe tener entre 6 y 100 caracteres'
      }
    }
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: 'El contenido de la noticia no puede estar vacío'
      }
    }
  },
  datePost: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  },
  creator: {
    type: DataTypes.STRING(50),
    allowNull: false,
    validate: {
      notEmpty: {
        msg: 'El creador de la noticia no puede estar vacío'
      }
    }
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active'
  }
}, {
  tableName: 'news',
  timestamps: true
});

// Define the relationship
News.belongsTo(Category, { foreignKey: 'categoryId', as: 'category' });
Category.hasMany(News, { foreignKey: 'categoryId', as: 'news' });

export default News;