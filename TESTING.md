# Guía de Prueba - Comparador de Precios GT

Esta guía te indica paso a paso cómo validar que el proyecto funciona correctamente.

## Requisitos previos
- Python 3.14+ con venv activado
- Flutter SDK instalado
- Android SDK/Emulator configurado (para pruebas de app móvil)
- Git

---

## PARTE 1: Prueba del Backend

### Paso 1.1: Navega a la carpeta backend
```bash
cd backend
```

### Paso 1.2: Activa el entorno virtual (si no está activado)
```powershell
# En PowerShell (recomendado)
& ..\.venv\Scripts\Activate.ps1
```

O alternativamente:
```bash
# Comando a prueba de typo
$act = Join-Path (Resolve-Path ..\.venv\Scripts).Path 'Activate.ps1'
& $act
```

### Paso 1.3: Verifica que las dependencias están instaladas
```bash
python -m pip list | grep fastapi uvicorn
```

Deberías ver:
- fastapi 0.135.2 o superior
- uvicorn 0.42.0 o superior

### Paso 1.4: Inicia el servidor backend
```bash
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Resultado esperado:
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Application startup complete.
```

### Paso 1.5: Prueba en otra terminal - Endpoint raíz
```powershell
# En otra terminal PowerShell
Invoke-WebRequest -Uri 'http://127.0.0.1:8000/' -UseBasicParsing | Select-Object -ExpandProperty Content
```

Resultado esperado:
```json
{"mensaje":"Comparador de Precios GT funcionando ✅"}
```

### Paso 1.6: Prueba búsqueda (ejemplo con "leche")
```powershell
Invoke-WebRequest -Uri 'http://127.0.0.1:8000/buscar?q=leche' -UseBasicParsing | Select-Object -ExpandProperty Content
```

Resultado esperado:
```json
{
  "query": "leche",
  "total": N,
  "walmart_count": M,
  "latorre_count": P,
  "coincidencias": Q,
  "resultados": [...]
}
```

**Nota**: Asegúrate de que cada producto tenga:
- `tienda`: "Walmart GT" o "La Torre"
- `nombre`: nombre del producto
- `precio`: número
- `ean`: código EAN (nuevo campo agregado)
- `imagen`: URL o null
- `url`: enlace a la tienda
- `coincide_ambas`: boolean

### Paso 1.7: Detén el servidor
Presiona CTRL+C en la terminal del servidor.

---

## PARTE 2: Prueba del Frontend

### Paso 2.1: Navega a la carpeta flutter_app
```bash
cd flutter_app
```

### Paso 2.2: Obtén dependencias de Flutter
```bash
flutter pub get
```

Resultado esperado:
```
Got dependencies!
```

### Paso 2.3: Ejecuta el análisis estático
```bash
flutter analyze
```

Resultado aceptado:
```
Analyzing flutter_app...
X issues found. (ran in Xs)
```

Solo son avisos de `unnecessary_underscores` y `deprecated_member_use` en el análisis, son no-bloqueantes.

### Paso 2.4: Ejecuta las pruebas unitarias
```bash
flutter test
```

Resultado esperado:
```
00:XX +N: All tests passed!
```

### Paso 2.5: Construye el APK debug (para probar en dispositivo/emulador)
```bash
flutter build apk --debug
```

Resultado esperado:
```
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

El archivo APK está en: `build/app/outputs/flutter-apk/app-debug.apk`

### Paso 2.6: Corre la app en modo desarrollo (con emulador o dispositivo conectado)
```bash
flutter run
```

Resultado esperado:
- Se abre la app en el emulador/dispositivo
- Ves el logo del Comparador GT
- Está el campo de búsqueda

### Paso 2.7: Prueba manual en la app
1. Escribe "leche" en el campo de búsqueda
2. Presiona "Buscar y comparar"
3. Verifica que aparecen productos de Walmart y La Torre
4. Comprueba que se muestra el EAN en cada tarjeta
5. Toca una tarjeta para ver detalle
6. En detalle verifica que se ve el EAN en la info del producto
7. Presiona "Ver en la tienda" para abrir el enlace

### Paso 2.8: Prueba en modo hot reload
Mientras la app está corriendo en `flutter run`:
1. Edita un archivo en lib/
2. Presiona `r` en la terminal para hot reload
3. Verifica que los cambios se aplican sin recargar la app

---

## PARTE 3: Verificación de integración completa

### Paso 3.1: Asegúrate de que el backend está corriendo
```bash
# En una terminal
cd backend
python -m uvicorn main:app --reload
```

### Paso 3.2: Configura la URL base del frontend
En `flutter_app/lib/services/api_service.dart`:
- Desarrollo local: `http://10.0.2.2:8000` (emulador Android)
- Dispositivo físico: `http://<TU_IP_LOCAL>:8000`
- Producción: URL de Render.com o servidor

### Paso 3.3: Corre la app con backend activo
```bash
cd flutter_app
flutter run
```

### Paso 3.4: Prueba búsqueda end-to-end
1. Abre la app
2. Busca un producto
3. Verifica que se conecta al backend y traen resultados reales
4. Comprueba que en cada tarjeta se muestra el EAN
5. Verifica "coincidencias" si hay productos en ambas tiendas

---

## Troubleshooting

| Problema | Solución |
|----------|----------|
| Backend no inicia | Verifica que el .venv está activado y `pip list` muestra fastapi/uvicorn |
| Error de conexión en Flutter | Usa `http://10.0.2.2:8000` en emulador o `http://<IP_LOCAL>:8000` en dispositivo |
| Tests fallan | Ejecuta `flutter pub get` y luego `flutter test` de nuevo |
| APK no se genera | Intenta `flutter clean` y después `flutter build apk --debug` |
| Sin resultados en búsqueda | Verifica que el backend está corriendo y accesible desde la IP del dispositivo |

---

## Estado del proyecto

✅ Backend compilado y funcionando  
✅ Frontend Flutter compilado y probado  
✅ API de búsqueda operacional  
✅ EAN integrado en respuestas y UI  
✅ Tests de frontend pasando  

---

**Última revisión**: 30/03/2026
**Versión**: 1.0.0
