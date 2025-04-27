import Joi from 'joi';

// Middleware de validación para creación de venta
export const validateSaleCreation = (req, res, next) => {
  // Esquema de validación para un ítem de venta
  const saleItemSchema = Joi.object({
    product_id: Joi.string()
      .uuid()
      .required()
      .messages({
        'string.guid': 'El ID del producto debe ser un UUID válido',
        'any.required': 'El ID del producto es requerido',
      }),
    product: Joi.object({
      name: Joi.string().optional(),
      description: Joi.string().optional(),
      price: Joi.number().optional(),
      stock: Joi.number().optional(),
      sku: Joi.string().optional(),
      id: Joi.string().uuid().optional(),
    }).optional(),
    quantity: Joi.number()
      .integer()
      .min(1)
      .required()
      .messages({
        'number.base': 'La cantidad debe ser un número',
        'number.integer': 'La cantidad debe ser un número entero',
        'number.min': 'La cantidad debe ser al menos 1',
        'any.required': 'La cantidad es requerida',
      }),
    unit_price: Joi.number().optional(),
  });

  // Esquema de validación para toda la venta
  const saleSchema = Joi.object({
    _id: Joi.any().optional(),
    sale_date: Joi.date().iso().optional(),
    total_amount: Joi.number()
      .required()
      .messages({
        'number.base': 'El monto total debe ser un número',
        'any.required': 'El monto total es requerido',
      }),
    status: Joi.string().valid('completed', 'pending', 'cancelled').optional(),
    items: Joi.array()
      .items(saleItemSchema)
      .min(1)
      .required()
      .messages({
        'array.base': 'Los ítems de venta deben ser un arreglo',
        'array.min': 'Debe haber al menos un ítem en la venta',
        'any.required': 'Los ítems de venta son requeridos',
      }),
  });

  // Validar el cuerpo de la solicitud
  const { error } = saleSchema.validate(req.body);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map((detail) => detail.message),
    });
  }

  next();
};

// Middleware de validación para reporte de ventas
export const validateSaleReport = (req, res, next) => {
  // Esquema de validación para los parámetros del reporte
  const reportSchema = Joi.object({
    startDate: Joi.date()
      .iso()
      .optional()
      .messages({
        'date.base': 'La fecha de inicio debe ser una fecha válida en formato ISO'
      }),
    endDate: Joi.date()
      .iso()
      .optional()
      .min(Joi.ref('startDate'))
      .messages({
        'date.base': 'La fecha de fin debe ser una fecha válida en formato ISO',
        'date.min': 'La fecha de fin debe ser posterior o igual a la fecha de inicio'
      }),
    groupBy: Joi.string()
      .valid('day', 'product')
      .optional()
      .default('day')
      .messages({
        'any.only': 'La agrupación solo puede ser "day" o "product"'
      })
  });

  // Validar los parámetros de consulta
  const { error } = reportSchema.validate(req.query);

  if (error) {
    return res.status(400).json({
      message: 'Error de validación',
      errors: error.details.map(detail => detail.message)
    });
  }

  next();
};