#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Ejecutando smoke Android..."
"$ROOT_DIR/scripts/run-smoke-android.sh"

echo
echo "Ejecutando smoke iOS..."
"$ROOT_DIR/scripts/run-smoke-ios.sh"

echo
echo "Smoke cross-platform completado. Revisa reports/smoke-android.xml y reports/smoke-ios.xml"
