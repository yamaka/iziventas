import Joi from 'joi';

// Middleware de validación para reportes con fechas
export const validateDateRangeReport = (req, res, next) => {
  // Esquema de validación para fechas
  const dateRangeSchema = Joi.object({
    startDate: Joi.date()
      .iso()
      .optional()
      .messages({
        'date.base': 'La fecha de inicio debe ser una fecha válida en formato ISO',
        'date.isoDate': 'La fecha de inicio debe estar en formato ISO'
      }),
    endDate: Joi.date()
      .iso()
      .optional()
      .min(Joi.ref('startDate'))
      .messages({
        'date.base': 'La fecha de fin debe ser una fecha válida en formato ISO',
        'date.min': 'La fecha de fin debe ser posterior o igual a la fecha de inicio'
      })
  });

  // Validar parámetros de consulta
  const { error } = dateRangeSchema.validate(req.query);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map(detail => detail.message)
    });
  }

  next();
};

// Middleware de validación para límite y offset de reportes
export const validatePaginationReport = (req, res, next) => {
  // Esquema de validación para paginación
  const paginationSchema = Joi.object({
    page: Joi.number()
      .integer()
      .min(1)
      .optional()
      .default(1)
      .messages({
        'number.base': 'El número de página debe ser un número',
        'number.integer': 'El número de página debe ser un entero',
        'number.min': 'El número de página debe ser al menos 1'
      }),
    limit: Joi.number()
      .integer()
      .min(1)
      .max(100)
      .optional()
      .default(10)
      .messages({
        'number.base': 'El límite debe ser un número',
        'number.integer': 'El límite debe ser un entero',
        'number.min': 'El límite debe ser al menos 1',
        'number.max': 'El límite no puede exceder 100'
      })
  });

  // Validar parámetros de consulta
  const { error } = paginationSchema.validate(req.query);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map(detail => detail.message)
    });
  }

  next();
};