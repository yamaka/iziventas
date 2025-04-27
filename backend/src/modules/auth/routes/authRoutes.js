import express from 'express';
import AuthController from '../controllers/authController.js';
import { 
  validateRegister, 
  validateLogin,
  validatePasswordChange,
  validatePasswordResetRequest
} from '../validations/authValidation.js';
import { authMiddleware } from '../../../middleware/authMiddleware.js';

const router = express.Router();

// Registro de usuario
router.post('/register', 
  validateRegister, 
  (req, res) => AuthController.register(req, res)
);

// Inicio de sesión
router.post('/login', 
  validateLogin, 
  (req, res) => AuthController.login(req, res)
);

// Cambiar contraseña (requiere autenticación)
router.patch('/change-password', 
  authMiddleware,
  validatePasswordChange,
  (req, res) => AuthController.changePassword(req, res)
);

// Perfil de usuario
router.get('/profile', 
  authMiddleware, 
  (req, res) => AuthController.getUserProfile(req, res)
);

// Solicitud de restablecimiento de contraseña
router.post('/reset-password/request', 
  validatePasswordResetRequest,
  (req, res) => AuthController.requestPasswordReset(req, res)
);

export default router;