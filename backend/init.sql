# Configuración inicial
USE mysql;

# Eliminar usuario existente si es necesario
DROP USER IF EXISTS 'usuario_db'@'%';
DROP USER IF EXISTS 'usuario_db'@'localhost';

# Crear usuario con autenticación nativa
CREATE USER 'usuario_db'@'%' IDENTIFIED WITH mysql_native_password BY 'contraseña_segura';
CREATE USER 'usuario_db'@'localhost' IDENTIFIED WITH mysql_native_password BY 'contraseña_segura';

# Crear base de datos
CREATE DATABASE IF NOT EXISTS inventory_sales_db 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

# Otorgar todos los privilegios
GRANT ALL PRIVILEGES ON inventory_sales_db.* TO 'usuario_db'@'%';
GRANT ALL PRIVILEGES ON inventory_sales_db.* TO 'usuario_db'@'localhost';

# Actualizar privilegios
FLUSH PRIVILEGES;