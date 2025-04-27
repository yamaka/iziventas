import { Sale, SaleItem } from '../models/sale.js';
import Product from '../../products/models/product.js';
import sequelize from '../../../config/database.js';
import { Op } from 'sequelize';

class SaleController {
  // Crear nueva venta
  async createSale(req, res) {
    const transaction = await sequelize.transaction();

    try {
      const { sale_date, total_amount, items } = req.body;

      let calculatedTotalAmount = 0;
      const saleItems = [];

      // Validar y procesar cada producto
      for (const item of items) {
        const product = await Product.findByPk(item.product_id);

        if (!product) {
          throw new Error(`Producto con ID ${item.product_id} no encontrado`);
        }

        if (product.stock < item.quantity) {
          throw new Error(`Stock insuficiente para el producto ${product.name}`);
        }

        // Reducir el stock del producto
        product.stock -= item.quantity;
        await product.save({ transaction });

        // Calcular el monto total
        calculatedTotalAmount += item.quantity * product.price;

        // Preparar ítem de venta
        saleItems.push({
          product_id: product.id,
          quantity: item.quantity,
          unit_price: product.price,
        });
      }

      // Verificar que el total enviado coincida con el calculado
      if (calculatedTotalAmount !== total_amount) {
        throw new Error('El monto total no coincide con los ítems de la venta');
      }

      // Crear la venta
      const sale = await Sale.create(
        {
          sale_date: sale_date || new Date(),
          total_amount: calculatedTotalAmount,
          status: 'completed',
        },
        { transaction }
      );

      // Crear los ítems de la venta
      await SaleItem.bulkCreate(
        saleItems.map((item) => ({
          ...item,
          sale_id: sale.id,
        })),
        { transaction }
      );

      // Confirmar la transacción
      await transaction.commit();

      res.status(201).json({
        message: 'Venta creada exitosamente',
        sale: {
          ...sale.toJSON(),
          items: saleItems,
        },
      });
    } catch (error) {
      // Revertir la transacción en caso de error
      await transaction.rollback();

      res.status(500).json({
        message: 'Error al crear la venta',
        error: error.message,
      });
    }
  }

  // Obtener todas las ventas
  async getAllSales(req, res) {
    try {
      const { 
        page = 1, 
        limit = 10, 
        startDate, 
        endDate 
      } = req.query;

      const offset = (page - 1) * limit;
      const whereCondition = {};

      // Filtro por rango de fechas
      if (startDate && endDate) {
        whereCondition.sale_date = {
          [Op.between]: [
            new Date(startDate), 
            new Date(endDate)
          ]
        };
      }

      const sales = await Sale.findAndCountAll({
        where: whereCondition,
        include: [
          {
            model: SaleItem,
            as: 'items',
            include: [{ 
              model: Product, 
              attributes: ['name', 'sku'] 
            }]
          }
        ],
        limit: Number(limit),
        offset: Number(offset),
        order: [['sale_date', 'DESC']]
      });

      res.json({
        sales: sales.rows,
        totalSales: sales.count,
        totalPages: Math.ceil(sales.count / limit),
        currentPage: Number(page)
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener las ventas',
        error: error.message
      });
    }
  }

  // Obtener venta por ID
  async getSaleById(req, res) {
    try {
      const { id } = req.params;

      const sale = await Sale.findByPk(id, {
        include: [
          {
            model: SaleItem,
            as: 'items',
            include: [{ 
              model: Product, 
              attributes: ['name', 'sku', 'price'] 
            }]
          }
        ]
      });

      if (!sale) {
        return res.status(404).json({
          message: 'Venta no encontrada'
        });
      }

        res.json(sale);
      } catch (error) {
        res.status(500).json({
          message: 'Error al obtener los detalles de la venta',
          error: error.message
        });
      }
    }
    
    // Cancelar venta
    async cancelSale(req, res) {
      const transaction = await sequelize.transaction();
    
      try {
        const { id } = req.params;
    
        // Buscar la venta con sus ítems
        const sale = await Sale.findByPk(id, {
          include: [{ 
            model: SaleItem, 
            as: 'items' 
          }]
        });
    
        if (!sale) {
          return res.status(404).json({
            message: 'Venta no encontrada'
          });
        }
    
        // Verificar si la venta ya está cancelada
        if (sale.status === 'cancelled') {
          return res.status(400).json({
            message: 'La venta ya está cancelada'
          });
        }
    
        // Restaurar stock de productos
        for (const item of sale.items) {
          const product = await Product.findByPk(item.product_id);
          
          if (product) {
            product.stock += item.quantity;
            await product.save({ transaction });
          }
        }
    
        // Actualizar estado de la venta
        sale.status = 'cancelled';
        await sale.save({ transaction });
    
        // Confirmar transacción
        await transaction.commit();
    
        res.json({
          message: 'Venta cancelada exitosamente',
          sale
        });
      } catch (error) {
        // Revertir transacción en caso de error
        await transaction.rollback();
    
        res.status(500).json({
          message: 'Error al cancelar la venta',
          error: error.message
        });
      }
    }
    
    // Generar reporte de ventas
    async generateSalesReport(req, res) {
      try {
        const { 
          startDate, 
          endDate, 
          groupBy = 'day' 
        } = req.query;
    
        // Validar y parsear fechas
        const start = startDate ? new Date(startDate) : new Date(new Date().getFullYear(), 0, 1);
        const end = endDate ? new Date(endDate) : new Date();
    
        // Consulta de reporte según agrupación
        let reportQuery;
        switch (groupBy) {
          case 'day':
            reportQuery = `
              SELECT 
                DATE(sale_date) as date, 
                COUNT(*) as total_sales, 
                SUM(total_amount) as total_revenue
              FROM sales
              WHERE sale_date BETWEEN :start AND :end
              GROUP BY DATE(sale_date)
              ORDER BY date
            `;
            break;
          case 'product':
            reportQuery = `
              SELECT 
                p.name as product_name, 
                p.sku as product_sku,
                SUM(si.quantity) as total_quantity,
                SUM(si.quantity * si.unit_price) as total_revenue
              FROM sale_items si
              JOIN products p ON si.product_id = p.id
              JOIN sales s ON si.sale_id = s.id
              WHERE s.sale_date BETWEEN :start AND :end
              GROUP BY p.id, p.name, p.sku
              ORDER BY total_revenue DESC
            `;
            break;
          default:
            return res.status(400).json({
              message: 'Agrupación no válida. Use "day" o "product"'
            });
        }
    
        // Ejecutar consulta
        const [results] = await sequelize.query(reportQuery, {
          replacements: { 
            start, 
            end 
          },
          type: sequelize.QueryTypes.SELECT
        });
    
        res.json({
          message: 'Reporte generado exitosamente',
          report: results
        });
      } catch (error) {
        res.status(500).json({
          message: 'Error al generar el reporte de ventas',
          error: error.message
        });
      }
    }
    }
    
    export default new SaleController();