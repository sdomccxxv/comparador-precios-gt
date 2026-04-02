# Guía de versionamiento de la APK — Comparador GT

## Cómo funciona el versionamiento en Flutter

Flutter usa dos valores en `pubspec.yaml` para versionar la app:

```yaml
version: 1.0.0+1
#        ^^^^^  ^
#        |      └── versionCode (número interno, solo Android lo ve)
#        └───────── versionName (número visible al usuario)
```

- `versionName` → lo que el usuario ve (ej: "1.2.0")
- `versionCode` → número entero que siempre sube de 1 en 1, nunca baja

---

## Convención de versiones (Semántico)

```
MAJOR.MINOR.PATCH
  │     │     └── Corrección de bugs (1.0.1, 1.0.2...)
  │     └──────── Nueva función sin romper nada (1.1.0, 1.2.0...)
  └────────────── Cambio grande o rediseño (2.0.0...)
```

### Ejemplos para este proyecto

| Versión | Cuándo usarla |
|---|---|
| `1.0.1` | Se corrigió el bug del escáner EAN |
| `1.1.0` | Se agregó historial de búsquedas |
| `1.2.0` | Se agregaron favoritos y compartir |
| `1.3.0` | Se agregó lista del super |
| `2.0.0` | Se rediseñó la app o se agregó historial de precios |

---

## Paso a paso para versionar y compilar

### Paso 1 — Actualizar la versión en `pubspec.yaml`

Abre `flutter_app/pubspec.yaml` y cambia la línea `version`:

```yaml
# Antes (v1.0)
version: 1.0.0+1

# Después (corrección de bug)
version: 1.0.1+2

# Después (nueva función)
version: 1.1.0+3
```

> El `versionCode` (+N) siempre sube de 1 en 1, nunca repitas un número.

---

### Paso 2 — Registrar el cambio en `CHANGELOG.md`

Crea o actualiza el archivo `CHANGELOG.md` en la raíz del proyecto:

```markdown
## [1.0.1] - 2026-04-01
### Corregido
- Bug al escanear EAN con la cámara no encontraba producto
- Precio anterior ahora se muestra correctamente tachado

## [1.0.0] - 2026-03-31
### Inicial
- Búsqueda de productos en Walmart GT y La Torre
- Comparación de precios con coincidencia por EAN
- Escaneo de código de barras
- Pantalla de detalle con link a la tienda
```

---

### Paso 3 — Compilar el APK de release

```powershell
cd flutter_app
flutter build apk --release
```

El APK se genera en:
```
flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

Para tener el nombre de versión en el archivo, renómbralo:

```powershell
# PowerShell
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" `
          "build\app\outputs\flutter-apk\comparador-gt-v1.0.1.apk"
```

---

### Paso 4 — Hacer commit y tag en Git

```powershell
cd ..  # volver a la raíz del proyecto
git add flutter_app/pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 1.0.1+2"

# Crear tag con la versión
git tag v1.0.1
git push origin main --tags
```

El tag en GitHub te permite ver exactamente qué código corresponde a cada APK distribuida.

---

### Paso 5 — Crear un Release en GitHub (opcional pero recomendado)

1. Ve a tu repo en GitHub
2. Clic en **"Releases"** → **"Create a new release"**
3. Selecciona el tag `v1.0.1`
4. Escribe el título: `v1.0.1 — Corrección escaneo EAN`
5. Pega el contenido del CHANGELOG de esa versión
6. Sube el APK renombrado como archivo adjunto
7. Clic en **"Publish release"**

Así tienes un historial descargable de cada versión.

---

## Resumen del flujo completo

```
1. Hacer cambios en el código
        ↓
2. Actualizar version en pubspec.yaml
        ↓
3. Actualizar CHANGELOG.md
        ↓
4. flutter build apk --release
        ↓
5. Renombrar el APK con la versión
        ↓
6. git commit + git tag + git push --tags
        ↓
7. Crear Release en GitHub con el APK adjunto
```

---

## Referencia rápida de comandos

```powershell
# Ver versión actual
Select-String -Path flutter_app\pubspec.yaml -Pattern "^version"

# Compilar release
cd flutter_app && flutter build apk --release

# Tagear versión
git tag v1.0.1 && git push origin main --tags

# Ver todos los tags
git tag --list
```