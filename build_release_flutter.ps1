param(
  [string]$ProjectRoot = $PSScriptRoot,
  [switch]$SkipProcessKill,
  [switch]$SkipClean
)

$ErrorActionPreference = "Stop"

$appPath = Join-Path $ProjectRoot "flutter_app"
$apkPath = Join-Path $appPath "build\app\outputs\flutter-apk\app-release.apk"

function Info($message) {
  Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Ok($message) {
  Write-Host "[OK]   $message" -ForegroundColor Green
}

if (-not (Test-Path $appPath)) {
  throw "No se encontro flutter_app en: $appPath"
}

if (-not $SkipProcessKill) {
  Info "Cerrando procesos que pueden bloquear Gradle..."
  $procNames = @("gradle", "java", "flutter", "dart")
  Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $procNames -contains $_.ProcessName } |
    Stop-Process -Force -ErrorAction SilentlyContinue
  Ok "Procesos de build cerrados"
}

Push-Location $appPath
try {
  if (-not $SkipClean) {
    Info "Limpiando artefactos previos (build/.dart_tool/android/.gradle)..."
    $pathsToRemove = @("build", ".dart_tool", "android/.gradle")
    foreach ($relativePath in $pathsToRemove) {
      if (Test-Path $relativePath) {
        Remove-Item $relativePath -Recurse -Force -ErrorAction SilentlyContinue
      }
    }
    Ok "Limpieza completada"
  }

  Info "Restaurando dependencias"
  flutter pub get

  Info "Construyendo APK release"
  flutter build apk --release

  if (Test-Path $apkPath) {
    $sizeMb = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Ok "APK generado: $apkPath ($sizeMb MB)"
  } else {
    throw "La compilacion termino, pero no se encontro el APK en $apkPath"
  }
}
finally {
  Pop-Location
}
