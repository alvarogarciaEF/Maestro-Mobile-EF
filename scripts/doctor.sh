#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./lib.sh
source "$ROOT_DIR/scripts/lib.sh"

load_env

echo "QA Mobile EnviaFlores - doctor"
echo

require_maestro
echo "[OK] Maestro CLI disponible: $(maestro --version)"

if command -v node >/dev/null 2>&1; then
  echo "[OK] Node.js disponible: $(node --version)"
else
  echo "[WARN] Node.js no disponible"
fi

if command -v adb >/dev/null 2>&1; then
  echo "[OK] adb disponible"
  adb devices || true
else
  echo "[WARN] adb no disponible (requerido para Android local)"
fi

if command -v xcrun >/dev/null 2>&1; then
  echo "[OK] xcrun disponible (iOS/macOS)"
else
  echo "[WARN] xcrun no disponible (requerido para iOS local en macOS)"
fi

if [[ -f "$ROOT_DIR/.env" ]]; then
  echo "[OK] .env encontrado"
else
  echo "[WARN] .env no encontrado; copia .env.example"
fi

if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" ]]; then
  echo "[WARN] ANDROID_HOME/ANDROID_SDK_ROOT no configurado (requerido para Maestro Android local)"
else
  echo "[OK] Android SDK configurado"
fi

if command -v java >/dev/null 2>&1; then
  echo "[OK] Java disponible: $(java -version 2>&1 | head -1)"
else
  echo "[WARN] Java no disponible (Maestro requiere Java 17+)"
fi

echo
echo "Preflight listo. Ejecuta npm run validate para validacion estatica."
echo "Para smoke login con Google: docs/emulator-google-setup.md"
echo "  npm run emulator:google-setup   # abre pantalla de cuentas"
echo "  npm run emulator:google-check   # verifica cuenta en el AVD"
echo "  npm run emulator:disable-stylus # desactiva Gboard stylus/handwriting"
echo "Para ejecutar en Android local exporta ANDROID_HOME y usa Maestro >= 2.6.0."
