#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./lib.sh
source "$ROOT_DIR/scripts/lib.sh"

DATASET="$ROOT_DIR/data/bines.yaml"
FLOW_PATH="flows/special/validacion-bines.yaml"
LIMIT="${BIN_LIMIT:-}"
VALIDATE_MSI="${BIN_VALIDATE_MSI:-0}"
CLEAR_STATE="${BIN_CLEAR_STATE:-0}"
DRY_RUN=0

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

load_env
require_maestro
require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME

export MAESTRO_TEST_OUTPUT_DIR="${MAESTRO_TEST_OUTPUT_DIR:-reports/maestro-artifacts/bines}"

build_card_number() {
  local prefix="$1"

  ruby -e '
    prefix = ARGV[0]
    abort "BIN invalido: #{prefix}" unless prefix.match?(/\A\d{1,16}\z/)
    puts prefix.ljust(16, "0")
  ' "$prefix"
}

if [[ ! -f "$DATASET" ]]; then
  echo "Error: no existe el dataset de BINes: $DATASET"
  exit 1
fi

BIN_ROWS=()
while IFS= read -r row; do
  BIN_ROWS+=("$row")
done < <(ruby -ryaml -e '
  rows = YAML.load_file(ARGV[0]).fetch("bines")
  limit = ARGV[1].to_s
  rows = rows.first(limit.to_i) unless limit.empty?
  rows.each do |row|
    puts [
      row.fetch("bin"),
      row.fetch("institution_id"),
      row.fetch("institution"),
      row.fetch("msi_allowed"),
      row.fetch("msi_policy"),
      row.fetch("card_brand"),
      row.fetch("payment_policy"),
      row.fetch("payment_action")
    ].join("\t")
  end
' "$DATASET" "$LIMIT")

if [[ "${#BIN_ROWS[@]}" -eq 0 ]]; then
  echo "Error: no hay BINes para ejecutar."
  exit 1
fi

STATUS=0
echo "Ejecutando validacion de BINes Android (${#BIN_ROWS[@]} casos)"

if [[ "$CLEAR_STATE" == "1" && "$DRY_RUN" -eq 0 ]]; then
  if ! run_maestro_suite "flows/utils/clear-state.yaml" "reports/bines-clear-state-android.xml" "limpieza inicial Android para validacion de BINes"; then
    exit 1
  fi
fi

for row in "${BIN_ROWS[@]}"; do
  IFS=$'\t' read -r BIN_NUMBER BIN_INSTITUTION_ID BIN_INSTITUTION BIN_MSI_ALLOWED BIN_MSI_POLICY BIN_CARD_BRAND BIN_PAYMENT_POLICY BIN_PAYMENT_ACTION <<< "$row"
  BIN_CARD_NUMBER="$(build_card_number "$BIN_NUMBER")"
  export BIN_NUMBER BIN_CARD_NUMBER BIN_INSTITUTION_ID BIN_INSTITUTION BIN_MSI_ALLOWED BIN_MSI_POLICY BIN_CARD_BRAND BIN_PAYMENT_POLICY BIN_PAYMENT_ACTION

  safe_institution="$(printf '%s' "$BIN_INSTITUTION" | tr '[:upper:] ' '[:lower:]-' | tr -cd '[:alnum:]-')"
  report_path="reports/bines-${BIN_NUMBER}-${safe_institution}-android.xml"
  flow_path="$FLOW_PATH"

  if [[ "$VALIDATE_MSI" == "1" ]]; then
    if [[ "$BIN_MSI_ALLOWED" == "true" ]]; then
      flow_path="flows/special/validacion-bines-msi-visible.yaml"
    else
      flow_path="flows/special/validacion-bines-msi-hidden.yaml"
    fi
  else
    case "$BIN_PAYMENT_ACTION" in
      bin_only)
        flow_path="flows/special/validacion-bines.yaml"
        ;;
      validate_options)
        if [[ "$BIN_MSI_ALLOWED" == "true" ]]; then
          flow_path="flows/special/validacion-bines-payment-options-msi-visible.yaml"
        else
          flow_path="flows/special/validacion-bines-payment-options-msi-hidden.yaml"
        fi
        ;;
      attempt_payment)
        if [[ "$BIN_MSI_ALLOWED" == "true" ]]; then
          flow_path="flows/special/validacion-bines-payment-attempt-msi-visible.yaml"
        else
          flow_path="flows/special/validacion-bines-payment-attempt-msi-hidden.yaml"
        fi
        ;;
      *)
        echo "Error: payment_action no reconocido para BIN ${BIN_NUMBER}: ${BIN_PAYMENT_ACTION}"
        STATUS=1
        continue
        ;;
    esac
  fi

  echo
  echo "BIN ${BIN_NUMBER} - ${BIN_INSTITUTION} - ${BIN_CARD_BRAND} - ${BIN_MSI_POLICY} - ${BIN_PAYMENT_POLICY} - card ${BIN_CARD_NUMBER}"
  echo "Accion: ${BIN_PAYMENT_ACTION} - Flow: ${flow_path}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    continue
  fi

  if ! run_maestro_suite "$flow_path" "$report_path" "validacion BIN ${BIN_NUMBER} (${BIN_INSTITUTION})"; then
    STATUS=1
  fi
done

exit "$STATUS"
