import bcrypt from 'bcryptjs';
import User from '../modules/auth/models/user.js';
import Product from '../modules/products/models/product.js';
import sequelize from '../config/database.js';

/**
 * Función para poblar la base de datos con datos iniciales
 */
export async function seedDatabase() {
  try {
    // Sincronizar modelos (force: true elimina y recrea tablas)
    await sequelize.sync({ force: true });

    // Crear usuarios iniciales
    const hashedPassword = await bcrypt.hash('AdminPassword123!', 10);
    const users = await User.bulkCreate([
      {
        username: 'admin',
        email: 'admin@inventoryapp.com',
        password: hashedPassword,
        role: 'admin',
        status: 'active'
      },
      {
        username: 'manager',
        email: 'manager@inventoryapp.com',
        password: hashedPassword,
        role: 'manager',
        status: 'active'
      },
      {
        username: 'seller',
        email: 'seller@inventoryapp.com',
        password: hashedPassword,
        role: 'seller',
        status: 'active'
      }
    ]);

    // Crear productos iniciales
    const products = await Product.bulkCreate([
      {
        name: 'Laptop Básica',
        description: 'Laptop económica para tareas básicas',
        price: 299.99,
        stock: 50,
        sku: 'LPT-001',
        status: 'active'
      },
      {
        name: 'Smartphone Gama Media',
        description: 'Smartphone con buenas características',
        price: 199.99,
        stock: 100,
        sku: 'SMT-002',
        status: 'active'
      },
      {
        name: 'Tableta 10 Pulgadas',
        description: 'Tableta compacta y versátil',
        price: 149.99,
        stock: 75,
        sku: 'TBL-003',
        status: 'active'
      }
    ]);

    console.log('Datos iniciales cargados exitosamente');
    
    return { users, products };
  } catch (error) {
    console.error('Error al cargar datos iniciales:', error);
    throw error;
  }
}

// Si se ejecuta directamente
if (import.meta.url === `file://${process.argv[1]}`) {
  seedDatabase()
    .then(() => {
      console.log('Semillas cargadas');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Error al cargar semillas:', error);
      process.exit(1);
    });
}