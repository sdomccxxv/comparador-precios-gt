# Changelog — Comparador de Precios GT

Todos los cambios notables de este proyecto están documentados en este archivo.
El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y el proyecto sigue [Versionamiento Semántico](https://semver.org/lang/es/).

---

## [Unreleased]

---
## [1.2.0] - 2026-04-01

### Added
- Integración con Supabase para persistencia de historial de precios
- Tabla `historial_precios` en PostgreSQL con campos: ean, tienda, nombre, marca, precio, fecha
- Endpoint `GET /historial/{ean}` en el backend para consultar evolución de precios por EAN
- Guardado automático de precios en cada búsqueda con deduplicación de 24 horas por producto/tienda
- Modelo `HistorialPrecio` en Flutter con campos: ean, tienda, precio, fecha
- Método `ApiService.obtenerHistorial(ean)` para consumir el nuevo endpoint
- Gráfica de evolución de precios en `DetailScreen` usando `fl_chart`
- Dos líneas en la gráfica: Walmart GT (azul) y La Torre (naranja), con tooltip al tocar
- Estado de carga con spinner y mensaje cuando no hay suficiente historial aún
- Contenedor visual `_ChartContainer` reutilizable para la gráfica

### Changed
- `DetailScreen` migrado de `StatelessWidget` a `StatefulWidget` para soportar carga asíncrona del historial
- Texto "Precio" cambiado a "Precio actual" en la tarjeta de detalle
- Colores de tiendas actualizados: Walmart GT `#1A75CF`, La Torre `#F36A10`
- `requirements.txt` actualizado con dependencia `supabase`

[1.2.0]: https://github.com/sdomccxxv/comparador-precios-gt/compare/v1.1.1...v1.2.0

---
## [1.1.1] - 2026-04-01

### Added
- Endpoint `/health` con soporte GET y HEAD para monitoreo externo
- Configurar UptimeRobot para evitar sleep del servidor en Render

### Fixed
- Escaneo de EAN ahora navega correctamente a la pantalla de resultados
- Método HEAD no permitido en `/health` causaba falsa alarma en UptimeRobot

[1.1.1]: https://github.com/sdomccxxv/comparador-precios-gt/compare/v1.1.0...v1.1.1

## [1.1.0] - 2026-04-01

### Added
- Escaneo de código de barras con la cámara usando `mobile_scanner`
- Endpoint `/buscar-ean` en el backend con filtro `fq=alternateIds_Ean` de VTEX
- Fallback automático a búsqueda por texto si el EAN no da resultados
- Manejo de EANs con y sin cero inicial (normalización con `lstrip('0')`)
- Botón "Escanear código de barras" en la pantalla principal
- Linterna activable desde la pantalla del escáner
- Overlay con recuadro de escaneo y esquinas destacadas en azul
- Permiso de cámara (`CAMERA`) en `AndroidManifest.xml`
- Campo `precio_antes` en el backend cuando `ListPrice > Price`
- Precio anterior tachado en tarjetas de producto cuando hay oferta activa
- Badge "Oferta" en verde cuando el producto tiene descuento
- Borde verde en tarjetas con oferta o precio más barato
- Getter `tieneOferta` en el modelo `Producto`

### Changed
- `extraer_precio` ahora prioriza `Price` sobre `ListPrice` para mostrar el precio real de venta
- Ordenamiento de resultados: primero EAN coincidentes agrupados, luego con EAN sin coincidencia, luego sin EAN
- El badge "Más barato" ahora resalta el producto más económico dentro de su grupo EAN, no el más barato en general

### Fixed
- Precio incorrecto al usar `FullSellingPrice` en lugar de `Price`
- EANs con distinto número de dígitos entre tiendas no coincidían por ceros al inicio

[1.1.0]: https://github.com/sdomccxxv/comparador-precios-gt/compare/v1.0.0...v1.1.0

---

## [1.0.0] - 2026-03-31

### Added

#### Backend (Python + FastAPI)
- Servidor FastAPI con CORS habilitado para cualquier origen
- Endpoint `GET /` de bienvenida
- Endpoint `GET /buscar?q=` para búsqueda simultánea en ambas tiendas
- Consulta paralela a Walmart GT y La Torre usando `asyncio.gather`
- Integración con la API VTEX Legacy Search (`/api/catalog_system/pub/products/search`)
- Aceptación de respuestas HTTP 200 y 206 (Partial Content) de VTEX
- Extracción de precio desde `items[0].sellers[0].commertialOffer.Price`
- Extracción de imagen desde `items[0].images[0].imageUrl`
- Extracción de EAN desde `items[0].ean` y `items[0].referenceId`
- Campo `coincide_ambas` en cada producto del response
- Campo `coincidencias` en el resumen del response
- Headers de User-Agent para evitar bloqueo por las APIs VTEX
- `requirements.txt` con `fastapi`, `uvicorn[standard]` e `httpx`
- `Procfile` con comando de arranque para Render.com
- `runtime.txt` fijando Python 3.11 para el despliegue
- Despliegue exitoso en Render.com en plan gratuito
- Inclusión de backend y archivos base para despliegue

#### Frontend (Flutter + Dart)
- Modelo `Producto` con campos: tienda, nombre, marca, precio, url, imagen, ean, coincideAmbas
- Servicio `ApiService` con método `buscarProductos` y timeout de 60 segundos
- URL base apuntando al servidor en Render.com
- Pantalla principal (`HomeScreen`) con campo de búsqueda y botón "Buscar y comparar"
- Badges de Walmart GT y La Torre en la pantalla principal
- Mensaje de error visible cuando el servidor no responde
- Pantalla de resultados (`ResultsScreen`) con filtros por tienda
- Badge "EAN coincidente" en ámbar para productos que existen en ambas tiendas
- Badge "Más barato" en verde para el producto de menor precio
- Imagen del producto con placeholder cuando no está disponible
- Pantalla de detalle (`DetailScreen`) con imagen grande, precio destacado y EAN
- Botón "Ver en la tienda" que abre la URL del producto en el navegador externo
- Colores diferenciados por tienda: azul para Walmart GT, rojo para La Torre
- Permiso de internet (`INTERNET`) en `AndroidManifest.xml`
- Dependencias: `http`, `url_launcher`, `mobile_scanner`
- Compilación y distribución como APK de release

### Changed
- Mejoras en extracción de precios y en la agrupación de coincidencias EAN
- Ajustes al proceso de build release en Android
- Actualización de pruebas de frontend para la pantalla inicial
- Ajustes de compatibilidad visual: opacidad y visualización de EAN en tarjetas

### Fixed
- Correcciones de overflow en pantalla de resultados
- Correcciones en backend para priorizar coincidencias y extraer EAN desde `items`
- Corrección del PATH de Flutter en Windows para uso desde PowerShell
- Corrección del `.gitignore_global` de Windows que bloqueaba archivos `.txt`

### Documentation
- `README.md` con descripción del proyecto
- `ROADMAP.md` con plan de mejoras por versión
- `VERSIONAMIENTO.md` con guía de versionamiento semántico y flujo de releases
- Guía de testing paso a paso
- Estandarización del flujo Git y contribución

[1.0.0]: https://github.com/sdomccxxv/comparador-precios-gt/releases/tag/v1.0.0

---

## [0.1.0] - 2026-03-30

### Added
- Confirmación de que Walmart GT y La Torre usan la plataforma VTEX
- Identificación del endpoint público de búsqueda VTEX mediante inspección de Network en DevTools
- Verificación de que ambas APIs responden con productos y precios reales
- Análisis de la estructura JSON de VTEX: sellers, commertialOffer, items, referenceId
- Identificación del campo EAN en `items[0].referenceId` con Key `"EAN"`
- Confirmación del status HTTP 206 como respuesta válida de VTEX
- Decisión de arquitectura: backend Python en la nube + app Flutter en Android
- Decisión de no usar scraping gracias a las APIs públicas de VTEX
