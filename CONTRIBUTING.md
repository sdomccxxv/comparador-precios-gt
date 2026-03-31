# Guia de Flujo Git

Este repositorio usa **GitHub Flow adaptado** (simple y efectivo para apps Flutter + backend).

## 1. Ramas
- `main`: rama estable y desplegable.
- `feature/<area>-<descripcion>`: nuevas funcionalidades.
- `fix/<area>-<descripcion>`: correcciones de errores.
- `chore/<area>-<descripcion>`: tareas de mantenimiento.
- `docs/<area>-<descripcion>`: cambios de documentacion.
- `refactor/<area>-<descripcion>`: mejoras internas sin cambiar comportamiento.

Ejemplos:
- `feature/flutter-buscador-precios`
- `fix/backend-timeout-api`
- `chore/repo-actualiza-gitignore`

## 2. Commits (Conventional Commits en espanol)
Formato:
- `tipo(scope): descripcion en imperativo`

Tipos permitidos:
- `feat`: nueva funcionalidad
- `fix`: correccion de bug
- `docs`: documentacion
- `style`: formato/cambios sin logica
- `refactor`: mejora interna sin cambios funcionales
- `test`: pruebas
- `chore`: mantenimiento/build/config
- `perf`: mejora de rendimiento
- `ci`: integracion/automatizacion

Ejemplos:
- `feat(flutter): agrega filtro por categoria`
- `fix(backend): corrige parseo de respuesta json`
- `chore(repo): actualiza reglas de gitignore`

## 3. Flujo de trabajo
1. Crear rama desde `main`.
2. Hacer cambios pequenos y commits atomicos.
3. Subir rama y abrir Pull Request hacia `main`.
4. Revisar y aprobar PR.
5. Hacer squash merge para mantener historial limpio.

## 4. Reglas de Pull Request
- Titulo claro y en espanol.
- Describir: problema, solucion y como probar.
- Incluir evidencia si aplica (capturas, logs, pasos).
- PR pequeno y enfocado en una sola cosa.

## 5. Versionado y releases
- Crear tags semanticos en `main`: `vX.Y.Z`.
- `feat` suma minor, `fix` suma patch, breaking change suma major.

## 6. Recomendaciones para este repo
- Mantener cambios de `flutter_app/` y `backend/` en commits separados cuando sea posible.
- Evitar mezclar refactor y feature en el mismo commit.
