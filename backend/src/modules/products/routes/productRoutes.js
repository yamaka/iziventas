import express from 'express';
import ProductController from '../controllers/productController.js';
import { 
  validateProductCreation, 
  validateProductUpdate,
  validateStockUpdate 
} from '../validations/productValidation.js';
import { authMiddleware } from '../../../middleware/authMiddleware.js';

const router = express.Router();

// Rutas protegidas por autenticación
router.use(authMiddleware);

// Crear nuevo producto
router.post('/', 
  validateProductCreation, 
  ProductController.createProduct
);

// Obtener todos los productos
router.get('/', ProductController.getAllProducts);

// Obtener producto por ID
router.get('/:id', ProductController.getProductById);

// Actualizar producto
router.put('/:id', 
  validateProductUpdate, 
  ProductController.updateProduct
);

// Eliminar producto
router.delete('/:id', ProductController.deleteProduct);

// Actualizar stock de producto
router.patch('/:id/stock', 
  validateStockUpdate,
  ProductController.updateProductStock
);

export default router;