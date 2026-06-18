# Flow Coverage

Mapa de cobertura actual para saber que valida cada flow, que tan estable deberia ser y que datos necesita antes de ejecutarlo.

## Smoke

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/smoke/launch-app.yaml` | Arranque, Home, toolbar, bottom nav, ciudad/fecha | `APP_ID_ANDROID` | Bajo |
| `flows/smoke/home.yaml` | Elementos criticos de Home | `APP_ID_ANDROID` | Bajo |
| `flows/smoke/select-city.yaml` | Selector estado/ciudad | `DEFAULT_STATE`, `DEFAULT_CITY` | Medio: depende de catalogo de ciudades |
| `flows/smoke/login.yaml` | Login desde Mi cuenta | `USER_EMAIL`, `USER_PASSWORD` | Medio: depende de cuenta QA |
| `flows/smoke/empty-cart.yaml` | Carrito vacio desde estado limpio | `DEFAULT_STATE`, `DEFAULT_CITY` | Medio: limpia estado local |
| `flows/smoke/deeplink-home.yaml` | Apertura por scheme `enviaflores://` | `DEEPLINK_HOME` | Medio: depende de deeplink instalado |

## Auth

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/regression/auth/login-invalid.yaml` | Login email con password invalida | `USER_EMAIL`, `USER_INVALID_PASSWORD` | Medio |
| `flows/regression/auth/login-empty-fields.yaml` | Validacion campos vacios en login | Ninguno extra | Bajo |
| `flows/regression/auth/recover-password.yaml` | Solicitud de enlace de recuperacion | `USER_EMAIL` con cuenta QA | Medio |
| `flows/regression/auth/recover-password-email-not-found.yaml` | Recuperacion con correo inexistente | `RECOVERY_UNKNOWN_EMAIL` | Bajo |

## Catalogo

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/regression/catalog/search-product.yaml` | Busqueda y resultado esperado | `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME` | Medio: depende de disponibilidad |
| `flows/regression/catalog/search-no-results.yaml` | Busqueda sin resultados y fallback | `SEARCH_NO_RESULTS_TERM` | Bajo-medio |
| `flows/regression/catalog/product-detail.yaml` | Busqueda a detalle de producto | `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME` | Medio |
| `flows/regression/catalog/product-unavailable.yaml` | PDP de producto no disponible | `PRODUCT_UNAVAILABLE_NAME`, `PRODUCT_UNAVAILABLE_SEARCH_TERM` | Medio: requiere SKU no disponible en ciudad |
| `flows/regression/catalog/browse-category.yaml` | Navegacion a categoria | `CATEGORY_NAME` | Medio |
| `flows/regression/catalog/filter-category.yaml` | Ordenamiento menor a mayor | `CATEGORY_NAME` | Medio-alto: depende de filtros disponibles |

## Carrito

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/regression/cart/add-product-to-cart.yaml` | Agregar desde detalle | `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME` | Medio |
| `flows/regression/cart/cart-from-search.yaml` | Busqueda -> detalle -> carrito | `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME` | Medio |
| `flows/regression/cart/update-quantity.yaml` | Incrementar/decrementar cantidad | `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME` | Medio: usa setup reusable de carrito |
| `flows/regression/cart/remove-product.yaml` | Eliminar producto | `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME` | Medio: usa setup reusable de carrito |
| `flows/regression/cart/apply-coupon.yaml` | Cupon invalido en carrito | `INVALID_COUPON_CODE`, producto en carrito | Medio |
| `flows/regression/cart/apply-coupon-valid.yaml` | Cupon valido en carrito | `VALID_COUPON_CODE`, producto en carrito | Medio-alto: requiere cupon QA vigente |

## Checkout

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/regression/checkout/checkout-basic.yaml` | Carrito a checkout (telefono) | Cuenta QA valida y producto disponible | Medio |
| `flows/regression/checkout/checkout-phone-validation.yaml` | Bloqueo con telefono vacio | Cuenta QA y producto en carrito | Medio |
| `flows/regression/checkout/checkout-address.yaml` | Checkout hasta destinatario/direccion | Cuenta QA con telefono | Medio-alto |
| `flows/regression/checkout/checkout-payment-entry.yaml` | Llega a metodo de pago sin pagar | Cuenta QA con direccion guardada | Alto |
| `flows/regression/checkout/payment-sandbox-error.yaml` | Error al agregar tarjeta declinada | `SANDBOX_DECLINE_CARD_*` | Alto: sandbox QA |

## Deeplink

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/smoke/deeplink-home.yaml` | Scheme base `enviaflores://` | `DEEPLINK_HOME` | Medio |
| `flows/regression/deeplink/deeplink-category.yaml` | Categoria por URL HTTPS | `DEEPLINK_CATEGORY` | Medio: slug/ciudad deben existir |
| `flows/regression/deeplink/deeplink-product-detail.yaml` | PDP por URL HTTPS | `DEEPLINK_PRODUCT` | Medio: SKU activo |
| `flows/regression/deeplink/deeplink-cart-empty.yaml` | Carrito vacio por `/shoppingcart` | `DEEPLINK_CART` | Bajo |
| `flows/regression/deeplink/deeplink-cart-with-product.yaml` | Carrito con producto por deeplink | `DEEPLINK_CART`, `PRODUCT_NAME` | Medio |
| `flows/regression/deeplink/deeplink-faq.yaml` | Centro de ayuda `/faq` | `DEEPLINK_FAQ` | Bajo |

## Cuenta

| Flow | Cobertura | Datos requeridos | Riesgo |
| --- | --- | --- | --- |
| `flows/regression/account/address-book.yaml` | Acceso a Direcciones | Cuenta QA | Medio |
| `flows/regression/account/order-history.yaml` | Acceso a Mis pedidos | Cuenta QA | Medio |
| `flows/regression/account/order-history-detail.yaml` | Detalle de pedido o estado vacio | Cuenta QA (ideal con pedidos) | Medio |
| `flows/regression/account/address-book.yaml` | Acceso a Direcciones | Cuenta QA | Medio |
| `flows/regression/account/address-book-add.yaml` | Formulario agregar direccion + validacion | Cuenta QA | Medio |
| `flows/regression/account/edit-profile.yaml` | Editar nombre/apellido | Cuenta QA modificable | Alto: modifica datos del usuario |
| `flows/regression/account/edit-profile-validation.yaml` | Validacion campos vacios en perfil | Cuenta QA | Bajo |

## Reusables Y Utils

| Flow | Uso | Riesgo |
| --- | --- | --- |
| `flows/reusable/close-modals.yaml` | Cerrar permisos/modales comunes | Bajo |
| `flows/reusable/ensure-logged-in.yaml` | Garantizar sesion autenticada | Medio |
| `flows/reusable/login-valid-user.yaml` | Login por email/password | Medio |
| `flows/reusable/logout.yaml` | Cerrar sesion | Medio |
| `flows/reusable/select-city.yaml` | Seleccionar ciudad desde Home | Medio |
| `flows/reusable/setup-cart-with-product.yaml` | Armar carrito deterministico desde Home | Medio |
| `flows/reusable/open-checkout-from-cart.yaml` | Carrito a checkout | Medio |
| `flows/reusable/advance-checkout-to-payment.yaml` | Pasos checkout hasta pago | Medio-alto |
| `flows/reusable/open-login-dialog.yaml` | Abrir dialogo de login desde Home | Bajo |
| `flows/reusable/search-open-product.yaml` | Buscar y abrir PDP desde Home | Medio |
| `flows/reusable/after-deeplink-launch.yaml` | Esperar animacion y cerrar modales tras deeplink | Bajo |
| `flows/utils/clear-state.yaml` | Limpiar estado local | Alto si se usa dentro de flows con sesion |

## Orden Recomendado Para Primera Ejecucion

1. `flows/smoke/launch-app.yaml`
2. `flows/smoke/home.yaml`
3. `flows/smoke/select-city.yaml`
4. `flows/regression/catalog/search-product.yaml`
5. `flows/regression/catalog/product-detail.yaml`
6. `flows/regression/cart/cart-from-search.yaml`
7. `flows/smoke/login.yaml`
8. `flows/regression/account/address-book.yaml`
9. `flows/regression/checkout/checkout-address.yaml`

## Brechas Conocidas

- iOS necesita `accessibilityIdentifier` antes de estabilizar smoke equivalente.
- `setup-cart-with-product` reduce dependencia de orden, pero requiere que `PRODUCT_NAME` siga disponible en `DEFAULT_CITY`.
- Checkout requiere confirmar datos de cuenta QA: direccion guardada, telefono y metodos sandbox.
- Catalogo depende de que `PRODUCT_NAME` siga disponible en `DEFAULT_CITY`.
