#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v adb >/dev/null 2>&1; then
  echo "Error: adb no disponible."
  exit 1
fi

if ! adb devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'; then
  echo "Error: conecta un emulador o dispositivo Android antes de continuar."
  exit 1
fi

echo "Abriendo pantalla para agregar cuenta Google en el emulador..."
echo
echo "Pasos manuales en el dispositivo:"
echo "  1. Settings → Passwords & accounts"
echo "  2. Add account → Google"
echo "  3. Inicia sesion con la cuenta que usaras en GOOGLE_ACCOUNT_EMAIL"
echo

adb shell am start -a android.settings.ADD_ACCOUNT_SETTINGS >/dev/null 2>&1 \
  || adb shell am start -a android.settings.SYNC_SETTINGS >/dev/null 2>&1 \
  || adb shell am start -a android.settings.SETTINGS >/dev/null 2>&1

echo "Pantalla de cuentas abierta. Cuando termines, ejecuta:"
echo "  npm run emulator:google-check"
