#!/usr/bin/env bash

load_env() {
  local root_dir
  local override
  local env_overrides=()
  local override_vars=(
    APP_ID_ANDROID
    APP_ID_IOS
    USER_EMAIL
    USER_PASSWORD
    USER_INVALID_PASSWORD
    GOOGLE_ACCOUNT_EMAIL
    USER_DISPLAY_NAME
    DEFAULT_STATE
    DEFAULT_CITY
    PRODUCT_SEARCH_TERM
    PRODUCT_NAME
    SECOND_PRODUCT_SEARCH_TERM
    SECOND_PRODUCT_NAME
    SECOND_CATEGORY_NAME
    SEARCH_NO_RESULTS_TERM
    PRODUCT_UNAVAILABLE_SEARCH_TERM
    PRODUCT_UNAVAILABLE_NAME
    INVALID_COUPON_CODE
    VALID_COUPON_CODE
    COUPON_DISCOUNT_PERCENT
    SANDBOX_DECLINE_CARD_NUMBER
    SANDBOX_DECLINE_CARD_EXPIRY
    SANDBOX_DECLINE_CARD_FIRST_NAME
    SANDBOX_DECLINE_CARD_LAST_NAME
    CATEGORY_NAME
    HOME_CATEGORY_BIRTHDAY
    HOME_CATEGORY_FLOWERS
    HOME_CATEGORY_GIFTS
    ALTERNATE_STATE
    ALTERNATE_CITY
    REMINDER_TITLE
    DEEPLINK_HOME
    DEEPLINK_CATEGORY
    DEEPLINK_PRODUCT
    DEEPLINK_CART
    DEEPLINK_FAQ
    DEEPLINK_PERSONALIZED_PRODUCT
    PERSONALIZED_PRODUCT_NAME
    PRICE_FILTER_RANGE
    PRICE_FILTER_RANGE_HIGH
    SORT_ORDER_DESC
    SEARCH_AUTOCOMPLETE_TERM
    CITY_CHANGE_CART_BEHAVIOR
    RECOVERY_UNKNOWN_EMAIL
    BIN_NUMBER
    BIN_CARD_NUMBER
    BIN_CARD_FIRST_NAME
    BIN_CARD_LAST_NAME
    BIN_CARD_EXPIRY
  )
  root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  cd "$root_dir"

  for override in "${override_vars[@]}"; do
    if [[ -n "${!override+x}" ]]; then
      env_overrides+=("${override}=${!override}")
    fi
  done

  if [[ -f ".env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source ".env"
    set +a
  fi

  if ((${#env_overrides[@]} > 0)); then
    for override in "${env_overrides[@]}"; do
      export "$override"
    done
  fi

  USER_DISPLAY_NAME="${USER_DISPLAY_NAME:-Prueba!}"
  GOOGLE_ACCOUNT_EMAIL="${GOOGLE_ACCOUNT_EMAIL:-$USER_EMAIL}"
  USER_INVALID_PASSWORD="${USER_INVALID_PASSWORD:-wrong-password-qa}"
  SEARCH_NO_RESULTS_TERM="${SEARCH_NO_RESULTS_TERM:-zzzqa-sin-resultados-999}"
  PRODUCT_UNAVAILABLE_SEARCH_TERM="${PRODUCT_UNAVAILABLE_SEARCH_TERM:-$PRODUCT_SEARCH_TERM}"
  SECOND_PRODUCT_SEARCH_TERM="${SECOND_PRODUCT_SEARCH_TERM:-globo}"
  SECOND_PRODUCT_NAME="${SECOND_PRODUCT_NAME:-Globo}"
  SECOND_CATEGORY_NAME="${SECOND_CATEGORY_NAME:-Globos}"
  INVALID_COUPON_CODE="${INVALID_COUPON_CODE:-QA-CUPON-INVALIDO}"
  VALID_COUPON_CODE="${VALID_COUPON_CODE:-}"
  COUPON_DISCOUNT_PERCENT="${COUPON_DISCOUNT_PERCENT:-15}"
  SANDBOX_DECLINE_CARD_NUMBER="${SANDBOX_DECLINE_CARD_NUMBER:-4000000000000002}"
  SANDBOX_DECLINE_CARD_EXPIRY="${SANDBOX_DECLINE_CARD_EXPIRY:-1230}"
  SANDBOX_DECLINE_CARD_FIRST_NAME="${SANDBOX_DECLINE_CARD_FIRST_NAME:-QA}"
  SANDBOX_DECLINE_CARD_LAST_NAME="${SANDBOX_DECLINE_CARD_LAST_NAME:-Decline}"
  RECOVERY_UNKNOWN_EMAIL="${RECOVERY_UNKNOWN_EMAIL:-no-existe-qa@enviaflores.com}"
  BIN_NUMBER="${BIN_NUMBER:-55462590}"
  BIN_CARD_NUMBER="${BIN_CARD_NUMBER:-$(printf '%-16s' "$BIN_NUMBER" | tr ' ' '0')}"
  BIN_CARD_FIRST_NAME="${BIN_CARD_FIRST_NAME:-Alvaro}"
  BIN_CARD_LAST_NAME="${BIN_CARD_LAST_NAME:-Garcia}"
  BIN_CARD_EXPIRY="${BIN_CARD_EXPIRY:-1230}"
  HOME_CATEGORY_BIRTHDAY="${HOME_CATEGORY_BIRTHDAY:-${CATEGORY_NAME:-Cumpleaños}}"
  HOME_CATEGORY_FLOWERS="${HOME_CATEGORY_FLOWERS:-Flores y plantas}"
  HOME_CATEGORY_GIFTS="${HOME_CATEGORY_GIFTS:-Regalos}"
  ALTERNATE_STATE="${ALTERNATE_STATE:-Nuevo León}"
  ALTERNATE_CITY="${ALTERNATE_CITY:-San Pedro Garza Garcia}"
  REMINDER_TITLE="${REMINDER_TITLE:-QA Recordatorio Maestro}"
  DEEPLINK_PERSONALIZED_PRODUCT="${DEEPLINK_PERSONALIZED_PRODUCT:-https://www.enviaflores.com/florerias-nuevo-leon/monterrey/26009}"
  PERSONALIZED_PRODUCT_NAME="${PERSONALIZED_PRODUCT_NAME:-}"
  PRICE_FILTER_RANGE="${PRICE_FILTER_RANGE:-Menor \$399}"
  PRICE_FILTER_RANGE_HIGH="${PRICE_FILTER_RANGE_HIGH:-Mayor \$990}"
  SORT_ORDER_DESC="${SORT_ORDER_DESC:-Mayor a menor \$}"
  SEARCH_AUTOCOMPLETE_TERM="${SEARCH_AUTOCOMPLETE_TERM:-globo}"
  CITY_CHANGE_CART_BEHAVIOR="${CITY_CHANGE_CART_BEHAVIOR:-either}"
}

require_maestro() {
  if ! command -v maestro >/dev/null 2>&1; then
    echo "Error: Maestro CLI no esta instalado o no esta en PATH."
    echo "Instala con: curl -Ls \"https://get.maestro.mobile.dev\" | bash"
    exit 1
  fi
}

disable_emulator_stylus() {
  local root_dir
  root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [[ -x "$root_dir/scripts/disable-emulator-stylus.sh" ]]; then
    bash "$root_dir/scripts/disable-emulator-stylus.sh" || true
  fi
}

require_env_vars() {
  local var_name
  for var_name in "$@"; do
    if [[ -z "${!var_name:-}" ]]; then
      echo "Error: falta la variable de ambiente ${var_name}."
      echo "Configura .env tomando .env.example como base."
      exit 1
    fi
  done
}

maestro_env_args() {
  local var_name
  local supported_vars=(
    APP_ID_ANDROID
    APP_ID_IOS
    USER_EMAIL
    USER_PASSWORD
    USER_INVALID_PASSWORD
    GOOGLE_ACCOUNT_EMAIL
    USER_DISPLAY_NAME
    DEFAULT_STATE
    DEFAULT_CITY
    PRODUCT_SEARCH_TERM
    PRODUCT_NAME
    SECOND_PRODUCT_SEARCH_TERM
    SECOND_PRODUCT_NAME
    SECOND_CATEGORY_NAME
    SEARCH_NO_RESULTS_TERM
    PRODUCT_UNAVAILABLE_SEARCH_TERM
    PRODUCT_UNAVAILABLE_NAME
    INVALID_COUPON_CODE
    VALID_COUPON_CODE
    COUPON_DISCOUNT_PERCENT
    SANDBOX_DECLINE_CARD_NUMBER
    SANDBOX_DECLINE_CARD_EXPIRY
    SANDBOX_DECLINE_CARD_FIRST_NAME
    SANDBOX_DECLINE_CARD_LAST_NAME
    CATEGORY_NAME
    HOME_CATEGORY_BIRTHDAY
    HOME_CATEGORY_FLOWERS
    HOME_CATEGORY_GIFTS
    ALTERNATE_STATE
    ALTERNATE_CITY
    REMINDER_TITLE
    DEEPLINK_HOME
    DEEPLINK_CATEGORY
    DEEPLINK_PRODUCT
    DEEPLINK_CART
    DEEPLINK_FAQ
    DEEPLINK_PERSONALIZED_PRODUCT
    PERSONALIZED_PRODUCT_NAME
    PRICE_FILTER_RANGE
    PRICE_FILTER_RANGE_HIGH
    SORT_ORDER_DESC
    SEARCH_AUTOCOMPLETE_TERM
    CITY_CHANGE_CART_BEHAVIOR
    RECOVERY_UNKNOWN_EMAIL
    BIN_NUMBER
    BIN_CARD_NUMBER
    BIN_CARD_FIRST_NAME
    BIN_CARD_LAST_NAME
    BIN_CARD_EXPIRY
    BIN_INSTITUTION_ID
    BIN_INSTITUTION
    BIN_MSI_ALLOWED
    BIN_MSI_POLICY
    BIN_CARD_BRAND
    BIN_PAYMENT_POLICY
    BIN_PAYMENT_ACTION
  )

  for var_name in "${supported_vars[@]}"; do
    if [[ -n "${!var_name:-}" ]]; then
      printf '%s\0%s\0' "-e" "${var_name}=${!var_name}"
    fi
  done
}

run_maestro_suite() {
  local suite_path="$1"
  local report_path="$2"
  local label="$3"
  shift 3
  local maestro_args=()
  local maestro_cmd=()
  local output_args=()
  local flow_paths=("$@")

  mkdir -p reports
  disable_emulator_stylus
  echo "Ejecutando ${label}"
  while IFS= read -r -d '' arg; do
    maestro_args+=("$arg")
  done < <(maestro_env_args)

  if [[ -n "${MAESTRO_TEST_OUTPUT_DIR:-}" ]]; then
    mkdir -p "$MAESTRO_TEST_OUTPUT_DIR"
    output_args+=(--test-output-dir "$MAESTRO_TEST_OUTPUT_DIR")
  fi

  maestro_cmd=(maestro test)
  if [[ "${#output_args[@]}" -gt 0 ]]; then
    maestro_cmd+=("${output_args[@]}")
  fi
  if ((${#flow_paths[@]} > 0)); then
    maestro_cmd+=("${maestro_args[@]}" "${flow_paths[@]}" --format junit --output "$report_path")
  else
    maestro_cmd+=("${maestro_args[@]}" "$suite_path" --format junit --output "$report_path")
  fi
  "${maestro_cmd[@]}"
}

cart_regression_paths() {
  local paths=(
    flows/regression/cart/add-product-to-cart.yaml
    flows/regression/cart/apply-coupon.yaml
    flows/regression/cart/cart-from-search.yaml
    flows/regression/cart/delivery-date-change.yaml
    flows/regression/cart/multi-product.yaml
    flows/regression/cart/remove-product.yaml
    flows/regression/cart/update-quantity.yaml
    flows/regression/cart/apply-coupon-valid.yaml
  )

  printf '%s\n' "${paths[@]}"
}

run_maestro_cart_regression() {
  local report_path="$1"
  local label="$2"
  local cart_paths=()

  while IFS= read -r path; do
    cart_paths+=("$path")
  done < <(cart_regression_paths)

  run_maestro_suite "" "$report_path" "$label" "${cart_paths[@]}"
}

regression_core_paths() {
  printf '%s\n' \
    "flows/regression/auth" \
    "flows/regression/catalog"
  cart_regression_paths
  printf '%s\n' \
    "flows/regression/location" \
    "flows/regression/account" \
    "flows/regression/deeplink"
}

run_maestro_regression_core() {
  local report_path="$1"
  local label="$2"
  local platform_label="$3"
  local maestro_args=()
  local maestro_cmd=()
  local output_args=()
  local core_paths=()

  mkdir -p reports
  disable_emulator_stylus
  echo "Ejecutando ${label}"
  while IFS= read -r -d '' arg; do
    maestro_args+=("$arg")
  done < <(maestro_env_args)

  if [[ -n "${MAESTRO_TEST_OUTPUT_DIR:-}" ]]; then
    mkdir -p "$MAESTRO_TEST_OUTPUT_DIR"
    output_args+=(--test-output-dir "$MAESTRO_TEST_OUTPUT_DIR")
  fi

  while IFS= read -r path; do
    core_paths+=("$path")
  done < <(regression_core_paths)

  maestro_cmd=(maestro test)
  if [[ "${#output_args[@]}" -gt 0 ]]; then
    maestro_cmd+=("${output_args[@]}")
  fi
  maestro_cmd+=("${maestro_args[@]}" "${core_paths[@]}" --format junit --output "$report_path")
  "${maestro_cmd[@]}"
}
