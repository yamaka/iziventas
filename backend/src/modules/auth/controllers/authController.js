import { Op } from 'sequelize'; 
import User from '../models/user.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

class AuthController {
  // Registro de usuario
  async register(req, res) {
    try {
      const { username, email, password, role } = req.body;

      // Verificar si el usuario o email ya existen
      const existingUser = await User.findOne({
        where: {
          [Op.or]: [
            { username },
            { email }
          ]
        }
      });

      if (existingUser) {
        return res.status(400).json({
          message: 'Nombre de usuario o correo electrónico ya existe'
        });
      }

      // Crear nuevo usuario
      const newUser = await User.create({
        username,
        email,
        password,
        role: role || 'seller' // Rol por defecto
      });

      // Generar token de autenticación
      const token = this.generateToken(newUser);

      res.status(201).json({
        message: 'Usuario registrado exitosamente',
        user: {
          id: newUser.id,
          username: newUser.username,
          email: newUser.email,
          role: newUser.role
        },
        token
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al registrar usuario',
        error: error.message
      });
    }
  }

  // Inicio de sesión
  async login(req, res) {
    try {
      const { username, password } = req.body;

      // Buscar usuario
      const user = await User.findOne({ 
        where: { username } 
      });

      if (!user) {
        return res.status(401).json({
          message: 'Credenciales inválidas'
        });
      }

      // Verificar contraseña
      const isMatch = await bcrypt.compare(password, user.password);

      if (!isMatch) {
        return res.status(401).json({
          message: 'Credenciales inválidas'
        });
      }

      // Verificar estado del usuario
      if (user.status !== 'active') {
        return res.status(403).json({
          message: 'Cuenta de usuario inactiva'
        });
      }

      // Actualizar última fecha de inicio de sesión
      user.last_login = new Date();
      await user.save();

      // Generar token
      const token = this.generateToken(user);

      res.json({
        message: 'Inicio de sesión exitoso',
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role
        },
        token
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error de inicio de sesión',
        error: error.message
      });
    }
  }

  // Cambiar contraseña
  async changePassword(req, res) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      // Buscar usuario
      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({
          message: 'Usuario no encontrado'
        });
      }

      // Verificar contraseña actual
      const isMatch = await bcrypt.compare(currentPassword, user.password);

      if (!isMatch) {
        return res.status(400).json({
          message: 'Contraseña actual incorrecta'
        });
      }

      // Actualizar contraseña
      user.password = newPassword;
      await user.save();

      res.json({
        message: 'Contraseña cambiada exitosamente'
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al cambiar la contraseña',
        error: error.message
      });
    }
  }

  // Generar token JWT
  generateToken(user) {
    return jwt.sign(
      { 
        id: user.id, 
        username: user.username, 
        role: user.role 
      },
      process.env.JWT_SECRET,
      { 
        expiresIn: process.env.JWT_EXPIRATION || '1h' 
      }
    );
  }

  // Perfil de usuario
  async getUserProfile(req, res) {
    try {
      // req.user ya es establecido por el middleware de autenticación
      const user = await User.findByPk(req.user.id, {
        attributes: { 
          exclude: ['password'] 
        }
      });

      if (!user) {
        return res.status(404).json({
          message: 'Usuario no encontrado'
        });
      }

      res.json(user);
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener perfil de usuario',
        error: error.message
      });
    }
  }

  // Recuperación de contraseña (solicitud de reset)
  async requestPasswordReset(req, res) {
    try {
      const { email } = req.body;

      // Buscar usuario por email
      const user = await User.findOne({ 
        where: { email } 
      });

      if (!user) {
        // Por seguridad, no revelar si el email existe
        return res.status(200).json({
          message: 'Si el correo existe, se enviará un enlace de restablecimiento'
        });
      }

      // Generar token de reset
      const resetToken = this.generateResetToken(user);

      // TODO: Enviar email con enlace de reset 
      // Implementar servicio de envío de emails
      // const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

      res.json({
        message: 'Solicitud de restablecimiento de contraseña procesada'
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error en la solicitud de restablecimiento',
        error: error.message
      });
    }
  }

  // Generar token de reset de contraseña
  generateResetToken(user) {
    return jwt.sign(
      { 
        id: user.id 
      },
      process.env.JWT_RESET_SECRET,
      { 
        expiresIn: '1h' 
      }
    );
  }
}

export default new AuthController();