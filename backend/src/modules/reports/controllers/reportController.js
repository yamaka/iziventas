import { Sale } from '../../sales/models/sale.js';
import { Product } from '../../products/models/product.js';
import { Op } from 'sequelize';
import sequelize from '../../../config/database.js';

class ReportController {
  // Reporte de ventas diarias
  async getDailySalesReport(req, res) {
    try {
      const { startDate, endDate } = req.query;

      // Configurar fechas si no se proporcionan
      const start = startDate 
        ? new Date(startDate) 
        : new Date(new Date().getFullYear(), 0, 1);
      const end = endDate 
        ? new Date(endDate) 
        : new Date();

      // Consulta de ventas diarias
      const dailySales = await Sale.findAll({
        attributes: [
          [sequelize.fn('DATE', sequelize.col('sale_date')), 'date'],
          [sequelize.fn('COUNT', sequelize.col('id')), 'total_sales'],
          [sequelize.fn('SUM', sequelize.col('total_amount')), 'total_revenue']
        ],
        where: {
          sale_date: {
            [Op.between]: [start, end]
          },
          status: 'completed'
        },
        group: [sequelize.fn('DATE', sequelize.col('sale_date'))],
        order: [[sequelize.fn('DATE', sequelize.col('sale_date')), 'ASC']]
      });

      res.json({
        message: 'Reporte de ventas diarias',
        data: dailySales
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al generar reporte de ventas diarias',
        error: error.message
      });
    }
  }

  // Reporte de ventas por producto
  async getProductSalesReport(req, res) {
    try {
      const { startDate, endDate } = req.query;

      // Configurar fechas si no se proporcionan
      const start = startDate 
        ? new Date(startDate) 
        : new Date(new Date().getFullYear(), 0, 1);
      const end = endDate 
        ? new Date(endDate) 
        : new Date();

      // Consulta de ventas por producto
      const productSales = await Product.findAll({
        attributes: [
          'id', 
          'name', 
          'sku',
          [sequelize.fn('SUM', sequelize.col('Sales.SaleItem.quantity')), 'total_quantity_sold'],
          [sequelize.fn('SUM', sequelize.literal('Sales.SaleItem.quantity * Sales.SaleItem.unit_price')), 'total_revenue']
        ],
        include: [
          {
            model: Sale,
            through: {
              attributes: ['quantity', 'unit_price']
            },
            where: {
              sale_date: {
                [Op.between]: [start, end]
              },
              status: 'completed'
            }
          }
        ],
        group: ['Product.id', 'Product.name', 'Product.sku'],
        order: [[sequelize.col('total_revenue'), 'DESC']]
      });

      res.json({
        message: 'Reporte de ventas por producto',
        data: productSales
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al generar reporte de ventas por producto',
        error: error.message
      });
    }
  }

  // Reporte de inventario
  async getInventoryReport(req, res) {
    try {
      // Obtener productos con stock bajo
      const lowStockProducts = await Product.findAll({
        where: {
          stock: {
            [Op.lt]: 10 // Productos con menos de 10 unidades
          }
        },
        attributes: ['id', 'name', 'sku', 'stock', 'price'],
        order: [[('stock', 'ASC')]]
      });

      // Obtener resumen general de inventario
      const inventorySummary = await Product.findOne({
        attributes: [
          [sequelize.fn('COUNT', sequelize.col('id')), 'total_products'],
          [sequelize.fn('SUM', sequelize.col('stock')), 'total_stock'],
          [sequelize.fn('SUM', sequelize.literal('stock * price')), 'total_inventory_value']
        ]
      });

      res.json({
        message: 'Reporte de inventario',
        low_stock_products: lowStockProducts,
        inventory_summary: inventorySummary
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al generar reporte de inventario',
        error: error.message
      });
    }
  }
}

export default new ReportController();