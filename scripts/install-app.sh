#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${1:-}"
APP_PATH="${2:-}"

if [[ -z "$PLATFORM" || -z "$APP_PATH" ]]; then
  echo "Uso: ./scripts/install-app.sh <android|ios> <ruta-app>"
  echo "Ejemplo Android: ./scripts/install-app.sh android apps/android/app-qa.apk"
  echo "Ejemplo iOS: ./scripts/install-app.sh ios apps/ios/MyApp.app"
  exit 1
fi

if [[ ! -e "$APP_PATH" ]]; then
  echo "Error: no existe la ruta indicada: $APP_PATH"
  exit 1
fi

case "$PLATFORM" in
  android)
    if ! command -v adb >/dev/null 2>&1; then
      echo "Error: adb no esta instalado o no esta en PATH."
      exit 1
    fi
    echo "Instalando APK en dispositivo/emulador Android: $APP_PATH"
    adb install -r "$APP_PATH"
    ;;
  ios)
    if ! command -v xcrun >/dev/null 2>&1; then
      echo "Error: xcrun no esta disponible. Instala Xcode."
      exit 1
    fi
    # Requiere un simulador previamente iniciado.
    # Para builds .app:
    echo "Instalando app iOS en el simulador iniciado: $APP_PATH"
    xcrun simctl install booted "$APP_PATH"
    ;;
  *)
    echo "Error: plataforma no soportada: $PLATFORM"
    echo "Valores validos: android, ios"
    exit 1
    ;;
esac
