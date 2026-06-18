#!/usr/bin/env bash
# Carga .env antes de Maestro Studio (Studio no lee .env solo ni resuelve ${VAR} circular en config.yaml).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ".env"
  set +a
  echo "Variables cargadas en shell (APP_ID_ANDROID=${APP_ID_ANDROID:-sin definir})"
  echo ""
  echo "IMPORTANTE: Maestro Studio NO lee .env ni config.yaml."
  echo "En Studio: icono Env → Manage Environments → crea 'QA Android'"
  echo "y pega variables con: npm run maestro:studio:env"
  echo "Ver docs/maestro-studio-env.md"
else
  echo "Aviso: no hay .env en la raiz del proyecto. Copia .env.example a .env"
fi

exec maestro studio "$@"
