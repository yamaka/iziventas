#!/bin/powershell

# Función para crear directorios
function Create-Directory {
    param(
        [string]$Path
    )
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

# Nombre del proyecto
$ProjectName = "iziventas_mobile"

# Crear proyecto Flutter
flutter create $ProjectName
Set-Location $ProjectName

# Estructura de directorios
$Directories = @(
    "lib\core\constants",
    "lib\core\error",
    "lib\core\network",
    "lib\core\utils",
    "lib\modules\auth\data\datasources",
    "lib\modules\auth\data\models",
    "lib\modules\auth\data\repositories",
    "lib\modules\auth\domain\entities",
    "lib\modules\auth\domain\usecases",
    "lib\modules\auth\presentation\blocs",
    "lib\modules\auth\presentation\pages",
    "lib\modules\auth\presentation\widgets",
    "lib\modules\products\data\datasources",
    "lib\modules\products\data\models",
    "lib\modules\products\data\repositories",
    "lib\modules\products\domain\entities",
    "lib\modules\products\domain\usecases",
    "lib\modules\products\presentation\blocs",
    "lib\modules\products\presentation\pages",
    "lib\modules\products\presentation\widgets",
    "lib\modules\sales\data\datasources",
    "lib\modules\sales\data\models",
    "lib\modules\sales\data\repositories",
    "lib\modules\sales\domain\entities",
    "lib\modules\sales\domain\usecases",
    "lib\modules\sales\presentation\blocs",
    "lib\modules\sales\presentation\pages",
    "lib\modules\sales\presentation\widgets",
    "lib\modules\reports\data\repositories",
    "lib\modules\reports\domain\usecases",
    "lib\modules\reports\presentation\blocs",
    "lib\modules\reports\presentation\pages",
    "lib\modules\reports\presentation\widgets",
    "lib\shared\widgets",
    "lib\shared\theme",
    "assets\images",
    "assets\icons",
    "assets\translations",
    "test\modules\auth",
    "test\modules\products",
    "test\modules\sales",
    "test\modules\reports",
    "test\core"
)

# Crear directorios
foreach ($dir in $Directories) {
    Create-Directory -Path $dir
}

# Crear archivo pubspec.yaml
$PubspecContent = @"
name: iziventas_mobile
description: Aplicación móvil de gestión de inventario y ventas

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^8.1.3
  dio: ^5.3.2
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  intl: ^0.18.1
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.3
  build_runner: ^2.4.6

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
"@

Set-Content -Path "pubspec.yaml" -Value $PubspecContent

# Crear archivo .env
$EnvContent = @"
# Configuración de Backend
API_BASE_URL=http://localhost:3000/api
AUTH_ENDPOINT=/auth
PRODUCTS_ENDPOINT=/products
SALES_ENDPOINT=/sales
REPORTS_ENDPOINT=/reports

# Configuraciones de Seguridad
JWT_SECRET=your_jwt_secret_here
TOKEN_STORAGE_KEY=auth_token

# Modos de Desarrollo
ENV=development
DEBUG=true
"@

Set-Content -Path ".env" -Value $EnvContent

# Crear archivo README.md
$ReadmeContent = @"
# IziVentas Mobile

## Descripción
Aplicación móvil de gestión de inventario y ventas.

## Requisitos Previos
- Flutter SDK
- Dart SDK
- Android Studio o VS Code

## Instalación

1. Clonar el repositorio
``````bash
git clone https://github.com/tu-usuario/iziventas-mobile.git
cd iziventas-mobile
``````

2. Instalar dependencias
``````bash
flutter pub get
``````

3. Ejecutar la aplicación
``````bash
flutter run
``````

## Estructura del Proyecto
- `lib/core/`: Componentes centrales
- `lib/modules/`: Módulos de funcionalidad
- `lib/shared/`: Componentes compartidos
- `test/`: Pruebas unitarias

## Desarrollo

### Generar código
``````bash
flutter pub run build_runner build
``````

### Ejecutar pruebas
``````bash
flutter test
``````

## Licencia
[Especificar Licencia]
"@

Set-Content -Path "README.md" -Value $ReadmeContent

# Instalar dependencias
flutter pub get

Write-Host "Proyecto Flutter '$ProjectName' creado exitosamente!" -ForegroundColor Green
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. cd $ProjectName" -ForegroundColor Cyan
Write-Host "2. flutter pub get" -ForegroundColor Cyan
Write-Host "3. flutter run" -ForegroundColor Cyan