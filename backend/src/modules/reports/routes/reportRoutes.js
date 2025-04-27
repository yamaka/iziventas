import express from 'express';
import ReportController from '../controllers/reportController.js';
import { authMiddleware } from '../../../middleware/authMiddleware.js';
import { 
  validateDateRangeReport, 
  validatePaginationReport 
} from '../validations/reportValidation.js';

const router = express.Router();

// Middleware de autenticación para todas las rutas de reportes
router.use(authMiddleware);

// Reporte de ventas diarias
router.get('/sales/daily', 
  validateDateRangeReport,
  validatePaginationReport,
  ReportController.getDailySalesReport
);

// Reporte de ventas por producto
router.get('/sales/products', 
  validateDateRangeReport,
  validatePaginationReport,
  ReportController.getProductSalesReport
);

// Reporte de inventario
router.get('/inventory', 
  validatePaginationReport,
  ReportController.getInventoryReport
);

export default router;