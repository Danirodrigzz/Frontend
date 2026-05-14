# ChinChin Exchange 🪙

Plataforma de intercambio de criptomonedas desarrollada con **Flutter Web**. Permite consultar precios en tiempo real, gestionar un portafolio de activos digitales y realizar intercambios simulados entre criptomonedas.

## 📸 Capturas de pantalla

| Login | Mercado | Intercambio |
|-------|---------|-------------|
| Pantalla de inicio de sesión con partículas animadas | Tabla de criptos con precios en tiempo real | Interfaz de swap con cálculo automático |

## 🚀 Funcionalidades

### Autenticación
- ✅ Registro de usuarios con validación de formularios
- ✅ Inicio de sesión con email y contraseña
- ✅ Almacenamiento seguro de tokens de sesión
- ✅ Protección de rutas (guards de autenticación)
- ✅ Cierre de sesión

### Consulta de datos
- ✅ Tabla de criptomonedas con precios en tiempo real (API de Binance)
- ✅ Actualización automática cada 30 segundos con indicador visual
- ✅ Búsqueda por nombre o símbolo
- ✅ Ordenamiento por precio, cambio %, volumen, nombre
- ✅ Vista detallada con gráfico interactivo de precios
- ✅ Conversión automática a PTR (1 PTR = 60 USD) y Bs (37.85 Bs = 1 USD)

### Intercambio de criptomonedas
- ✅ Selección de cripto origen y destino
- ✅ Cálculo automático de la cantidad a recibir
- ✅ Tasa de cambio en tiempo real con countdown de expiración
- ✅ Validación de saldo disponible
- ✅ Actualización inmediata del portafolio tras el intercambio

### Funcionalidades extra
- ✅ Historial completo de transacciones realizadas
- ✅ Sección de configuración (mostrar/ocultar secciones, auto-refresh)
- ✅ Portafolio con valor total en USD, PTR y Bs
- ✅ Diseño responsive (desktop y mobile)
- ✅ Animaciones y micro-interacciones premium

## 🛠️ Tecnologías

| Tecnología | Uso |
|---|---|
| **Flutter 3.38** | Framework principal (web) |
| **Dart 3.10** | Lenguaje de programación |
| **Riverpod** | Gestión de estado reactiva |
| **GoRouter** | Enrutamiento declarativo con guards |
| **Dio** | Cliente HTTP para API de Binance |
| **FL Chart** | Gráficos de precios interactivos |
| **flutter_animate** | Animaciones declarativas |
| **Google Fonts** | Tipografía (Inter, JetBrains Mono) |
| **SharedPreferences** | Almacenamiento local |

## 📁 Estructura del proyecto

```
lib/
├── main.dart                     # Punto de entrada
├── app.dart                      # Configuración de MaterialApp
├── core/                         # Núcleo compartido
│   ├── constants/                # Constantes (API, app)
│   ├── theme/                    # Sistema de diseño
│   ├── utils/                    # Utilidades (formatters, validators)
│   └── network/                  # Cliente HTTP
├── features/                     # Módulos funcionales
│   ├── auth/                     # Autenticación
│   ├── market/                   # Mercado de criptos
│   ├── exchange/                 # Intercambio
│   ├── portfolio/                # Portafolio del usuario
│   ├── history/                  # Historial de transacciones
│   └── settings/                 # Configuración
├── shared/                       # Componentes reutilizables
│   ├── widgets/                  # Widgets compartidos
│   └── layouts/                  # Layouts base
└── routing/                      # Navegación y guards
```

## 🏃 Cómo ejecutar

### Prerrequisitos
- Flutter SDK 3.10+
- Navegador web moderno (Chrome recomendado)

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/Danirodrigzz/Frontend.git
cd Frontend

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo (web)
flutter run -d chrome
```

### Build de producción

```bash
# Generar build web optimizado
flutter build web --release

# Los archivos se generan en build/web/
```

## 🎨 Diseño

- **Modo oscuro premium** con paleta turquesa inspirada en Chinchin
- **Glassmorphism** en tarjetas y paneles
- **Animaciones staggered** en la carga de elementos
- **Parallax** con partículas animadas en el login
- **Micro-animaciones** en precios, hover effects y transiciones
- **Tipografía profesional** con Inter y JetBrains Mono para datos financieros

## 🔗 API utilizada

- **Binance API v3** (pública, sin autenticación)
  - `/api/v3/ticker/24hr` — Estadísticas 24h
  - `/api/v3/klines` — Datos de velas para gráficos
  - `/api/v3/ticker/price` — Precios individuales

## 📝 Valores fijos

| Moneda | Valor |
|--------|-------|
| **PTR (Petro)** | 1 PTR = 60 USD |
| **BS (Bolívar)** | 37.85 BS = 1 USD |

---

Desarrollado como prueba técnica para **Chinchin** 🚀
