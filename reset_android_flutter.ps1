param(
  [string]$ProjectRoot = $PSScriptRoot,
  [string]$AvdName = "Medium_Phone_API_36.1",
  [switch]$StartEmulator,
  [switch]$RunApp,
  [int]$BootTimeoutSeconds = 90
)

$ErrorActionPreference = "Continue"

$appPath = Join-Path $ProjectRoot "flutter_app"
$sdkRoot = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$adbPath = Join-Path $sdkRoot "platform-tools\adb.exe"
$emulatorPath = Join-Path $sdkRoot "emulator\emulator.exe"

function Info($message) {
  Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Ok($message) {
  Write-Host "[OK]   $message" -ForegroundColor Green
}

function Warn($message) {
  Write-Host "[WARN] $message" -ForegroundColor Yellow
}

if (-not (Test-Path $appPath)) {
  Write-Error "No se encontro flutter_app en: $appPath"
  exit 1
}

Info "Cerrando procesos que suelen bloquear la compilacion..."
$procNames = @("gradle", "java", "flutter", "dart", "adb", "emulator", "qemu-system-x86_64")
Get-Process -ErrorAction SilentlyContinue |
  Where-Object { $procNames -contains $_.ProcessName } |
  Stop-Process -Force -ErrorAction SilentlyContinue
Ok "Procesos cerrados"

Info "Limpiando artefactos de build..."
$pathsToRemove = @(
  (Join-Path $appPath "build"),
  (Join-Path $appPath ".dart_tool"),
  (Join-Path $appPath "android\.gradle"),
  (Join-Path $appPath "windows\flutter\ephemeral")
)

foreach ($path in $pathsToRemove) {
  if (Test-Path $path) {
    Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
  }
}
Ok "Limpieza completada"

if (Test-Path $adbPath) {
  Info "Reiniciando ADB..."
  & $adbPath kill-server | Out-Null
  & $adbPath start-server | Out-Null
  Ok "ADB reiniciado"
} else {
  Warn "No se encontro adb.exe en $adbPath"
}

Info "Restaurando dependencias Flutter..."
Push-Location $appPath
flutter pub get
Pop-Location
Ok "Dependencias listas"

if ($StartEmulator) {
  if (-not (Test-Path $emulatorPath)) {
    Write-Error "No se encontro emulator.exe en $emulatorPath"
    exit 1
  }

  Info "Iniciando emulador '$AvdName'..."
  Start-Process -FilePath $emulatorPath -ArgumentList @(
    "-avd", $AvdName,
    "-gpu", "swiftshader_indirect",
    "-no-snapshot-load",
    "-no-boot-anim"
  ) | Out-Null

  if (Test-Path $adbPath) {
    Info "Esperando que el emulador aparezca como 'device'..."
    $deadline = (Get-Date).AddSeconds($BootTimeoutSeconds)
    $isReady = $false

    while ((Get-Date) -lt $deadline) {
      Start-Sleep -Seconds 3
      $adbLines = & $adbPath devices
      if ($adbLines -match "emulator-\d+\s+device") {
        $isReady = $true
        break
      }
    }

    if ($isReady) {
      Ok "Emulador listo"
    } else {
      Warn "El emulador no paso a estado 'device' dentro de $BootTimeoutSeconds segundos"
      Warn "Revisa manualmente con: adb devices"
    }
  }
}

if ($RunApp) {
  Info "Ejecutando la app en emulator-5554..."
  Push-Location $appPath
  flutter run -d emulator-5554 --target lib/main.dart
  Pop-Location
} else {
  Write-Host ""
  Ok "Reset completado"
  Write-Host "Siguiente comando sugerido:" -ForegroundColor White
  Write-Host "  cd $appPath" -ForegroundColor Gray
  Write-Host "  flutter run -d emulator-5554" -ForegroundColor Gray
}
