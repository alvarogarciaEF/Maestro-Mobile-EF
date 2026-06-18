#!/usr/bin/env bash
set -euo pipefail

warn() {
  echo "[WARN] $1"
}

ok() {
  echo "[OK] $1"
}

if ! command -v adb >/dev/null 2>&1; then
  warn "adb no disponible; no se pudo desactivar stylus."
  exit 0
fi

if ! adb devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'; then
  warn "No hay dispositivo Android conectado; omitiendo desactivar stylus."
  exit 0
fi

echo "Desactivando stylus / handwriting en el emulador..."

adb shell settings put secure stylus_handwriting_enabled 0 >/dev/null 2>&1 || true
adb shell am force-stop com.google.android.inputmethod.latin >/dev/null 2>&1 || true
adb shell am force-stop com.android.chrome >/dev/null 2>&1 || true
adb shell am force-stop com.facebook.katana >/dev/null 2>&1 || true

APP_ID="${APP_ID_ANDROID:-com.enviaflores.android}"
echo "Configurando app links para ${APP_ID}..."
adb shell pm set-app-links --package "${APP_ID}" 2 www.enviaflores.com enviaflores.com >/dev/null 2>&1 || true

# Cierra overlays comunes de Gboard stylus si quedaron abiertos.
adb shell input keyevent KEYCODE_BACK >/dev/null 2>&1 || true
sleep 0.5
adb shell input keyevent KEYCODE_BACK >/dev/null 2>&1 || true

current="$(adb shell settings get secure stylus_handwriting_enabled 2>/dev/null | tr -d '\r' || true)"
if [[ "$current" == "0" ]]; then
  ok "stylus_handwriting_enabled=0"
else
  warn "No se pudo confirmar stylus_handwriting_enabled=0 (valor: ${current:-desconocido})."
fi

echo
echo "Si el emulador sigue en modo stylus, en la ventana del AVD:"
echo "  Extended controls (...) → desactiva Stylus / Pen input si esta activo."
echo "  Evita hacer clic en el icono de lapiz en la barra lateral del emulador."
