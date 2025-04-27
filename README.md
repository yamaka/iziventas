
# Configuracion y Ejecucion del Backend
==========================

Esta guia te ayudar  a configurar y ejecutar el backend para la aplicaci n de gesti o de inventario y ventas.

## Requisitos previos
---------------

* Docker instalado en tu m quina
* Docker Compose instalado en tu m quina
* Cliente de MySQL instalado en tu m quina (opcional)

## Paso 1: Crear una base de datos de MySQL
---------------------------------

Crea una base de datos de MySQL utilizando el script `backend/init.sql`. Puedes hacer esto ejecutando el siguiente comando:

## Paso 2: Construir la Imagen de Docker
------------------------------

Construye la imagen de Docker para el backend usando el archivo `backend/Dockerfile`. Ejecuta el siguiente comando:

```bash
docker build -t inventory-sales-api backend
```

## Step 3: Create a Docker Compose File
--------------------------------------

Crea un archivo de Docker Compose llamado `docker-compose.yml` en el directorio raiz de tu proyecto. Copia el contenido de `backend/docker-compose.yml` en este archivo.

## Paso 4: Iniciar los Contenedores
-----------------------------

Inicia los contenedores utilizando Docker Compose:

```bash
docker-compose up -d
```

Esto iniciar  la base de datos de MySQL y la API de backend en modo desacoplado.

## Paso 5: Verificar la Configuración
-------------------------

Verifica que la configuración esté funcionando revisando los registros:

```bash
docker-compose logs -f
```

Debes ver los registros de la API de backend y la base de datos de MySQL.

## Paso 6: Probar la API
---------------------

Prueba la API enviando una solicitud a `http://localhost:3000`. Puedes utilizar una herramienta como `curl` o un cliente REST como Postman.

```bash
curl http://localhost:3000
```
Debes ver una respuesta.

## Solucionar Problemas
--------------------

Si tienes problemas durante el proceso de configuraci n, revisa los registros para ver los errores:

```bash
docker-compose logs -f
```

Tambi n puedes intentar detener y reiniciar los contenedores:

```bash
docker-compose down
docker-compose up -d
```

## Variables de Entorno
-----------------------

La API de backend utiliza variables de entorno para configurar la conexi n de base de datos y otras configuraciones. Puedes establecer estas variables en el archivo `docker-compose.yml` o en un archivo `.env`.

## Documentaci n de la API
-------------------

La documentaci n de la API est  disponible en el archivo `backend/api-documentation.md`.

Eso es todo! Ahora deber as tener el backend en funcionamiento.



# IziVentas Mobile

## Descripción
Aplicación móvil de gestión de inventario y ventas.

## Requisitos Previos
- Flutter SDK
- Dart SDK
- Android Studio o VS Code

## Instalación

1. ingresar en el directorio del front
```bash
cd iziventas-mobile
```

2. Instalar dependencias
```bash
flutter pub get
```

3. Ejecutar la aplicación
```bash
flutter run
```

## Estructura del Proyecto
- lib/core/: Componentes centrales
- lib/modules/: Módulos de funcionalidad
- lib/shared/: Componentes compartidos
- 	est/: Pruebas unitarias

## Desarrollo

### Generar código
```bash
flutter pub run build_runner build
```

### Ejecutar pruebas
```bash
flutter test
```



