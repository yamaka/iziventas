import request from 'supertest';
import app from '../src/app';
import { Product } from '../src/modules/products/models/product';
import sequelize from '../src/config/database';

describe('Productos API', () => {
  let authToken;
  let createdProductId;

  // Configuración antes de todas las pruebas
  beforeAll(async () => {
    // Sincronizar modelos
    await sequelize.sync({ force: true });

    // Iniciar sesión y obtener token
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        username: 'admin',
        password: 'AdminPassword123!'
      });

    authToken = loginResponse.body.token;
  });

  // Limpiar base de datos después de las pruebas
  afterAll(async () => {
    await sequelize.close();
  });

  // Prueba de creación de producto
  describe('POST /api/products', () => {
    it('Debería crear un nuevo producto', async () => {
      const productData = {
        name: 'Producto de Prueba',
        description: 'Descripción del producto de prueba',
        price: 19.99,
        stock: 100,
        sku: 'TEST-001'
      };

      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${authToken}`)
        .send(productData);

      expect(response.statusCode).toBe(201);
      expect(response.body.product).toHaveProperty('id');
      expect(response.body.product.name).toBe(productData.name);

      // Guardar ID para pruebas posteriores
      createdProductId = response.body.product.id;
    });

    it('No debería crear producto con datos inválidos', async () => {
      const invalidProductData = {
        name: '', // Nombre vacío
        price: -10 // Precio negativo
      };

      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidProductData);

      expect(response.statusCode).toBe(400);
      expect(response.body).toHaveProperty('errors');
    });
  });

  // Prueba de obtención de productos
  describe('GET /api/products', () => {
    it('Debería obtener lista de productos', async () => {
      const response = await request(app)
        .get('/api/products')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('products');
      expect(Array.isArray(response.body.products)).toBe(true);
    });
  });

  // Prueba de actualización de producto
  describe('PUT /api/products/:id', () => {
    it('Debería actualizar un producto existente', async () => {
      const updateData = {
        name: 'Producto Actualizado',
        price: 29.99
      };

      const response = await request(app)
        .put(`/api/products/${createdProductId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData);

      expect(response.statusCode).toBe(200);
      expect(response.body.product.name).toBe(updateData.name);
      expect(response.body.product.price).toBe(updateData.price);
    });
  });

  // Prueba de actualización de stock
  describe('PATCH /api/products/:id/stock', () => {
    it('Debería actualizar el stock de un producto', async () => {
      const stockUpdateData = {
        amount: 50
      };

      const response = await request(app)
        .patch(`/api/products/${createdProductId}/stock`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(stockUpdateData);

      expect(response.statusCode).toBe(200);
      expect(response.body.product.stock).toBe(150); // 100 inicial + 50
    });

    it('No debería permitir stock negativo', async () => {
      const invalidStockUpdate = {
        amount: -200
      };

      const response = await request(app)
        .patch(`/api/products/${createdProductId}/stock`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidStockUpdate);

      expect(response.statusCode).toBe(400);
    });
  });

  // Prueba de eliminación de producto
  describe('DELETE /api/products/:id', () => {
    it('Debería eliminar un producto existente', async () => {
      const response = await request(app)
        .delete(`/api/products/${createdProductId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.statusCode).toBe(200);
      expect(response.body.message).toContain('eliminado');
    });
  });
});