#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./lib.sh
source "$ROOT_DIR/scripts/lib.sh"

load_env

warn() {
  echo "[WARN] $1"
}

ok() {
  echo "[OK] $1"
}

fail() {
  echo "[ERROR] $1"
  exit 1
}

if ! command -v adb >/dev/null 2>&1; then
  fail "adb no disponible."
fi

if ! adb devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'; then
  fail "No hay emulador/dispositivo Android conectado (adb devices)."
fi

echo "Verificando cuenta Google en el dispositivo..."
echo

account_dump="$(adb shell dumpsys account 2>/dev/null || true)"
google_accounts="$(echo "$account_dump" | grep -E 'Account \{name=.*type=com\.google' || true)"
account_names="$(echo "$google_accounts" | grep -oE 'name=[^,]+' | sed 's/name=//' || true)"

if [[ -z "$google_accounts" ]]; then
  accounts_line="$(echo "$account_dump" | grep -E '^\s*Accounts:' | head -1 || true)"
  warn "No se detectaron cuentas Google en el dispositivo.${accounts_line:+ ($accounts_line)}"
  echo "      Ejecuta: npm run emulator:google-setup"
  echo "      Luego agrega la cuenta en Settings → Passwords & accounts → Google"
  exit 1
fi

ok "Cuenta(s) Google detectada(s) en el dispositivo."

if [[ -n "${GOOGLE_ACCOUNT_EMAIL:-}" ]]; then
  if echo "$account_names" | grep -qiF "${GOOGLE_ACCOUNT_EMAIL}"; then
    ok "GOOGLE_ACCOUNT_EMAIL (${GOOGLE_ACCOUNT_EMAIL}) coincide con una cuenta del dispositivo."
  else
    warn "GOOGLE_ACCOUNT_EMAIL=${GOOGLE_ACCOUNT_EMAIL} no aparece en el dispositivo."
    echo "      Cuentas visibles:"
    echo "$account_names" | sed 's/^/        /'
    echo "      Ajusta .env o agrega la cuenta correcta al emulador."
    exit 1
  fi
else
  warn "GOOGLE_ACCOUNT_EMAIL no esta definido en .env"
fi

if [[ "${GOOGLE_ACCOUNT_EMAIL:-}" == *mailinator.com* ]]; then
  warn "GOOGLE_ACCOUNT_EMAIL apunta a Mailinator; no es una cuenta Google valida para el picker de Android."
  echo "      Usa un Gmail/Workspace en GOOGLE_ACCOUNT_EMAIL y deja Mailinator solo en USER_EMAIL."
  exit 1
fi

echo
ok "Listo para flujos con Google (smoke login, ensure-logged-in)."
