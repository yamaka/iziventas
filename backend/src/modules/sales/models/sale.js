import { DataTypes } from 'sequelize';
import sequelize from '../../../config/database.js';
import { Product } from '../../products/models/product.js';

const Sale = sequelize.define('Sale', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  total_amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: {
        args: [0],
        msg: 'El monto total no puede ser negativo'
      }
    }
  },
  sale_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  status: {
    type: DataTypes.ENUM('completed', 'cancelled'),
    defaultValue: 'completed'
  }
}, {
  tableName: 'sales',
  indexes: [
    {
      fields: ['sale_date']
    }
  ]
});

// Definir la relación de muchos a muchos entre Ventas y Productos
const SaleItem = sequelize.define('SaleItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: {
        args: [1],
        msg: 'La cantidad debe ser al menos 1'
      }
    }
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  }
}, {
  tableName: 'sale_items'
});

// Asociaciones
Sale.belongsToMany(Product, { 
  through: SaleItem, 
  foreignKey: 'sale_id',
  otherKey: 'product_id'
});
Product.belongsToMany(Sale, { 
  through: SaleItem, 
  foreignKey: 'product_id',
  otherKey: 'sale_id'
});

Sale.hasMany(SaleItem, { 
  foreignKey: 'sale_id',
  as: 'items'
});
SaleItem.belongsTo(Sale, { 
  foreignKey: 'sale_id'
});
SaleItem.belongsTo(Product, { 
  foreignKey: 'product_id'
});

export { Sale, SaleItem };