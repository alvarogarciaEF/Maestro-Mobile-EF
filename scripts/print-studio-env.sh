#!/usr/bin/env bash
# Imprime variables de .env para copiar al panel Env de Maestro Studio.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f ".env" ]]; then
  echo "No hay .env. Copia desde: cp .env.example .env" >&2
  exit 1
fi

echo "# Pegar en Maestro Studio → Env → Manage Environments → variables"
echo ""

grep -v '^[[:space:]]*#' .env | grep -v '^[[:space:]]*$' | while IFS= read -r line; do
  key="${line%%=*}"
  value="${line#*=}"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s=%s\n' "$key" "$value"
done
