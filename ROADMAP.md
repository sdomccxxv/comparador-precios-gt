# Roadmap — Comparador de Precios GT

## Estado actual — v1.0 ✅

- Búsqueda de productos por texto en Walmart GT y La Torre
- Comparación de precios en tiempo real vía API VTEX
- Agrupación y coincidencia de productos por EAN
- Badge de producto más barato por par EAN coincidente
- Badge de oferta cuando `Price < ListPrice`
- Escaneo de código de barras con la cámara
- Pantalla de detalle con botón para abrir en la tienda
- Filtro por tienda en resultados
- Backend desplegado en Render.com
- APK instalable en Android

---

## v1.1 — Escaneo y precios 🔧

- [x] Escaneo de código de barras con `mobile_scanner`
- [x] Búsqueda por EAN con endpoint `/buscar-ean` en el backend
- [x] Mostrar precio anterior tachado cuando hay oferta activa
- [x] Resolver bug de producto no encontrado al escanear EAN
- [x] Endpoint `/health` para monitoreo con UptimeRobot
- [x] Configurar UptimeRobot para evitar sleep del servidor en Render

---

## v1.2 — Experiencia de usuario

- [ ] **Historial de búsquedas** — guardar las últimas búsquedas en el dispositivo para repetirlas rápido desde la pantalla principal
- [ ] **Favoritos** — permitir guardar productos de interés y consultarlos sin necesidad de buscarlos de nuevo
- [ ] **Compartir comparación** — botón para compartir la comparación de precios de un producto por WhatsApp mostrando precio en cada tienda
- [ ] **Skeleton loading** — mostrar placeholders animados mientras carga la búsqueda en lugar del spinner actual
- [ ] **Búsqueda reciente en home** — chips con las últimas búsquedas debajo del campo de texto

---

## v1.3 — Funciones avanzadas

- [ ] **Lista del super** — crear una lista de compras, elegir en qué tienda comprar cada producto y calcular el total automáticamente
- [ ] **Alertas de precio** — el servidor revisa periódicamente si un producto bajó de precio y envía una notificación push al celular
- [ ] **Más tiendas** — agregar Paiz y Maxi Despensa (ambos usan VTEX, integración directa posible)
- [ ] **Ordenamiento en resultados** — permitir ordenar por precio, por tienda o por coincidencia EAN
- [ ] **Modo sin conexión** — cachear los últimos resultados para consultarlos sin internet

---

## v2.0 — Inteligencia de precios

- [ ] **Historial de precios** — almacenar precios en base de datos (PostgreSQL) para mostrar si un producto subió o bajó con el tiempo
- [ ] **Gráfica de evolución** — visualizar el precio histórico de un producto en una gráfica dentro del detalle
- [ ] **Widget Android** — acceso rápido al buscador desde la pantalla de inicio sin abrir la app
- [ ] **Notificaciones de oferta** — alertar cuando un producto guardado entra en oferta
- [ ] **Comparación por categoría** — comparar todos los productos de una categoría (ej: lácteos) entre ambas tiendas de una sola vez

---

## Infraestructura y técnico

- [ ] Migrar de Render Free a plan pagado o Azure B1 cuando el tráfico lo justifique
- [ ] Agregar caché en el backend (Redis o in-memory) para reducir llamadas repetidas a la API VTEX
- [ ] Agregar tests automatizados al backend con `pytest`
- [ ] CI/CD con GitHub Actions para deploy automático al hacer push a `main`
- [ ] Renombrar la app de `com.example.flutter_app` a un bundle ID definitivo antes de publicar

---

## Notas técnicas

| Componente | Tecnología | Hosting |
|---|---|---|
| Backend | Python 3.11 + FastAPI + httpx | Render.com (Free) |
| Frontend | Flutter (Dart) | APK directo / Android |
| API de datos | VTEX Legacy Search API | Walmart GT + La Torre |
| Matching de productos | EAN / alternateIds_Ean | — |
| CI/CD | GitHub (manual por ahora) | — |
