import express from 'express';
import SaleController from '../controllers/saleController.js';
import { 
  validateSaleCreation,
  validateSaleReport 
} from '../validations/saleValidation.js';
import { authMiddleware } from '../../../middleware/authMiddleware.js';

const router = express.Router();

// Aplicar middleware de autenticación a todas las rutas
router.use(authMiddleware);

// Crear nueva venta
router.post('/', 
  validateSaleCreation, 
  SaleController.createSale
);

// Obtener todas las ventas
router.get('/', SaleController.getAllSales);

// Obtener venta por ID
router.get('/:id', SaleController.getSaleById);

// Cancelar venta
router.patch('/:id/cancel', SaleController.cancelSale);

// Generar reporte de ventas
router.get('/report', 
  validateSaleReport,
  SaleController.generateSalesReport
);

export default router;