import Product from '../models/product.js';
import { Op } from 'sequelize';

class ProductController {
  // Crear nuevo producto
  async createProduct(req, res) {
    try {
      const { name, description, price, stock, sku } = req.body;
      
      // Validar si ya existe un producto con ese nombre o SKU
      const existingProduct = await Product.findOne({
        where: {
          [Op.or]: [
            { name: name },
            { sku: sku }
          ]
        }
      });

      if (existingProduct) {
        return res.status(400).json({
          message: 'Ya existe un producto con este nombre o SKU'
        });
      }

      // Crear nuevo producto
      const newProduct = await Product.create({
        name,
        description,
        price,
        stock,
        sku
      });

      res.status(201).json({
        message: 'Producto creado exitosamente',
        product: newProduct
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al crear el producto',
        error: error.message
      });
    }
  }

  // Obtener todos los productos
  async getAllProducts(req, res) {
    try {
      const { page = 1, limit = 10, search = '' } = req.query;
      const offset = (page - 1) * limit;

      const products = await Product.findAndCountAll({
        where: {
          [Op.or]: [
            { name: { [Op.like]: `%${search}%` } },
            { sku: { [Op.like]: `%${search}%` } }
          ]
        },
        limit: Number(limit),
        offset: Number(offset),
        order: [['createdAt', 'DESC']]
      });

      res.json({
        products: products.rows,
        totalProducts: products.count,
        totalPages: Math.ceil(products.count / limit),
        currentPage: Number(page)
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener los productos',
        error: error.message
      });
    }
  }

  // Obtener producto por ID
  async getProductById(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findByPk(id);

      if (!product) {
        return res.status(404).json({
          message: 'Producto no encontrado'
        });
      }

      res.json(product);
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener el producto',
        error: error.message
      });
    }
  }

  // Actualizar producto
  async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const { name, description, price, stock, sku, status } = req.body;

      const product = await Product.findByPk(id);

      if (!product) {
        return res.status(404).json({
          message: 'Producto no encontrado'
        });
      }

      // Actualizar campos
      product.name = name || product.name;
      product.description = description || product.description;
      product.price = price || product.price;
      product.stock = stock || product.stock;
      product.sku = sku || product.sku;
      product.status = status || product.status;

      await product.save();

      res.json({
        message: 'Producto actualizado exitosamente',
        product
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al actualizar el producto',
        error: error.message
      });
    }
  }

  // Eliminar producto
  async deleteProduct(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findByPk(id);

      if (!product) {
        return res.status(404).json({
          message: 'Producto no encontrado'
        });
      }

      await product.destroy();

      res.json({
        message: 'Producto eliminado exitosamente'
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al eliminar el producto',
        error: error.message
      });
    }
  }

  // Actualizar stock de producto
  async updateProductStock(req, res) {
    try {
      const { id } = req.params
      const { amount } = req.body;

    // Validar que la cantidad sea un número positivo
    if (!amount || amount <= 0) {
      return res.status(400).json({
        message: 'La cantidad debe ser un número positivo'
      });
    }

    const product = await Product.findByPk(id);

    if (!product) {
      return res.status(404).json({
        message: 'Producto no encontrado'
      });
    }

    // Actualizar stock
    product.stock += parseInt(amount);

    await product.save();

    res.json({
      message: 'Stock actualizado exitosamente',
      product
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error al actualizar el stock',
      error: error.message
    });
  }
}
}

export default new ProductController();