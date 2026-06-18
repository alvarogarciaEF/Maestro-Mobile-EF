#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./lib.sh
source "$ROOT_DIR/scripts/lib.sh"

SUITE="${1:-}"
FLOW_PATH="${2:-}"

load_env
require_maestro
bash "$ROOT_DIR/scripts/validate-dataset.sh" "${SUITE:-unknown}" "ios"

run_ios_suite() {
  local suite_path="$1"
  local report_path="$2"
  local label="$3"
  APP_ID_ANDROID="${APP_ID_IOS}" run_maestro_suite "$suite_path" "$report_path" "$label"
}

case "$SUITE" in
  smoke)
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY DEEPLINK_HOME
    run_ios_suite "flows/smoke" "reports/smoke-ios.xml" "smoke tests iOS para appId: ${APP_ID_IOS}"
    ;;
  regression)
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME DEEPLINK_CATEGORY DEEPLINK_PRODUCT DEEPLINK_CART DEEPLINK_FAQ RECOVERY_UNKNOWN_EMAIL USER_INVALID_PASSWORD INVALID_COUPON_CODE SEARCH_NO_RESULTS_TERM
    APP_ID_ANDROID="${APP_ID_IOS}" run_maestro_regression_core "reports/regression-core-ios.xml" "regression core iOS (sin checkout) para appId: ${APP_ID_IOS}" "ios"
    ;;
  regression-full)
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME
    APP_ID_ANDROID="${APP_ID_IOS}" run_maestro_suite "flows/regression" "reports/regression-full-ios.xml" "regression completa iOS para appId: ${APP_ID_IOS}"
    ;;
  auth)
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD USER_INVALID_PASSWORD RECOVERY_UNKNOWN_EMAIL
    APP_ID_ANDROID="${APP_ID_IOS}" run_maestro_suite "flows/regression/auth" "reports/auth-ios.xml" "auth regression iOS para appId: ${APP_ID_IOS}"
    ;;
  deeplink)
    require_env_vars APP_ID_IOS DEEPLINK_CATEGORY DEEPLINK_PRODUCT DEEPLINK_CART DEEPLINK_FAQ PRODUCT_SEARCH_TERM PRODUCT_NAME DEFAULT_STATE DEFAULT_CITY
    APP_ID_ANDROID="${APP_ID_IOS}" run_maestro_suite "flows/regression/deeplink" "reports/deeplink-ios.xml" "deeplink regression iOS para appId: ${APP_ID_IOS}"
    ;;
  catalog)
    require_env_vars APP_ID_IOS DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME
    run_ios_suite "flows/regression/catalog" "reports/catalog-ios.xml" "catalog regression iOS para appId: ${APP_ID_IOS}"
    ;;
  cart)
    require_env_vars APP_ID_IOS DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME INVALID_COUPON_CODE
    APP_ID_ANDROID="${APP_ID_IOS}" run_maestro_cart_regression "reports/cart-ios.xml" "cart regression iOS para appId: ${APP_ID_IOS}"
    ;;
  checkout)
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME
    run_ios_suite "flows/regression/checkout" "reports/checkout-ios.xml" "checkout regression iOS para appId: ${APP_ID_IOS}"
    ;;
  account)
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY
    run_ios_suite "flows/regression/account" "reports/account-ios.xml" "account regression iOS para appId: ${APP_ID_IOS}"
    ;;
  flow)
    if [[ -z "$FLOW_PATH" ]]; then
      echo "Uso: ./scripts/run-ios-suite.sh flow <ruta-flow.yaml>"
      exit 1
    fi
    if [[ ! -f "$FLOW_PATH" ]]; then
      echo "Error: no existe el flow indicado: $FLOW_PATH"
      exit 1
    fi
    require_env_vars APP_ID_IOS USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME
    mkdir -p reports
    SAFE_NAME="${FLOW_PATH//\//-}"
    SAFE_NAME="${SAFE_NAME%.yaml}"
    run_ios_suite "$FLOW_PATH" "reports/${SAFE_NAME}-ios.xml" "flow iOS: ${FLOW_PATH}"
    ;;
  *)
    echo "Uso: ./scripts/run-ios-suite.sh <smoke|regression|regression-full|auth|catalog|cart|checkout|account|deeplink|flow> [ruta-flow.yaml]"
    exit 1
    ;;
esac
