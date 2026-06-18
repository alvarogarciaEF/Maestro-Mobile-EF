#!/usr/bin/env bash
set -euo pipefail

SUITE="${1:-unknown}"
PLATFORM="${2:-android}"

warn() {
  echo "[WARN] $1"
}

fail() {
  echo "[ERROR] $1"
  exit 1
}

require_non_placeholder() {
  local var_name="$1"
  local value="${!var_name:-}"

  if [[ -z "$value" ]]; then
    fail "La variable ${var_name} es requerida para ${SUITE}/${PLATFORM}."
  fi

  case "$value" in
    change-me|qa.user@example.com|com.example.*|replace-with-ios)
      fail "La variable ${var_name} tiene un valor placeholder (${value})."
      ;;
  esac
}

require_non_placeholder APP_ID_ANDROID
require_non_placeholder DEFAULT_STATE
require_non_placeholder DEFAULT_CITY

if [[ "$PLATFORM" == "ios" ]]; then
  require_non_placeholder APP_ID_IOS
fi

if [[ "$SUITE" == "smoke" || "$SUITE" == "regression" || "$SUITE" == "checkout" || "$SUITE" == "account" ]]; then
  require_non_placeholder USER_EMAIL
  require_non_placeholder USER_PASSWORD
fi

if [[ "$SUITE" == "regression" || "$SUITE" == "catalog" || "$SUITE" == "cart" || "$SUITE" == "checkout" || "$SUITE" == "location" ]]; then
  require_non_placeholder PRODUCT_SEARCH_TERM
  require_non_placeholder PRODUCT_NAME
fi

if [[ "$SUITE" == "cart" ]]; then
  require_non_placeholder SECOND_PRODUCT_SEARCH_TERM
  require_non_placeholder SECOND_PRODUCT_NAME
fi

if [[ "$SUITE" == "regression" || "$SUITE" == "catalog" ]]; then
  require_non_placeholder CATEGORY_NAME
  require_non_placeholder HOME_CATEGORY_BIRTHDAY
  require_non_placeholder HOME_CATEGORY_FLOWERS
  require_non_placeholder HOME_CATEGORY_GIFTS
fi

if [[ "$SUITE" == "regression" || "$SUITE" == "location" ]]; then
  require_non_placeholder ALTERNATE_STATE
  require_non_placeholder ALTERNATE_CITY
fi

if [[ "$SUITE" == "regression" || "$SUITE" == "account" || "$SUITE" == "checkout" ]]; then
  require_non_placeholder REMINDER_TITLE
fi

if [[ "$SUITE" == "smoke" || "$SUITE" == "regression" || "$SUITE" == "regression-core" ]]; then
  require_non_placeholder DEEPLINK_HOME
fi

if [[ "$SUITE" == "regression" || "$SUITE" == "regression-core" ]]; then
  require_non_placeholder USER_INVALID_PASSWORD
  require_non_placeholder RECOVERY_UNKNOWN_EMAIL
  require_non_placeholder INVALID_COUPON_CODE
  require_non_placeholder SEARCH_NO_RESULTS_TERM
  require_non_placeholder DEEPLINK_CATEGORY
  require_non_placeholder DEEPLINK_PRODUCT
  require_non_placeholder DEEPLINK_CART
  require_non_placeholder DEEPLINK_FAQ
fi

if [[ "$SUITE" == "deeplink" ]]; then
  require_non_placeholder DEEPLINK_CATEGORY
  require_non_placeholder DEEPLINK_PRODUCT
  require_non_placeholder DEEPLINK_CART
  require_non_placeholder DEEPLINK_FAQ
  require_non_placeholder PRODUCT_SEARCH_TERM
  require_non_placeholder PRODUCT_NAME
fi

if [[ "$PLATFORM" == "ios" && -z "${APP_ID_IOS:-}" ]]; then
  fail "APP_ID_IOS es obligatorio para iOS."
fi

if [[ "${PRODUCT_SEARCH_TERM:-}" == "${PRODUCT_NAME:-}" ]]; then
  warn "PRODUCT_SEARCH_TERM y PRODUCT_NAME son iguales; revisa que el dataset sea real."
fi

echo "Dataset validado para ${SUITE}/${PLATFORM}."
