#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./lib.sh
source "$ROOT_DIR/scripts/lib.sh"

SUITE="${1:-}"
FLOW_PATH="${2:-}"

load_env
require_maestro
bash "$ROOT_DIR/scripts/validate-dataset.sh" "${SUITE:-unknown}" "android"

case "$SUITE" in
  smoke)
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY DEEPLINK_HOME
    run_maestro_suite "flows/smoke" "reports/smoke-android.xml" "smoke tests Android para appId: ${APP_ID_ANDROID}"
    ;;
  regression)
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME DEEPLINK_CATEGORY DEEPLINK_PRODUCT DEEPLINK_CART DEEPLINK_FAQ RECOVERY_UNKNOWN_EMAIL USER_INVALID_PASSWORD INVALID_COUPON_CODE SEARCH_NO_RESULTS_TERM
    run_maestro_regression_core "reports/regression-core-android.xml" "regression core Android (sin checkout) para appId: ${APP_ID_ANDROID}" "android"
    ;;
  regression-full)
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME
    run_maestro_suite "flows/regression" "reports/regression-full-android.xml" "regression completa Android (incluye checkout) para appId: ${APP_ID_ANDROID}"
    ;;
  auth)
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD USER_INVALID_PASSWORD RECOVERY_UNKNOWN_EMAIL
    run_maestro_suite "flows/regression/auth" "reports/auth-android.xml" "auth regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  catalog)
    require_env_vars APP_ID_ANDROID DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME HOME_CATEGORY_BIRTHDAY HOME_CATEGORY_FLOWERS HOME_CATEGORY_GIFTS
    run_maestro_suite "flows/regression/catalog" "reports/catalog-android.xml" "catalog regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  cart)
    require_env_vars APP_ID_ANDROID DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME SECOND_PRODUCT_SEARCH_TERM SECOND_PRODUCT_NAME INVALID_COUPON_CODE
    run_maestro_cart_regression "reports/cart-android.xml" "cart regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  location)
    require_env_vars APP_ID_ANDROID DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME ALTERNATE_STATE ALTERNATE_CITY
    run_maestro_suite "flows/regression/location" "reports/location-android.xml" "location regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  checkout)
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME SANDBOX_DECLINE_CARD_NUMBER SANDBOX_DECLINE_CARD_EXPIRY REMINDER_TITLE
    run_maestro_suite "flows/regression/checkout" "reports/checkout-android.xml" "checkout regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  account)
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY REMINDER_TITLE
    run_maestro_suite "flows/regression/account" "reports/account-android.xml" "account regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  deeplink)
    require_env_vars APP_ID_ANDROID DEEPLINK_CATEGORY DEEPLINK_PRODUCT DEEPLINK_CART DEEPLINK_FAQ PRODUCT_SEARCH_TERM PRODUCT_NAME DEFAULT_STATE DEFAULT_CITY
    run_maestro_suite "flows/regression/deeplink" "reports/deeplink-android.xml" "deeplink regression Android para appId: ${APP_ID_ANDROID}"
    ;;
  tags)
    INCLUDE_TAGS="${2:-}"
    EXCLUDE_TAGS="${3:-}"
    if [[ -z "$INCLUDE_TAGS" && -z "$EXCLUDE_TAGS" ]]; then
      echo "Uso: ./scripts/run-android-suite.sh tags \"<include>\" [\"<exclude>\"]"
      echo "Ejemplo: ./scripts/run-android-suite.sh tags web-parity"
      echo "Ejemplo: ./scripts/run-android-suite.sh tags regression checkout,payment,payments,oxxo"
      exit 1
    fi
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME
    SAFE_TAGS="${INCLUDE_TAGS//,/-}"
    SAFE_TAGS="${SAFE_TAGS:-all}"
    run_maestro_tags "$INCLUDE_TAGS" "$EXCLUDE_TAGS" "reports/tags-${SAFE_TAGS}-android.xml" "tags Android (include: ${INCLUDE_TAGS:-*}, exclude: ${EXCLUDE_TAGS:-none}) para appId: ${APP_ID_ANDROID}"
    ;;
  flow)
    if [[ -z "$FLOW_PATH" ]]; then
      echo "Uso: ./scripts/run-android-suite.sh flow <ruta-flow.yaml>"
      exit 1
    fi
    if [[ ! -f "$FLOW_PATH" ]]; then
      echo "Error: no existe el flow indicado: $FLOW_PATH"
      exit 1
    fi
    require_env_vars APP_ID_ANDROID USER_EMAIL USER_PASSWORD DEFAULT_STATE DEFAULT_CITY PRODUCT_SEARCH_TERM PRODUCT_NAME CATEGORY_NAME DEEPLINK_HOME
    mkdir -p reports
    SAFE_NAME="${FLOW_PATH//\//-}"
    SAFE_NAME="${SAFE_NAME%.yaml}"
    run_maestro_suite "$FLOW_PATH" "reports/${SAFE_NAME}-android.xml" "flow Android: ${FLOW_PATH}"
    ;;
  *)
    echo "Uso: ./scripts/run-android-suite.sh <smoke|regression|regression-full|auth|catalog|cart|checkout|account|deeplink|location|flow|tags> [args]"
    echo "  tags <include> [exclude]: corre flows por tags (transversal). Ej: tags web-parity"
    exit 1
    ;;
esac
