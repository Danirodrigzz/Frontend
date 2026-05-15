# ChinChin Intercambio 🪙

¡Bienvenido a **ChinChin Intercambio**! Esta es una plataforma web de alto rendimiento diseñada para la gestión y conversión de activos digitales. El objetivo principal es ofrecer una experiencia de usuario fluida, moderna y visualmente atractiva para el ecosistema cripto.

Desarrollada íntegramente con **Flutter Web**, la aplicación combina potencia técnica con un diseño de vanguardia.

---

## ✨ Lo que hace especial a este proyecto

A diferencia de un dashboard convencional, aquí me enfoqué en los detalles que marcan la diferencia:

*   **💎 Estética Premium**: He implementado un diseño basado en *Glassmorphism* (efecto cristal) y modos oscuros profundos, inspirados en las mejores aplicaciones Fintech actuales.
*   **⚡ Datos al Instante**: Conexión directa con la API de Binance para obtener precios en tiempo real. ¡Nada de datos estáticos!
*   **🎨 Animaciones Vivas**: Desde el fondo de partículas en el login hasta las transiciones suaves entre páginas, todo está animado para que la app se sienta "viva".
*   **📊 Análisis Visual**: Gráficos interactivos de precios (velas/líneas) para que puedas ver la tendencia de tus activos favoritos.
*   **🇻🇪 Contexto Local**: Conversión automática a **Petros (PTR)** y **Bolívares (Bs)**, adaptada a la realidad del mercado venezolano.

---

## 🚀 Funcionalidades Principales

### 🔐 Seguridad y Acceso
*   **Sistema de Auth**: Registro e inicio de sesión funcional con validación de formularios en tiempo real.
*   **Sesiones Persistentes**: Tu sesión se mantiene activa aunque refresques el navegador.
*   **Rutas Protegidas**: Nadie entra al dashboard sin pasar por la puerta de seguridad.

### 📈 Mercado en Vivo
*   **Monitor 24h**: Lista completa de criptos con su precio, volumen y cambio porcentual.
*   **Buscador Inteligente**: Encuentra cualquier moneda por su nombre o símbolo al instante.
*   **Detalle Profundo**: Haz clic en cualquier activo para ver su gráfico histórico y estadísticas clave.

### 🔄 Intercambio (Swap)
*   **Calculadora Inteligente**: Selecciona qué vendes y qué recibes, y la app hace las matemáticas por ti.
*   **Tasa Garantizada**: Un contador de expiración te asegura el precio durante el proceso.
*   **Validación de Fondos**: No te deja gastar lo que no tienes, con alertas visuales integradas.
*   **Historial**: Registro detallado de cada operación para que nunca pierdas el rastro de tus movimientos.

---

## 🛠️ El Motor Bajo el Capó (Stack Técnico)

He utilizado las mejores herramientas del ecosistema Flutter para garantizar escalabilidad:

*   **Estado**: [Riverpod](https://riverpod.dev/) (El estándar de oro para apps reactivas).
*   **Navegación**: [GoRouter](https://pub.dev/packages/go_router) para una gestión de rutas limpia y profesional.
*   **Networking**: [Dio](https://pub.dev/packages/dio) para peticiones HTTP eficientes.
*   **Gráficos**: [FL Chart](https://pub.dev/packages/fl_chart) para visualizaciones dinámicas.
*   **Diseño**: Google Fonts (Inter & JetBrains Mono) y [flutter_animate](https://pub.dev/packages/flutter_animate).

---

## 🏗️ Estructura Organizada

El código sigue una arquitectura basada en **features** (características), lo que facilita su mantenimiento:

```
lib/
├── core/         # El corazón: Temas, constantes y utilidades globales.
├── features/     # Módulos: Auth, Market, Intercambio, Portfolio, History...
├── shared/       # Lo común: Widgets y Layouts reutilizables.
└── routing/      # El mapa: Definición de rutas y seguridad.
```

---

## ⚙️ Cómo ponerlo a marchar

1.  Asegúrate de tener **Flutter 3.10** o superior instalado.
2.  Clona este repo: `git clone https://github.com/Danirodrigzz/Frontend.git`
3.  Entra a la carpeta: `cd Frontend`
4.  Baja las dependencias: `flutter pub get`
5.  ¡Dale play!: `flutter run -d chrome`

---

## 📝 Datos de Referencia

| Moneda | Tasa de Cambio |
| :--- | :--- |
| **Petro (PTR)** | 1 PTR = 60.00 USD |
| **Bolívar (Bs)** | 1 USD = 37.85 Bs |

---

Diseñado y construido con ❤️ como prueba técnica para **Chinchin** 🚀
