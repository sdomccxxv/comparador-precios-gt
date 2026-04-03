---
description: "Instrucciones del workspace para Comparador de Precios GT. Se aplican a todas las tareas de Copilot en este repo."
---

# Comparador de Precios GT

## Estructura Del Proyecto
- Este repo contiene una app Flutter en [flutter_app/](flutter_app) y un backend FastAPI en [backend/](backend).
- Supabase es opcional y se usa para persistir el historial de precios cuando las variables de entorno están presentes.
- Prefiere cambios pequeños y focalizados dentro de una sola capa a la vez, salvo que la tarea abarque explícitamente frontend y backend.

## Puntos De Entrada Clave
- API del backend: [backend/main.py](backend/main.py)
- Dependencias y runtime del backend: [backend/requirements.txt](backend/requirements.txt), [backend/runtime.txt](backend/runtime.txt)
- Entrada de la app Flutter: [flutter_app/lib/main.dart](flutter_app/lib/main.dart)
- Cliente HTTP de Flutter: [flutter_app/lib/services/api_service.dart](flutter_app/lib/services/api_service.dart)
- Configuración del paquete Flutter: [flutter_app/pubspec.yaml](flutter_app/pubspec.yaml)
- Pruebas de Flutter: [flutter_app/test/widget_test.dart](flutter_app/test/widget_test.dart)
- Configuración local de Supabase: [supabase/config.toml](supabase/config.toml)

## Convenciones De Trabajo
- Mantén separadas, cuando sea práctico, las ediciones de Flutter y del backend.
- Prefiere los patrones existentes del árbol de código antes que introducir abstracciones nuevas.
- Usa la documentación de [CONTRIBUTING.md](CONTRIBUTING.md), [TESTING.md](TESTING.md), [VERSIONAMIENTO.md](VERSIONAMIENTO.md) y [CHANGELOG.md](CHANGELOG.md) como fuente de verdad para el flujo de trabajo y el comportamiento de releases.
- No dupliques esa documentación dentro de comentarios de código o docs nuevas salvo que la tarea necesite una actualización puntual.
- El flujo de Git sigue GitHub Flow adaptado para un proyecto individual, con Conventional Commits en español y tags de versión semánticos.

## Compilar, Probar Y Ejecutar
- Ejecución local del backend: activa el entorno virtual y luego ejecuta `python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000` desde [backend/](backend).
- Configuración de Flutter: ejecuta `flutter pub get` en [flutter_app/](flutter_app).
- Validación de Flutter: ejecuta `flutter analyze` y `flutter test`.
- APK de release de Flutter: usa [build_release_flutter.ps1](build_release_flutter.ps1) cuando necesites una compilación limpia de release desde Windows.
- Para comprobaciones manuales del backend, sigue el flujo de peticiones documentado en [TESTING.md](TESTING.md).

## Riesgos Importantes
- La URL base de la API de Flutter está fijada en [flutter_app/lib/services/api_service.dart](flutter_app/lib/services/api_service.dart); los emuladores locales pueden necesitar la URL comentada del emulador Android en lugar de producción.
- El historial en [backend/main.py](backend/main.py) se desactiva silenciosamente cuando faltan `SUPABASE_URL` o `SUPABASE_SERVICE_KEY`.
- La búsqueda del backend llama a sitios externos y puede fallar por red o por anti-bot remoto; conserva el timeout y el comportamiento de respaldo salvo que la tarea pida un cambio.
- La app Flutter ya usa Material 3 y los lints actuales de [flutter_app/analysis_options.yaml](flutter_app/analysis_options.yaml); mantén los cambios compatibles con ellos.

## Mapa De Documentación
- Flujo de build y release: [VERSIONAMIENTO.md](VERSIONAMIENTO.md)
- Flujo de pruebas: [TESTING.md](TESTING.md)
- Guía de ramas y commits: [CONTRIBUTING.md](CONTRIBUTING.md)
- Resumen de la app: [flutter_app/README.md](flutter_app/README.md)

## Guía De Edición
- Prefiere el cambio más pequeño que resuelva la tarea.
- Cuando cambies un flujo visible para el usuario, valida las pruebas relacionadas o el comando mínimo relevante.
- Si un cambio solicitado entra en conflicto con el flujo documentado, dilo y ajusta la implementación al comportamiento documentado en lugar de cambiar el flujo en silencio.
