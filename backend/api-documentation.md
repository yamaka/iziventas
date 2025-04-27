# Inventory Sales Management API Documentation

## Autenticación

### Registro de Usuario
- **Endpoint**: `POST /api/auth/register`
- **Descripción**: Registrar un nuevo usuario
- **Cuerpo de la solicitud**:
```json
{
  "username": "nuevo_usuario",
  "email": "usuario@ejemplo.com",
  "password": "Contraseña123!",
  "role": "seller" // Opcional, por defecto 'seller'
}
```

### Inicio de Sesión
- **Endpoint**: `POST /api/auth/login`
- **Descripción**: Iniciar sesión y obtener token JWT
- **Cuerpo de la solicitud**:
```json
{
  "username": "nombre_usuario",
  "password": "contraseña"
}
```

## Gestión de Productos

### Crear Producto
- **Endpoint**: `POST /api/products`
- **Descripción**: Crear un nuevo producto
- **Autenticación**: Requiere token JWT
- **Cuerpo de la solicitud**:
```json
{
  "name": "Producto de Ejemplo",
  "description": "Descripción del producto",
  "price": 19.99,
  "stock": 100,
  "sku": "PRD-001"
}
```

### Listar Productos
- **Endpoint**: `GET /api/products`
- **Descripción**: Obtener lista de productos
- **Parámetros de consulta**:
  - `page`: Número de página (defecto: 1)
  - `limit`: Productos por página (defecto: 10)
  - `search`: Término de búsqueda

### Actualizar Stock
- **Endpoint**: `PATCH /api/products/:id/stock`
- **Descripción**: Actualizar el stock de un producto
- **Cuerpo de la solicitud**:
```json
{
  "amount": 50 // Cantidad a añadir/quitar
}
```

## Gestión de Ventas

### Crear Venta
- **Endpoint**: `POST /api/sales`
- **Descripción**: Registrar una nueva venta
- **Autenticación**: Requiere token JWT
- **Cuerpo de la solicitud**:
```json
{
  "items": [
    {
      "productId": "uuid-del-producto",
      "quantity": 2
    }
  ]
}
```

### Listar Ventas
- **Endpoint**: `GET /api/sales`
- **Descripción**: Obtener lista de ventas
- **Parámetros de consulta**:
  - `page`: Número de página
  - `limit`: Ventas por página
  - `startDate`: Fecha de inicio para filtrar
  - `endDate`: Fecha de fin para filtrar

## Reportes

### Reporte de Ventas Diarias
- **Endpoint**: `GET /api/reports/sales/daily`
- **Descripción**: Generar reporte de ventas por día
- **Parámetros de consulta**:
  - `startDate`: Fecha de inicio (formato ISO, opcional)
  - `endDate`: Fecha de fin (formato ISO, opcional)
  - `page`: Número de página (opcional)
  - `limit`: Resultados por página (opcional)
- **Respuesta de ejemplo**:
```json
{
  "message": "Reporte de ventas diarias",
  "data": [
    {
      "date": "2024-01-01",
      "total_sales": 10,
      "total_revenue": 599.90
    }
  ]
}
```

### Reporte de Ventas por Producto
- **Endpoint**: `GET /api/reports/sales/products`
- **Descripción**: Generar reporte de ventas por producto
- **Parámetros de consulta**:
  - `startDate`: Fecha de inicio (formato ISO, opcional)
  - `endDate`: Fecha de fin (formato ISO, opcional)
  - `page`: Número de página (opcional)
  - `limit`: Resultados por página (opcional)
- **Respuesta de ejemplo**:
```json
{
  "message": "Reporte de ventas por producto",
  "data": [
    {
      "id": "uuid-producto",
      "name": "Producto A",
      "sku": "PRD-001",
      "total_quantity_sold": 50,
      "total_revenue": 1499.50
    }
  ]
}
```

### Reporte de Inventario
- **Endpoint**: `GET /api/reports/inventory`
- **Descripción**: Generar reporte de estado de inventario
- **Parámetros de consulta**:
  - `page`: Número de página (opcional)
  - `limit`: Resultados por página (opcional)
- **Respuesta de ejemplo**:
```json
{
  "message": "Reporte de inventario",
  "low_stock_products": [
    {
      "id": "uuid-producto",
      "name": "Producto con Stock Bajo",
      "sku": "PRD-002",
      "stock": 5,
      "price": 29.99
    }
  ],
  "inventory_summary": {
    "total_products": 100,
    "total_stock": 1500,
    "total_inventory_value": 45000.00
  }
}
```

## Códigos de Estado
- `200`: Éxito
- `201`: Creado exitosamente
- `400`: Error de validación
- `401`: No autorizado
- `404`: No encontrado
- `500`: Error interno del servidor

## Autenticación
Todas las rutas protegidas requieren un token JWT en el encabezado:
```
Authorization: Bearer <token>
```

## Notas Importantes
- Todos los endpoints de reportes requieren autenticación
- Las fechas deben estar en formato ISO (YYYY-MM-DD)
- Los parámetros de consulta son opcionales
- Se recomienda manejar errores del lado del cliente