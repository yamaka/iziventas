import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

// Configuraciones para diferentes entornos
const environments = {
  development: {
    username: process.env.DB_USER || 'usuario_db',
    password: process.env.DB_PASS || 'contraseña_segura',
    database: process.env.DB_NAME || 'inventory_sales_db',
    host: process.env.DB_HOST || 'db',
    dialect: 'mysql',
    port: process.env.DB_PORT || 3306,
    dialectOptions: {
      connectTimeout: 10000, // 10 segundos
    },
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
};

// Seleccionar configuración según el entorno
const env = process.env.NODE_ENV || 'development';
const config = environments[env];

// Crear instancia de Sequelize
const sequelize = new Sequelize(
  config.database, 
  config.username, 
  config.password, 
  {
    host: config.host,
    port: config.port,
    dialect: config.dialect,
    
    dialectOptions: {
      connectTimeout: 10000, // 10 segundos
    },
    
    pool: config.pool,
    
    // Logging
    logging: env === 'development' ? console.log : false
  }
);

// Función para conectar y sincronizar la base de datos
export const connectDatabase = async () => {
  try {
    console.log('Intentando conectar a la base de datos...');
    console.log('Configuración de conexión:', {
      host: config.host,
      port: config.port,
      database: config.database,
      user: config.username
    });

    // Intentar autenticar múltiples veces
    const maxAttempts = 10;
    const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await sequelize.authenticate();
        console.log('Conexión a la base de datos establecida exitosamente.');
        
        // En desarrollo, sincroniza los modelos
        if (process.env.NODE_ENV === 'development') {
          await sequelize.sync({ alter: true });
          console.log('Modelos sincronizados con la base de datos.');
        }
        
        return;
      } catch (error) {
        console.error(`Intento ${attempt} de conexión fallido:`, error.message);
        
        if (attempt < maxAttempts) {
          console.log(`Reintentando en 5 segundos... (Intento ${attempt + 1}/${maxAttempts})`);
          await delay(5000);
        } else {
          throw error;
        }
      }
    }
  } catch (error) {
    console.error('No se pudo conectar a la base de datos después de varios intentos:', error);
    process.exit(1);
  }
};

export default sequelize;