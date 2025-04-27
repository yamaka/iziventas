# IziVentas - Aplicación de Gestión de Inventario y Ventas

## Descripción
IziVentas es una aplicación móvil de gestión de inventario y ventas desarrollada con Flutter, utilizando arquitectura modular y BLoC para gestión de estado.

## Características Principales
- Autenticación de usuarios
- Gestión de productos
- Registro de ventas
- Control de inventario
- Generación de reportes

## Requisitos Previos
- Flutter SDK (versión 3.10.0 o superior)
- Dart SDK
- Android Studio o VS Code
- Dispositivo Android/iOS o emulador

## Instalación

1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/iziventas.git
cd iziventas
```

2. Instalar dependencias
```bash
flutter pub get
```

3. Generar archivos de serialización
```bash
flutter pub run build_runner build
```

## Configuración

1. Crear archivo `.env` en la raíz del proyecto
```
API_BASE_URL=http://tu-backend.com/api
JWT_SECRET=tu_secreto_jwt
```

2. Configurar variables de entorno en `lib/core/constants/`

## Ejecución

### Modo Desarrollo
```bash
flutter run
```

### Compilación para Producción
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Arquitectura
- Modular
- Patrón BLoC para gestión de estado
- Separación por módulos (Auth, Products, Sales, Reports)
- Repositorios con fuentes de datos locales y remotas

## Dependencias Principales
- Flutter
- Bloc
- Dio
- Sequelize
- JWT
- Shared Preferences

## Pruebas
```bash
flutter test
```

## Contribución
1. Fork del repositorio
2. Crear rama de feature
3. Commit de cambios
4. Push a la rama
5. Crear Pull Request

## Licencia
[Especificar Licencia]

## Contacto
- Nombre del Desarrollador
- Correo Electrónico
- LinkedIn
```

## Capturas de Pantalla
(Incluir capturas de pantalla de la aplicación)