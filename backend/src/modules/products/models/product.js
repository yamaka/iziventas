import { DataTypes } from 'sequelize';
import sequelize from '../../../config/database.js';

// Definir el modelo
const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      notEmpty: {
        msg: 'El nombre del producto no puede estar vacío'
      },
      len: {
        args: [3, 100],
        msg: 'El nombre del producto debe tener entre 3 y 100 caracteres'
      }
    }
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: {
        args: [0],
        msg: 'El precio no puede ser negativo'
      }
    }
  },
  stock: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: {
        args: [0],
        msg: 'El stock no puede ser negativo'
      }
    }
  },
  sku: {
    type: DataTypes.STRING(50),
    unique: true,
    validate: {
      notEmpty: {
        msg: 'El SKU no puede estar vacío'
      }
    }
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active'
  }
}, {
  // Otras opciones de modelo
  tableName: 'products',
  indexes: [
    {
      unique: true,
      fields: ['name', 'sku']
    }
  ],
  hooks: {
    beforeCreate: (product) => {
      // Generar SKU automáticamente si no se proporciona
      if (!product.sku) {
        product.sku = `PRD-${Date.now()}`;
      }
    }
  }
});

// Exportación por defecto
export default Product;

// Exportación nombrada
export { Product };