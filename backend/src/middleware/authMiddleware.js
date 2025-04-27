import jwt from 'jsonwebtoken';
import User from '../modules/auth/models/user.js';

export const authMiddleware = async (req, res, next) => {
  try {
    // Obtener el token del encabezado de autorización
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        message: 'Token de autorización no proporcionado'
      });
    }

    // Extraer el token (Bearer TOKEN)
    const token = authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        message: 'Formato de token inválido'
      });
    }

    // Verificar y decodificar el token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Buscar usuario
    const user = await User.findByPk(decoded.id, {
      attributes: { exclude: ['password'] }
    });

    if (!user) {
      return res.status(401).json({
        message: 'Usuario no encontrado'
      });
    }

    // Adjuntar usuario a la solicitud
    req.user = user;

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        message: 'Token inválido'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        message: 'Token expirado'
      });
    }

    res.status(500).json({
      message: 'Error de autenticación',
      error: error.message
    });
  }
};

// Middleware para roles específicos
export const roleMiddleware = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        message: 'No autenticado'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        message: 'Acceso denegado. Permisos insuficientes'
      });
    }

    next();
  };
};