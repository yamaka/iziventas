import Joi from 'joi';

// Middleware de validación para creación de producto
export const validateProductCreation = (req, res, next) => {
  const schema = Joi.object({
    name: Joi.string()
      .trim()
      .min(3)
      .max(100)
      .required()
      .messages({
        'string.empty': 'El nombre del producto es requerido',
        'string.min': 'El nombre debe tener al menos 3 caracteres',
        'string.max': 'El nombre no puede exceder 100 caracteres'
      }),
    description: Joi.string()
      .optional()
      .allow(null, ''),
    price: Joi.number()
      .positive()
      .precision(2)
      .required()
      .messages({
        'number.positive': 'El precio debe ser un número positivo',
        'any.required': 'El precio es requerido'
      }),
    stock: Joi.number()
      .integer()
      .min(0)
      .required()
      .messages({
        'number.base': 'El stock debe ser un número',
        'number.integer': 'El stock debe ser un número entero',
        'number.min': 'El stock no puede ser negativo'
      }),
    sku: Joi.string()
      .trim()
      .optional()
      .pattern(/^[A-Z0-9-]+$/)
      .messages({
        'string.pattern.base': 'El SKU solo puede contener letras mayúsculas, números y guiones'
      })
  });

  const { error } = schema.validate(req.body);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map(detail => detail.message)
    });
  }

  next();
};

// Middleware de validación para actualización de producto
export const validateProductUpdate = (req, res, next) => {
  const schema = Joi.object({
    name: Joi.string()
      .trim()
      .min(3)
      .max(100)
      .optional()
      .messages({
        'string.min': 'El nombre debe tener al menos 3 caracteres',
        'string.max': 'El nombre no puede exceder 100 caracteres'
      }),
    description: Joi.string()
      .optional()
      .allow(null, ''),
    price: Joi.number()
      .positive()
      .precision(2)
      .optional()
      .messages({
        'number.positive': 'El precio debe ser un número positivo'
      }),
    stock: Joi.number()
      .integer()
      .min(0)
      .optional()
      .messages({
        'number.integer': 'El stock debe ser un número entero',
        'number.min': 'El stock no puede ser negativo'
      }),
    sku: Joi.string()
      .trim()
      .optional()
      .pattern(/^[A-Z0-9-]+$/)
      .messages({
        'string.pattern.base': 'El SKU solo puede contener letras mayúsculas, números y guiones'
      }),
    status: Joi.string()
      .valid('active', 'inactive')
      .optional()
  });

  const { error } = schema.validate(req.body);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map(detail => detail.message)
    });
  }

  next();
};

// Middleware de validación para actualización de stock
export const validateStockUpdate = (req, res, next) => {
  const schema = Joi.object({
    amount: Joi.number()
      .integer()
      .positive()
      .required()
      .messages({
        'number.base': 'La cantidad debe ser un número',
        'number.integer': 'La cantidad debe ser un número entero',
        'number.positive': 'La cantidad debe ser un número positivo',
        'any.required': 'La cantidad es requerida'
      })
  });

  const { error } = schema.validate(req.body);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map(detail => detail.message)
    });
  }

  next();
};