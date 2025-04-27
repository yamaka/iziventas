// Middleware de manejo de errores global
const errorHandler = (err, req, res, next) => {
  // Log del error para referencia del servidor
  console.error('Error capturado:', err);

  // Determinar código de estado
  const statusCode = err.statusCode || 500;

  // Respuesta de error
  res.status(statusCode).json({
    message: err.message || 'Error interno del servidor',
    // Incluir stack trace solo en desarrollo
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

// Exportación por defecto
export default errorHandler;

// Exportación nombrada
export { errorHandler };