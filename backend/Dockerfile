FROM node:18-alpine

# Instalar wait-port globalmente
RUN npm install -g wait-port

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código de la aplicación
COPY . .

# Establecer variables de entorno para desarrollo
ENV NODE_ENV=development

# Exponer puerto de la aplicación
EXPOSE 3000

# Comando para iniciar la aplicación
CMD ["sh", "-c", "wait-port db:3306 && npm run dev"]