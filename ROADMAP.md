# Roadmap — Comparador de Precios GT

## Estado actual — v1.2 ✅

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
- Historial de precios en Supabase (PostgreSQL)
- Gráfica de evolución de precios en pantalla de detalle
- Cron job diario para actualización automática del historial

---

## v1.1 — Escaneo y precios ✅

- [x] Escaneo de código de barras con `mobile_scanner`
- [x] Búsqueda por EAN con endpoint `/buscar-ean` en el backend
- [x] Mostrar precio anterior tachado cuando hay oferta activa
- [x] Resolver bug de producto no encontrado al escanear EAN
- [x] Endpoint `/health` para monitoreo con UptimeRobot
- [x] Configurar UptimeRobot para evitar sleep del servidor en Render

---

## v1.2 — Experiencia de usuario ✅

- [x] **Historial de precios** — guardar precio + fecha en Supabase cada vez que se consulta un EAN
- [x] **Gráfica de evolución** — visualizar precio histórico con fl_chart en la pantalla de detalle
- [x] **Deduplicación diaria** — evitar registros duplicados del mismo EAN+tienda por día
- [x] **Cron job diario** — Edge Function en Supabase que actualiza el historial automáticamente cada día
- [x] **Skeleton loading** — placeholders animados mientras carga la búsqueda
- [x] **Historial de búsquedas** — chips con las últimas búsquedas debajo del campo de texto
- [x] **Mejoras visuales** — color de tienda en fondo de tarjetas, separador sin EAN visible

---

## v1.3 — Funciones avanzadas

- [ ] **Lista del super** — crear una lista de compras, elegir en qué tienda comprar cada producto y calcular el total automáticamente
- [ ] **Alertas de precio** — el servidor revisa periódicamente si un producto bajó de precio y envía una notificación push al celular
- [ ] **Más tiendas** — agregar Paiz y Maxi Despensa (ambos usan VTEX, integración directa posible)
- [ ] **Ordenamiento en resultados** — permitir ordenar por precio, por tienda o por coincidencia EAN
- [ ] **Modo sin conexión** — cachear los últimos resultados para consultarlos sin internet
- [ ] **Tendencia de precio** — indicador visual (↑↓) que muestra si el precio subió o bajó respecto al registro anterior

---

## v2.0 — Inteligencia de precios

- [ ] **Widget Android** — acceso rápido al buscador desde la pantalla de inicio sin abrir la app
- [ ] **Notificaciones de oferta** — alertar cuando un producto guardado entra en oferta
- [ ] **Comparación por categoría** — comparar todos los productos de una categoría (ej: lácteos) entre ambas tiendas de una sola vez

---

## Infraestructura y técnico

- [ ] Migrar de Render Free a plan pagado o Azure B1 cuando el tráfico lo justifique
- [ ] Agregar caché en el backend (Redis o in-memory) para reducir llamadas repetidas a la API VTEX
- [ ] Agregar tests automatizados al backend con `pytest`
- [ ] Tests unitarios Flutter para `ApiService` y modelos
- [ ] CI/CD con GitHub Actions para deploy automático al hacer push a `main`
- [ ] Renombrar la app de `com.example.flutter_app` a un bundle ID definitivo antes de publicar
- [ ] Limpieza automática de registros de historial mayores a 1 año (pg_cron)

---

## Notas técnicas

| Componente | Tecnología | Hosting |
|---|---|---|
| Backend | Python 3.11 + FastAPI + httpx | Render.com (Free) |
| Frontend | Flutter (Dart) | APK directo / Android |
| Base de datos | PostgreSQL (Supabase) | Supabase (Free) |
| API de datos | VTEX Legacy Search API | Walmart GT + La Torre |
| Matching de productos | EAN / alternateIds_Ean | — |
| CI/CD | GitHub (manual por ahora) | — |