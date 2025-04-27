import Joi from 'joi';

// Validación para registro de usuario
export const validateRegister = (req, res, next) => {
  const schema = Joi.object({
    username: Joi.string()
      .trim()
      .min(3)
      .max(50)
      .required()
      .pattern(/^[a-zA-Z0-9_]+$/)
      .messages({
        'string.empty': 'El nombre de usuario es requerido',
        'string.min': 'El nombre de usuario debe tener al menos 3 caracteres',
        'string.max': 'El nombre de usuario no puede exceder 50 caracteres',
        'string.pattern.base': 'El nombre de usuario solo puede contener letras, números y guiones bajos'
      }),
    email: Joi.string()
      .trim()
      .email()
      .required()
      .messages({
        'string.empty': 'El correo electrónico es requerido',
        'string.email': 'Debe ser un correo electrónico válido'
      }),
    password: Joi.string()
      .min(6)
      .max(255)
      .required()
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$/)
      .messages({
        'string.empty': 'La contraseña es requerida',
        'string.min': 'La contraseña debe tener al menos 6 caracteres',
        'string.max': 'La contraseña no puede exceder 255 caracteres',
        'string.pattern.base': 'La contraseña debe contener al menos una mayúscula, una minúscula, un número y un carácter especial'
      }),
    role: Joi.string()
      .valid('admin', 'manager', 'seller')
      .optional()
      .default('seller')
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

// Validación para inicio de sesión
export const validateLogin = (req, res, next) => {
  const schema = Joi.object({
    username: Joi.string()
      .trim()
      .required()
      .messages({
        'string.empty': 'El nombre de usuario es requerido'
      }),
    password: Joi.string()
      .required()
      .messages({
        'string.empty': 'La contraseña es requerida'
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

// Validación para cambio de contraseña
export const validatePasswordChange = (req, res, next) => {
  const schema = Joi.object({
    currentPassword: Joi.string()
      .required()
      .messages({
        'string.empty': 'La contraseña actual es requerida'
      }),
    newPassword: Joi.string()
      .min(6)
      .max(255)
      .required()
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$/)
      .messages({
        'string.empty': 'La nueva contraseña es requerida',
        'string.min': 'La nueva contraseña debe tener al menos 6 caracteres',
        'string.max': 'La nueva contraseña no puede exceder 255 caracteres',
        'string.pattern.base': 'La nueva contraseña debe contener al menos una mayúscula, una minúscula, un número y un carácter especial'
      }),
    confirmPassword: Joi.string()
      .valid(Joi.ref('newPassword'))
      .required()
      .messages({
        'any.only': 'Las contraseñas no coinciden',
        'string.empty': 'Confirmar contraseña es requerido'
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

// Validación para solicitud de restablecimiento de contraseña
export const validatePasswordResetRequest = (req, res, next) => {
  const schema = Joi.object({
    email: Joi.string()
      .trim()
      .email()
      .required()
      .messages({
        'string.empty': 'El correo electrónico es requerido',
        'string.email': 'Debe ser un correo electrónico válido'
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