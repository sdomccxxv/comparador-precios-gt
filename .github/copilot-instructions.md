---
description: "Workspace instructions for Comparador de Precios GT. Applies to all Copilot coding tasks in this repo."
---

# Comparador de Precios GT

## Project Shape
- This repo contains a Flutter app in [flutter_app/](flutter_app) and a FastAPI backend in [backend/](backend).
- Supabase is optional and is used for price history persistence when environment variables are present.
- Prefer small, focused changes within one layer at a time unless the task explicitly spans frontend and backend.

## Key Entry Points
- Backend API: [backend/main.py](backend/main.py)
- Backend dependencies and runtime: [backend/requirements.txt](backend/requirements.txt), [backend/runtime.txt](backend/runtime.txt)
- Flutter app entry: [flutter_app/lib/main.dart](flutter_app/lib/main.dart)
- Flutter API client: [flutter_app/lib/services/api_service.dart](flutter_app/lib/services/api_service.dart)
- Flutter package config: [flutter_app/pubspec.yaml](flutter_app/pubspec.yaml)
- Flutter tests: [flutter_app/test/widget_test.dart](flutter_app/test/widget_test.dart)
- Supabase local config: [supabase/config.toml](supabase/config.toml)

## Working Conventions
- Keep Flutter and backend edits separated when practical.
- Prefer the existing patterns in the source tree over introducing new abstractions.
- Use the documentation in [CONTRIBUTING.md](CONTRIBUTING.md), [TESTING.md](TESTING.md), [VERSIONAMIENTO.md](VERSIONAMIENTO.md), and [CHANGELOG.md](CHANGELOG.md) as the source of truth for workflow and release behavior.
- Do not duplicate documentation from those files inside code comments or new docs unless the task needs a focused update.
- Git workflow follows GitHub Flow adapted for a solo project, with Conventional Commits in Spanish and semantic version tags.

## Build, Test, and Run
- Backend local run: activate the virtual environment, then run `python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000` from [backend/](backend).
- Flutter setup: run `flutter pub get` in [flutter_app/](flutter_app).
- Flutter validation: run `flutter analyze` and `flutter test`.
- Flutter release APK: use [build_release_flutter.ps1](build_release_flutter.ps1) when you need a clean release build from Windows.
- For manual backend checks, follow the request flow documented in [TESTING.md](TESTING.md).

## Important Pitfalls
- The Flutter API base URL is hardcoded in [flutter_app/lib/services/api_service.dart](flutter_app/lib/services/api_service.dart); local emulators may need the commented Android emulator URL instead of production.
- History tracking in [backend/main.py](backend/main.py) is silently disabled when `SUPABASE_URL` or `SUPABASE_SERVICE_KEY` are missing.
- The backend search calls external sites and can fail because of network or remote anti-bot behavior; keep timeout and fallback behavior intact unless the task requires a change.
- The Flutter app already uses Material 3 and the current lints from [flutter_app/analysis_options.yaml](flutter_app/analysis_options.yaml); keep changes compatible with them.

## Documentation Map
- Build and release workflow: [VERSIONAMIENTO.md](VERSIONAMIENTO.md)
- Test workflow: [TESTING.md](TESTING.md)
- Branching and commit guidance: [CONTRIBUTING.md](CONTRIBUTING.md)
- App overview: [flutter_app/README.md](flutter_app/README.md)

## Editing Guidance
- Prefer the smallest change that solves the task.
- When changing a user-facing flow, validate the related tests or the smallest relevant run command.
- If a requested change conflicts with the documented workflow, call that out and align the implementation with the documented behavior instead of silently changing the workflow.
