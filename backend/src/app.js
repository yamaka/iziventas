import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

// Importar configuración de base de datos
import { connectDatabase } from './config/database.js';

// Importar rutas de módulos
import authRoutes from './modules/auth/routes/authRoutes.js';
import productRoutes from './modules/products/routes/productRoutes.js';
import saleRoutes from './modules/sales/routes/saleRoutes.js';
import reportRoutes from './modules/reports/routes/reportRoutes.js';

// Importar middleware de manejo de errores
import { errorHandler } from './middleware/errorHandler.js';

// Configuración de variables de entorno
dotenv.config();

class App {
  constructor() {
    this.app = express();
    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
  }

  // Configurar middlewares
  initializeMiddlewares() {
    // Seguridad
    this.app.use(helmet());

    // Parseo de JSON
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));

    // CORS
    this.app.use(cors({
      origin: process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
      allowedHeaders: ['Content-Type', 'Authorization']
    }));

    // Rate limiting
    const limiter = rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutos
      max: 100, // Límite de 100 solicitudes por IP
      message: 'Demasiadas solicitudes, por favor intente más tarde'
    });
    this.app.use(limiter);
  }

  // Configurar rutas
  initializeRoutes() {
    // Ruta de bienvenida
    this.app.get('/', (req, res) => {
      res.json({
        message: 'Bienvenido a la API de Gestión de Inventario y Ventas',
        version: '1.0.0'
      });
    });

    // Rutas de módulos
    this.app.use('/api/auth', authRoutes);
    this.app.use('/api/products', productRoutes);
    this.app.use('/api/sales', saleRoutes);
    this.app.use('/api/reports', reportRoutes);

    // Manejar rutas no encontradas
    this.app.use((req, res, next) => {
      res.status(404).json({
        message: 'Ruta no encontrada'
      });
    });
  }

  // Configurar manejo de errores
  initializeErrorHandling() {
    this.app.use(errorHandler);
  }

  // Iniciar servidor
  async start() {
    const PORT = process.env.PORT || 3000;

    try {
      // Conectar a la base de datos
      await connectDatabase();

      // Iniciar servidor
      this.app.listen(PORT, () => {
        console.log(`Servidor corriendo en puerto ${PORT}`);
        console.log(`Entorno: ${process.env.NODE_ENV}`);
      });
    } catch (error) {
      console.error('Error al iniciar la aplicación:', error);
      process.exit(1);
    }
  }

  // Devolver la instancia de Express (útil para testing)
  getApp() {
    return this.app;
  }
}

// Crear instancia de la aplicación
const app = new App();

// Exportar para uso en otros archivos (por ejemplo, testing)
export default app;

// Si se ejecuta directamente el archivo
if (import.meta.url === `file://${process.argv[1]}`) {
  app.start();
}