# Web ↔ Mobile Parity

Matriz de alineación entre el framework web (`enviaflores/ef-qa-automation`, Playwright) y este repo (`qa-mobile-maestro`, Maestro).

**Repo web local:** `/Users/alvarogarcia/Documents/Framework/QA---EnviaFlores`  
**Última revisión:** 2026-05-19

## Resumen ejecutivo

| Métrica | Web | Mobile |
| --- | ---: | ---: |
| Specs / flows UI | 124 | 72 (66 regression + 6 smoke) |
| Specs API | 28 | N/A |
| Utilities | 2 | N/A |
| **Aplicables a app nativa** (excl. API, site, webviews, multitab) | ~75 | 72 flows |
| **Paridad estimada** | — | ~**58%** del inventario web total · ~**96%** de lo aplicable a mobile |

Estados usados en las tablas:

| Estado | Significado |
| --- | --- |
| **Cubierto** | Flow mobile implementado y mapeado al spec web |
| **Parcial** | Existe cobertura mobile con alcance, datos o estabilidad menor |
| **Pendiente** | Spec web aplicable a mobile sin equivalente aún |
| **N/A** | No aplica en app nativa (web-only, API, patrón distinto) |

---

## Suites y comandos equivalentes

| Web (`ef-qa-automation`) | Mobile (`qa-mobile-maestro`) |
| --- | --- |
| `npm run test:smoke` | `npm run maestro:smoke:android` |
| `npm run test:regression` | `npm run maestro:regression:android` (core, sin checkout) |
| `npm run test:regression:auth` | `npm run maestro:auth:android` |
| `npm run test:regression:catalog` | `npm run maestro:catalog:android` |
| `npm run test:regression:location` | `npm run maestro:location:android` |
| `npm run test:api` | N/A |
| — | `npm run maestro:cart:android` |
| — | `npm run maestro:checkout:android` |
| — | `npm run maestro:account:android` |
| — | `npm run maestro:deeplink:android` |
| — | `npm run maestro:regression:full:android` (incluye checkout) |

**Regression core mobile** (`scripts/lib.sh`): auth, catalog, cart, location, account, deeplink — **excluye checkout** por tiempo/flakiness en emulador.

---

## Smoke — `tests/smoke/*`

### Auth (`tests/smoke/auth/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `login.spec.js` | `flows/smoke/login.yaml`, `flows/reusable/login-email-password.yaml` | Parcial | Mobile: email/password + Google opcional; web incluye flujo UI completo |
| `login-invalid-credentials.spec.js` | `flows/regression/auth/login-invalid.yaml` | Cubierto | |
| `logout.spec.js` | `flows/regression/auth/logout.yaml` | Cubierto | Fase 1 P0 |
| `register.spec.js` | `flows/regression/auth/register-validation.yaml` | Parcial | Fase 5; email duplicado |
| `forgot-password.spec.js` | `flows/regression/auth/recover-password.yaml` | Cubierto | |
| — | `flows/regression/auth/login-empty-fields.yaml` | Mobile+ | Validación campos vacíos |
| — | `flows/regression/auth/recover-password-email-not-found.yaml` | Mobile+ | Email inexistente |

### Catalog (`tests/smoke/catalog/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `search.spec.js` | `flows/regression/catalog/search-product.yaml` | Cubierto | |
| `search-no-results.spec.js` | `flows/regression/catalog/search-no-results.yaml` | Cubierto | |
| `search-direct-routes.spec.js` | `flows/regression/deeplink/deeplink-category.yaml` | Parcial | Mobile: deeplink HTTPS, no ruta directa browser |
| `product-details.spec.js` | `flows/regression/catalog/product-detail.yaml` | Cubierto | |
| `megamenu.spec.js` | `flows/regression/catalog/megamenu-navigation.yaml` | Cubierto | Fase 1 P1; mobile usa pestaña Categorías |
| `catalog-filters.spec.js` | `flows/regression/catalog/filter-category.yaml` | Cubierto | |
| `home-search-results.spec.js` | `flows/regression/cart/cart-from-search.yaml` | Parcial | Mobile valida búsqueda → carrito, no solo resultados |
| `not-found.spec.js` | `flows/regression/catalog/product-unavailable.yaml` | Parcial | Mobile: producto no disponible, no 404 genérico |

### Shopping cart (`tests/smoke/shopping-cart/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `main-cart.spec.js` | `flows/regression/cart/add-product-to-cart.yaml` | Cubierto | |
| `main-cart-delivery-date.spec.js` | `flows/regression/cart/delivery-date-change.yaml` | Cubierto | Fase 1 P0 |
| `multi-product-cart.spec.js` | `flows/regression/cart/multi-product.yaml` | Cubierto | Fase 1 P0 |
| `cart-quantity.spec.js` | `flows/regression/cart/update-quantity.yaml` | Cubierto | |
| `secondary-cart.spec.js` | — | N/A | Web: overlay lateral; mobile va directo a PDP/carrito |
| `secondary-cart-quantity.spec.js` | — | N/A | |
| `secondary-cart-removal.spec.js` | `flows/regression/cart/remove-product.yaml` | Parcial | Remoción en carrito principal, no secondary |
| `cart-session-persistence.spec.js` | `flows/regression/cart/cart-session-persistence.yaml` | Parcial | Fase 5; relaunch + re-login |

### Checkout (`tests/smoke/checkout/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `checkout.spec.js` | `flows/regression/checkout/checkout-basic.yaml` | Parcial | Suite checkout, fuera de regression core |
| `checkout-status.spec.js` | — | Pendiente | Requiere `CHECKOUT_STATUS_ORDER_ID` / pedido previo |
| `dedicatoria.spec.js` | `flows/regression/checkout/dedicatoria.yaml` | Parcial | Fase 1 P1; sin edit/delete dedicatoria |

### Location (`tests/smoke/location/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `shipping-selector.spec.js` | `flows/smoke/select-city.yaml`, reusables `select-city.yaml` | Cubierto | |
| `shipping-guards-and-persistence.spec.js` (guard) | `flows/regression/location/shipping-guards.yaml` | Cubierto | Fase 1 P0 |
| `shipping-guards-and-persistence.spec.js` (happy path) | `flows/regression/location/shipping-flow-home-to-pdp.yaml` | Cubierto | Fase 1 P0 |
| `city-change.spec.js` | `flows/regression/location/city-change-catalog.yaml` | Cubierto | Fase 1 P1 |
| `currency-language.spec.js` | — | Pendiente | Selector moneda/idioma web |

### Home (`tests/smoke/home/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `home-navigation.spec.js` | `flows/regression/catalog/home-navigation.yaml` | Cubierto | Fase 1 P1; vía Categorías (carrusel Home inestable) |
| `home-banner.spec.js` | — | Pendiente | Banners compose en Home |
| `home-banner-differentiators.spec.js` | — | Pendiente | |
| `home-differentiators.spec.js` | — | Pendiente | |
| `notifications-modal-dismiss.spec.js` | `flows/reusable/close-modals.yaml` | Parcial | Cierre genérico de modales, no CTA específico → checkout |

### Clients / Account (`tests/smoke/clients/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `account-hub.spec.js` | `flows/regression/account/order-history.yaml` | Parcial | Mobile: pantalla Mi cuenta parcial |
| `clients-auth-guard.spec.js` | `flows/reusable/open-login-dialog.yaml` | Parcial | Guardas de login en acciones protegidas |
| `clients-authenticated-profile.spec.js` | `flows/regression/account/edit-profile.yaml` | Cubierto | |
| `clients-authenticated-orders-engagement.spec.js` | `flows/regression/account/order-history-detail.yaml` | Parcial | Depende de historial previo |

### Orders (`tests/smoke/orders/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `orders-auth-guard.spec.js` | `flows/regression/account/order-history.yaml` | Parcial | Acceso Mis pedidos autenticado |

### Site (`tests/smoke/site/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `faq-navigation.spec.js` | `flows/regression/deeplink/deeplink-faq.yaml` | Parcial | Mobile: centro ayuda nativo vía deeplink |
| `billing-faq.spec.js` | — | N/A | Contenido web |
| `footer.spec.js` | — | N/A | |
| `legal-information-pages.spec.js` | — | N/A | |
| `marketing-static-routes.spec.js` | — | N/A | |
| `seo-accessibility.spec.js` | — | N/A | |
| `analytics-clevertap.spec.js` | — | N/A | |
| `tokenized-routes-guest.spec.js` | — | N/A | Rutas tokenizadas web |
| `tokenized-routes-happy-path.spec.js` | — | N/A | |
| `webview-routes.spec.js` | — | N/A | Webviews embebidos |

---

## Regression — `tests/regression/*`

### Auth (`tests/regression/auth/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `guest-to-auth-cart-state.spec.js` | `flows/regression/auth/guest-cart-merge.yaml` | Parcial | Fase 3; documenta preservación o reset coherente |
| `logout-and-relogin.spec.js` | `flows/regression/auth/logout-and-relogin.yaml` | Cubierto | Fase 5 |
| `register-validation.spec.js` | `flows/regression/auth/register-validation.yaml` | Parcial | Fase 5; email duplicado |
| `session-persistence-across-navigation.spec.js` | `flows/regression/auth/session-persistence-navigation.yaml` | Parcial | Fase 4; Home ↔ cuenta (sin paso búsqueda) |
| `social-login-session.spec.js` | `flows/reusable/login-valid-user.yaml` | Parcial | Google en emulador; sin Facebook/Apple |

### Catalog (`tests/regression/catalog/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `megamenu-main-categories-navigation.spec.js` | `flows/regression/catalog/megamenu-navigation.yaml` | Parcial | Smoke cubre happy path; regression web más profundo |
| `catalog-pdp-back-navigation.spec.js` | `flows/regression/catalog/pdp-back-navigation.yaml` | Cubierto | Fase 4 |
| `catalog-price-ranges.spec.js` | `flows/regression/catalog/price-range-filter.yaml` | Parcial | Fase 2; un rango configurable (`PRICE_FILTER_RANGE`) |
| `personalized-product-customization.spec.js` | `flows/regression/catalog/personalized-product.yaml` | Parcial | Fase 2; valida UI personalización, sin upload de imagen |
| `search-autocomplete-navigation.spec.js` | `flows/regression/catalog/search-autocomplete-navigation.yaml` | Parcial | Fase 4; sugerencias → PDP |
| `search-no-results-recovery.spec.js` | `flows/regression/catalog/search-no-results-recovery.yaml` | Cubierto | Fase 4 |
| `search-then-filter-combined.spec.js` | `flows/regression/catalog/search-then-filter-combined.yaml` | Parcial | Fase 5; sort + precio en búsqueda |

### Shopping cart (`tests/regression/shopping-cart/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `cart-coupon.spec.js` | `flows/regression/cart/apply-coupon-valid.yaml` | Parcial | Requiere `VALID_COUPON_CODE` en `.env` |
| `cart-upsell.spec.js` | `flows/regression/cart/upsell-additional.yaml` | Parcial | Fase 2; abre/cierra dialogo sin agregar adicional |
| `main-product-additional-removal.spec.js` | `flows/regression/cart/remove-product.yaml` | Parcial | |
| `main-cart-delivery-date-recalculation.spec.js` | `flows/regression/cart/delivery-date-change.yaml` | Parcial | Sin validar recálculo de totales |
| `city-change-cart-behavior.spec.js` | `flows/regression/cart/city-change-cart-behavior.yaml` | Parcial | Fase 5; persist o clear (`CITY_CHANGE_CART_BEHAVIOR`) |
| `cart-multitab-consistency.spec.js` | — | N/A | Multi-tab es patrón browser |

### Checkout (`tests/regression/checkout/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `checkout-entry-contract.spec.js` | `flows/regression/checkout/checkout-payment-entry.yaml` | Parcial | |
| `checkout-basic` (smoke) | `flows/regression/checkout/checkout-basic.yaml` | Parcial | |
| `address-crud-checkout.spec.js` | `flows/regression/checkout/checkout-address.yaml` | Parcial | CRUD completo condicionado en web |
| `checkout-invalid-card.spec.js` | `flows/regression/checkout/payment-sandbox-error.yaml` | Parcial | Tarjeta sandbox decline |
| `checkout-phone-validation.spec.js` | `flows/regression/checkout/checkout-phone-validation.yaml` | Cubierto | |
| `checkout-after-cart-date-change.spec.js` | `flows/regression/checkout/checkout-after-cart-date-change.yaml` | Parcial | Fase 4; cambio fecha en carrito → checkout |
| `checkout-city-change-recovery.spec.js` | — | Pendiente | |
| `checkout-payment-method-switch.spec.js` | `flows/regression/checkout/checkout-payment-method-switch.yaml` | Parcial | Fase 5; OXXO → tarjeta |
| `checkout-refresh-persistence.spec.js` | — | Pendiente | |
| `checkout-alternate-payment-surfaces.spec.js` | — | Pendiente | PayPal, Mercado Pago, SPEI |
| `commercial-flow.spec.js` | — | Pendiente | Flujo comercial E2E |

### Purchase / OXXO (`tests/regression/purchase/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `oxxo-confirmation-contract.spec.js` | `flows/regression/checkout/oxxo-confirmation-contract.yaml` | Parcial | Fase 3; referencia + monto + fecha límite |
| `oxxo-no-double-purchase.spec.js` | `flows/regression/checkout/oxxo-no-double-purchase.yaml` | Parcial | Fase 3; doble tap UI, sin assert API |
| `oxxo-post-purchase-orders.spec.js` | `flows/regression/account/order-history-detail.yaml` | Parcial | Fase 3; markers OXXO cuando hay pedido pendiente |
| `coupon-oxxo-totals-contract.spec.js` | — | Pendiente | **P0 web** |

### Location (`tests/regression/location/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `shipping-selector-full-flow.spec.js` | reusables `select-city`, `select-home-delivery-date` | Parcial | |
| `city-change-catalog-content-isolation.spec.js` | `flows/regression/location/city-change-catalog.yaml` | Parcial | Mobile valida cambio + listado, no aislamiento de contenido |
| `delivery-calendar-restricted-dates.spec.js` | — | Pendiente | |
| `home-location-search-contract.spec.js` | — | Pendiente | |
| `language-currency-persistence-navigation.spec.js` | — | Pendiente | |

### Clients / Account (`tests/regression/clients/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `address-create.spec.js` | `flows/regression/account/address-book-add.yaml` | Cubierto | |
| `reminder-create.spec.js` | `flows/regression/account/reminder-create.yaml` | Parcial | Fase 1 P1; solo alta |
| `rewards-and-coupons.spec.js` | `flows/regression/account/rewards-program.yaml`, `my-coupons.yaml` | Parcial | Fase 4; programa puntos + Mis cupones |
| — | `flows/regression/account/address-book.yaml` | Mobile+ | |
| — | `flows/regression/account/edit-profile-validation.yaml` | Mobile+ | Validación negativa perfil |

### Orders (`tests/regression/orders/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `order-cancel-contract.spec.js` | `flows/regression/account/order-cancel-dialog.yaml` | Parcial | Fase 4; abre/cierra modal (sin cancelar) |
| `order-hide-contract.spec.js` | `flows/regression/account/order-hide-dialog.yaml` | Parcial | Fase 4; modal Ocultar + Cancelar |
| `order-help-faq.spec.js` | `flows/regression/account/order-help-faq.yaml` | Parcial | Fase 4; centro ayuda desde pedido |
| `order-payment-retry-contract.spec.js` | `flows/regression/account/order-payment-retry.yaml` | Parcial | Fase 4; condicional si hay pago pendiente |
| `order-report-create-contract.spec.js` | `flows/regression/account/order-report-create.yaml` | Parcial | Fase 5; condicional si hay acción Reportar |

### Site (`tests/regression/site/`)

| Spec web | Flow mobile | Estado | Notas |
| --- | --- | --- | --- |
| `webview-cookie-and-paypal.spec.js` | — | N/A | |
| `webview-customizer-persistence.spec.js` | — | N/A | |

---

## API — `tests/api/*` (28 specs)

**Estado: N/A para Maestro.** Contratos API viven en `ef-qa-automation`. Mobile puede reutilizar mismos datos (`.env`) pero no duplica la suite.

Dominios API web: auth, catalog, shopping-cart, checkout, customer, location, orders, site/health.

---

## Mobile-only (sin equivalente directo en smoke/regression web UI)

| Flow mobile | Propósito |
| --- | --- |
| `flows/smoke/launch-app.yaml` | Arranque app + Home |
| `flows/smoke/home.yaml` | Elementos críticos Home |
| `flows/smoke/empty-cart.yaml` | Carrito vacío |
| `flows/smoke/deeplink-home.yaml` | Deeplink home |
| `flows/regression/deeplink/deeplink-cart-empty.yaml` | `/shoppingcart` vacío |
| `flows/regression/deeplink/deeplink-cart-with-product.yaml` | `/shoppingcart` con producto |
| `flows/regression/deeplink/deeplink-product-detail.yaml` | PDP por URL con ciudad |
| `flows/regression/deeplink/deeplink-category.yaml` | Categoría por URL |
| `flows/regression/deeplink/deeplink-faq.yaml` | FAQ / centro ayuda |
| `flows/regression/catalog/browse-category.yaml` | Navegación categoría estable |
| `flows/regression/cart/apply-coupon.yaml` | Cupón inválido |
| `flows/special/validacion-bines*.yaml` | Validación BINes (mobile) |

---

## Prioridades web (referencia `bug-reports/reporte-cobertura-suite-2026-04-09.md`)

| Prioridad | Tema web | Estado mobile |
| --- | --- | --- |
| **P0** | OXXO happy path + cupón + post-compra | Parcial (Fase 3) |
| **P0** | Detalle pedido desde Mis pedidos | Parcial (`order-history-detail`) |
| **P1** | Guest cart merge on login | Parcial (Fase 3) |
| **P1** | PDP personalización / adicionales | Parcial (Fase 2) |
| **P1** | Guards unavailable / out-of-stock | Parcial (`product-unavailable`) |
| **P1** | Cart upsell / totales | Parcial (Fase 2) |
| **P2** | Analytics checkout, CTAs Home | Pendiente / N/A |

---

## Fases de implementación mobile

### Fase 1 — Completada (P0 + P1 paridad inicial)

| Spec web | Flow mobile |
| --- | --- |
| `smoke/auth/logout.spec.js` | `regression/auth/logout.yaml` |
| `smoke/shopping-cart/multi-product-cart.spec.js` | `regression/cart/multi-product.yaml` |
| `smoke/shopping-cart/main-cart-delivery-date.spec.js` | `regression/cart/delivery-date-change.yaml` |
| `smoke/location/shipping-guards-and-persistence.spec.js` | `shipping-guards.yaml` + `shipping-flow-home-to-pdp.yaml` |
| `smoke/catalog/megamenu.spec.js` | `regression/catalog/megamenu-navigation.yaml` |
| `smoke/home/home-navigation.spec.js` | `regression/catalog/home-navigation.yaml` |
| `smoke/location/city-change.spec.js` | `regression/location/city-change-catalog.yaml` |
| `smoke/checkout/dedicatoria.spec.js` | `regression/checkout/dedicatoria.yaml` |
| `regression/clients/reminder-create.spec.js` | `regression/account/reminder-create.yaml` (Parcial) |

### Fase 2 — Catálogo y carrito avanzado (implementada)

| Spec web | Flow mobile | Estado |
| --- | --- | --- |
| `regression/catalog/personalized-product-customization.spec.js` | `regression/catalog/personalized-product.yaml` | Parcial |
| `regression/catalog/catalog-price-ranges.spec.js` | `regression/catalog/price-range-filter.yaml` | Parcial |
| `regression/shopping-cart/cart-upsell.spec.js` | `regression/cart/upsell-additional.yaml` | Parcial |
| `regression/shopping-cart/cart-coupon.spec.js` | `apply-coupon-valid.yaml` | Parcial (requiere `VALID_COUPON_CODE`) |

### Fase 3 — P0 negocio (OXXO + auth carrito) (implementada)

| Spec web | Flow mobile | Estado |
| --- | --- | --- |
| `regression/purchase/oxxo-confirmation-contract.spec.js` | `regression/checkout/oxxo-confirmation-contract.yaml` | Parcial |
| `regression/purchase/oxxo-no-double-purchase.spec.js` | `regression/checkout/oxxo-no-double-purchase.yaml` | Parcial |
| `regression/auth/guest-to-auth-cart-state.spec.js` | `regression/auth/guest-cart-merge.yaml` | Parcial |
| `regression/purchase/oxxo-post-purchase-orders.spec.js` | `order-history-detail.yaml` (reforzado) | Parcial |

### Fase 4 — Regression operacional (implementada)

| Spec web | Flow mobile | Estado |
| --- | --- | --- |
| `regression/catalog/search-no-results-recovery.spec.js` | `regression/catalog/search-no-results-recovery.yaml` | Cubierto |
| `regression/catalog/search-autocomplete-navigation.spec.js` | `regression/catalog/search-autocomplete-navigation.yaml` | Parcial |
| `regression/catalog/catalog-pdp-back-navigation.spec.js` | `regression/catalog/pdp-back-navigation.yaml` | Cubierto |
| `regression/auth/session-persistence-across-navigation.spec.js` | `regression/auth/session-persistence-navigation.yaml` | Parcial | Home ↔ cuenta; sin paso búsqueda |
| `regression/checkout/checkout-after-cart-date-change.spec.js` | `regression/checkout/checkout-after-cart-date-change.yaml` | Parcial |
| `regression/clients/rewards-and-coupons.spec.js` | `regression/account/rewards-program.yaml`, `my-coupons.yaml` | Parcial |
| `regression/orders/order-help-faq.spec.js` | `regression/account/order-help-faq.yaml` | Parcial |
| `regression/orders/order-hide-contract.spec.js` | `regression/account/order-hide-dialog.yaml` | Parcial |
| `regression/orders/order-cancel-contract.spec.js` | `regression/account/order-cancel-dialog.yaml` | Parcial |
| `regression/orders/order-payment-retry-contract.spec.js` | `regression/account/order-payment-retry.yaml` | Parcial (condicional) |

**Reusable nuevo:** `flows/reusable/open-first-order-detail.yaml`

**Validación emulador (2026-05-19):** Fase 4 flows catalog/auth **Passed**. Fase 5 flows **sin validar** aún.

**Pendiente:** coupon-oxxo-totals, locale/calendar, home banners, checkout recovery avanzado, register happy-path.

### Fase 5 — Brechas principales (implementada)

| Spec web | Flow mobile | Estado |
| --- | --- | --- |
| `regression/auth/logout-and-relogin.spec.js` | `regression/auth/logout-and-relogin.yaml` | Cubierto |
| `regression/auth/register-validation.spec.js` | `regression/auth/register-validation.yaml` | Parcial |
| `regression/catalog/search-then-filter-combined.spec.js` | `regression/catalog/search-then-filter-combined.yaml` | Parcial |
| `smoke/shopping-cart/cart-session-persistence.spec.js` | `regression/cart/cart-session-persistence.yaml` | Parcial |
| `regression/shopping-cart/city-change-cart-behavior.spec.js` | `regression/cart/city-change-cart-behavior.yaml` | Parcial |
| `regression/checkout/checkout-payment-method-switch.spec.js` | `regression/checkout/checkout-payment-method-switch.yaml` | Parcial |
| `regression/orders/order-report-create-contract.spec.js` | `regression/account/order-report-create.yaml` | Parcial (condicional) |

---

## Variables alineadas web ↔ mobile

```env
# Ubicación (mobile usa ciudad alterna disponible en QA)
DEFAULT_STATE="Nuevo León"
DEFAULT_CITY=Monterrey
ALTERNATE_STATE="Nuevo León"
ALTERNATE_CITY="San Pedro Garza Garcia"

# Catálogo / carrito
PRODUCT_SEARCH_TERM=rosas
PRODUCT_NAME="Clásico Amor con 24 Rosas Rojas"
SECOND_PRODUCT_SEARCH_TERM=globo
SECOND_PRODUCT_NAME=Globo
SECOND_CATEGORY_NAME="Cumpleaños"
CATEGORY_NAME="Cumpleaños"
HOME_CATEGORY_BIRTHDAY="Cumpleaños"
HOME_CATEGORY_FLOWERS="Flores y plantas"
HOME_CATEGORY_GIFTS=Regalos

# Cuenta / checkout
USER_EMAIL=...
USER_PASSWORD=...
REMINDER_TITLE="QA Recordatorio Maestro"
INVALID_COUPON_CODE=QA-CUPON-INVALIDO
# VALID_COUPON_CODE=...   # opcional; alinea con EF_VALID_COUPON web

# Deeplinks (PDP debe incluir ciudad en path para app nativa)
DEEPLINK_HOME=enviaflores://
DEEPLINK_CATEGORY=https://www.enviaflores.com/florerias-nuevo-leon/monterrey/cumpleanos
DEEPLINK_PRODUCT=https://www.enviaflores.com/florerias-nuevo-leon/monterrey/002
DEEPLINK_PERSONALIZED_PRODUCT=https://www.enviaflores.com/florerias-nuevo-leon/monterrey/26009
PRICE_FILTER_RANGE="Menor $399"
PRICE_FILTER_RANGE_HIGH="Mayor $990"
SORT_ORDER_DESC="Mayor a menor $"
CITY_CHANGE_CART_BEHAVIOR=either
SEARCH_AUTOCOMPLETE_TERM=globo
DEEPLINK_CART=https://www.enviaflores.com/shoppingcart
DEEPLINK_FAQ=https://www.enviaflores.com/faq
```

**Equivalencias web → mobile:**

| Web | Mobile |
| --- | --- |
| `BASE_URL` + `CATALOG_PATH` | `DEFAULT_STATE` + `DEFAULT_CITY` + `CATEGORY_NAME` |
| `EF_USER` / `EF_PASS` | `USER_EMAIL` / `USER_PASSWORD` |
| `EF_VALID_COUPON` | `VALID_COUPON_CODE` |
| `PERSONALIZED_PRODUCT_SKU` | `DEEPLINK_PERSONALIZED_PRODUCT` (path con SKU) |
| `PRICE_RANGES` (web) | `PRICE_FILTER_RANGE` / `PRICE_FILTER_RANGE_HIGH` |
| `SEARCH_AUTOCOMPLETE_TERM` (web) | `SEARCH_AUTOCOMPLETE_TERM` (ej. `globo`) |
| `CITY_CHANGE_CART_BEHAVIOR` (web) | `CITY_CHANGE_CART_BEHAVIOR` (`persist`, `clear`, `either`) |

---

## Notas de equivalencia mobile vs web

- **Megamenu / Home nav:** mobile usa pestaña `Categorías` (`action_category`); no hay hover ni secondary cart.
- **Dedicatoria / recordatorios:** mobile valida flujo feliz; web incluye edit/delete.
- **Deeplinks:** configurar app links en emulador (`npm run emulator:disable-stylus`); usar `openLink` con `autoVerify: true`.
- **Multi-product:** segundo producto vía categoría (tap en listado); no depender de SKU fijo en búsqueda.
- **Regression core:** excluye checkout; usar `maestro:checkout:android` o `maestro:regression:full:android` para paridad completa.

---

## Comandos útiles

```bash
# Suites por dominio
npm run maestro:smoke:android
npm run maestro:regression:android      # core (sin checkout)
npm run maestro:regression:full:android
npm run maestro:auth:android
npm run maestro:catalog:android
npm run maestro:cart:android
npm run maestro:location:android
npm run maestro:account:android
npm run maestro:checkout:android
npm run maestro:deeplink:android

# Flow individual
npm run maestro:flow:android -- flows/regression/catalog/megamenu-navigation.yaml

# Setup emulador (stylus + app links HTTPS → app nativa)
npm run emulator:disable-stylus
```

---

## Fuera de alcance mobile

- Suite API Playwright (`tests/api/*`)
- Utilities de cancelación de pedidos (`tests/utilities/*`)
- Site: footer, legal, SEO/a11y, CleverTap, marketing static routes
- Rutas tokenizadas web (reset password, encuestas, CLRT)
- Webviews embebidos (customizer, PayPal cookie flows)
- Multi-tab browser (`cart-multitab-consistency.spec.js`)
- Secondary cart como overlay (patrón UX distinto en native)
