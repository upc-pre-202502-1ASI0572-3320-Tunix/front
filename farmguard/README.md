# FarmGuard 🌾

Aplicación móvil y web para monitoreo y gestión de granjas con IoT.

## 📋 Tabla de Contenidos

- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Configuración del Proyecto](#-configuración-del-proyecto)
- [Configuración de API y Entornos](#-configuración-de-api-y-entornos)
- [Ejecución del Proyecto](#-ejecución-del-proyecto)
- [Despliegue](#-despliegue)

## 🏗️ Arquitectura

Este proyecto utiliza **Clean Architecture** con la siguiente estructura:

```
lib/
├── core/                    # Funcionalidades compartidas
│   ├── config/             # Configuración de la app
│   ├── constants/          # Constantes globales
│   ├── network/            # Cliente HTTP y configuración de red
│   ├── storage/            # Almacenamiento local (tokens, preferencias)
│   ├── errors/             # Manejo de errores
│   └── utils/              # Utilidades generales
│
├── src/                     # Bounded Contexts
│   ├── auth/               # Autenticación
│   ├── shared/             # Widgets y lógica compartida
│   └── [features]/         # Otras características
│
└── main.dart               # Punto de entrada
```

### Principios de Clean Architecture

- **Separation of Concerns**: Cada capa tiene su responsabilidad
- **Dependency Rule**: Las dependencias apuntan hacia adentro
- **Testability**: Código fácil de testear
- **Independence**: Independiente de frameworks y UI

## 📁 Estructura del Proyecto

### Core Layer (`/lib/core`)

Contiene toda la lógica compartida entre bounded contexts:

#### **Config** (`/core/config/`)
- `app_config.dart`: Configuración de URLs de API y entornos
- `platform_config.dart`: Configuración específica por plataforma (web/mobile)

#### **Constants** (`/core/constants/`)
- `api_constants.dart`: Endpoints de la API
- `storage_constants.dart`: Claves de almacenamiento local

#### **Network** (`/core/network/`)
- `api_client.dart`: Cliente HTTP (Dio) con interceptores
  - ✅ Añade automáticamente el token de autenticación
  - ✅ Maneja refresh token cuando expira
  - ✅ Logs en modo desarrollo
  - ✅ Retry automático en caso de token expirado

#### **Storage** (`/core/storage/`)
- `token_storage.dart`: Almacenamiento multiplataforma
  - 📱 **Mobile**: Usa `flutter_secure_storage` (almacenamiento encriptado)
  - 🌐 **Web**: Usa `shared_preferences` (localStorage)

#### **Errors** (`/core/errors/`)
- `failures.dart`: Clases de error tipadas
  - `ServerFailure`: Errores del servidor
  - `ConnectionFailure`: Errores de conexión
  - `AuthFailure`: Errores de autenticación
  - `ValidationFailure`: Errores de validación

#### **Utils** (`/core/utils/`)
- `either.dart`: Tipo `Either<L, R>` para manejo funcional de errores

## ⚙️ Configuración del Proyecto

### Instalación de Dependencias

```bash
cd farmguard
flutter pub get
```

### Dependencias Principales

- **dio** (^5.4.0): Cliente HTTP
- **flutter_secure_storage** (^9.0.0): Almacenamiento seguro en mobile
- **shared_preferences** (^2.2.2): Almacenamiento en web
- **go_router** (^13.0.0): Navegación declarativa

## 🔧 Configuración de API y Entornos

### ¿Cómo Funciona la Configuración?

El proyecto usa **variables de entorno** en tiempo de compilación para configurar diferentes entornos:

#### 1. **Configuración Multiplataforma**

```dart
// lib/core/config/app_config.dart
static String get apiBaseUrl {
  if (kIsWeb) {
    // 🌐 WEB: Usa URL relativa para proxy reverso
    return '/api';  // Nginx redirige a la API real
  } else {
    // 📱 MOBILE: URL directa (segura en binario)
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.farmguard.com',
    );
  }
}
```

**¿Por qué esta diferencia?**

- **Mobile**: Las URLs en el código compilado son seguras (binario no legible)
- **Web**: Las URLs en JavaScript son públicas, por eso usamos proxy reverso

#### 2. **Almacenamiento de Tokens Seguro**

```dart
// lib/core/storage/token_storage.dart
static Future<void> saveToken(String token) async {
  if (kIsWeb) {
    // Web: localStorage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  } else {
    // Mobile: Secure Storage (encriptado)
    await _secureStorage.write(key: 'auth_token', value: token);
  }
}
```

#### 3. **Cliente API con Interceptores**

El `ApiClient` maneja automáticamente:

✅ **Inyección de Token**: Añade `Authorization: Bearer <token>` a cada request
✅ **Refresh Token**: Si el token expira (401), intenta renovarlo automáticamente
✅ **Retry**: Reintenta la petición fallida con el nuevo token
✅ **Logs**: Muestra logs solo en desarrollo

```dart
// Uso en repositories
final apiClient = ApiClient();

final response = await apiClient.post(
  ApiConstants.login,
  data: {'email': email, 'password': password},
);
```

## 🚀 Ejecución del Proyecto

### Desarrollo Local

#### Mobile (Android)

```bash
# Desarrollo con API local (Android Emulator)
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://10.0.2.2:3000

# Staging
flutter run --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging-api.farmguard.com

# Producción
flutter run --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://api.farmguard.com
```

> **Nota**: `10.0.2.2` es la IP del host desde el emulador de Android

#### Mobile (iOS)

```bash
# Desarrollo con API local (iOS Simulator)
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:3000
```

#### Web

```bash
# Desarrollo (usa proxy '/api' configurado)
flutter run -d chrome

# Producción
flutter run -d chrome --dart-define=ENVIRONMENT=production
```

### Construcción para Producción

#### Mobile - Android APK

```bash
flutter build apk --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.farmguard.com
```

#### Mobile - iOS

```bash
flutter build ios --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.farmguard.com
```

#### Web

```bash
flutter build web --release --dart-define=ENVIRONMENT=production
```

## 🌐 Despliegue

### Web - Configuración Nginx

Para evitar problemas de CORS y ocultar la URL de la API, usa un proxy reverso:

```nginx
server {
    listen 443 ssl http2;
    server_name farmguard.com;
    
    # SSL Certificates
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Flutter Web App
    root /var/www/farmguard/build/web;
    index index.html;
    
    # SPA Routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 🔥 Proxy a la API (evita CORS)
    location /api/ {
        proxy_pass https://api.farmguard.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Cache para assets estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Web - Firebase Hosting

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar proyecto
firebase init hosting

# Build y Deploy
flutter build web --release
firebase deploy --only hosting
```

### Web - Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
flutter build web --release
vercel --prod
```

## 📝 Ejemplos de Uso

### Ejemplo: Repository de Autenticación

```dart
import 'package:farmguard/core/core.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      // Guardar tokens automáticamente
      await TokenStorage.saveToken(response.data['token']);
      await TokenStorage.saveRefreshToken(response.data['refreshToken']);

      return Right(User.fromJson(response.data['user']));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure(message: 'Credenciales inválidas'));
      }
      return Left(ServerFailure(message: e.message ?? 'Error del servidor'));
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
```

### Ejemplo: Uso en UI

```dart
final result = await authRepository.login(
  email: emailController.text,
  password: passwordController.text,
);

result.fold(
  (failure) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(failure.message)),
  ),
  (user) => Navigator.pushReplacementNamed(context, '/home'),
);
```

## 🔒 Seguridad

### ✅ Lo que SÍ es seguro:
- URLs base de API (están en el binario compilado)
- Endpoints públicos
- Configuración de timeouts

### ❌ Lo que NUNCA debe estar en el código:
- API Keys secretas
- Passwords hardcodeadas
- Tokens de autenticación estáticos
- Credenciales de bases de datos

### Manejo de Tokens:
1. Usuario hace login
2. Backend responde con `token` y `refreshToken`
3. Se guardan en almacenamiento seguro
4. Cada request incluye automáticamente el token
5. Si expira (401), se renueva automáticamente
6. En logout, se limpian todos los tokens

## 👥 Equipo

Para añadir nuevas características:

1. Crea un nuevo bounded context en `/src/[feature]/`
2. Usa la capa `core` para API, storage y errores
3. Sigue Clean Architecture (domain, data, presentation)
4. Actualiza `api_constants.dart` con nuevos endpoints

## 📚 Recursos

- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dio Package](https://pub.dev/packages/dio)
- [Go Router](https://pub.dev/packages/go_router)
