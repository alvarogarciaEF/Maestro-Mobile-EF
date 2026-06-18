# Coverage Matrix Android+iOS

Matriz base para seguimiento de cobertura por flujo. Estado esperado:

- `Cubierto`: existe flow ejecutable y estable en la suite objetivo.
- `Parcial`: existe flow, pero con dependencias externas, flakes o sin soporte equivalente en ambos OS.
- `No cubierto`: no existe flow automatizado en este repo.

## Smoke

| Dominio | Flow | Android | iOS | Estado global | Prioridad |
| --- | --- | --- | --- | --- | --- |
| Arranque | `flows/smoke/launch-app.yaml` | Cubierto | Parcial | Parcial | P0 |
| Home | `flows/smoke/home.yaml` | Cubierto | Parcial | Parcial | P0 |
| Ubicacion | `flows/smoke/select-city.yaml` | Cubierto | Parcial | Parcial | P0 |
| Auth | `flows/smoke/login.yaml` | Cubierto | Parcial | Parcial | P0 |
| Carrito vacio | `flows/smoke/empty-cart.yaml` | Cubierto | Parcial | Parcial | P0 |
| Deeplink home | `flows/smoke/deeplink-home.yaml` | Cubierto | Parcial | Parcial | P1 |

## Regression Actual

| Dominio | Flow | Android | iOS | Estado global | Prioridad |
| --- | --- | --- | --- | --- | --- |
| Auth | `flows/regression/auth/login-invalid.yaml` | Cubierto | Parcial | Parcial | P0 |
| Auth | `flows/regression/auth/recover-password.yaml` | Cubierto | Parcial | Parcial | P1 |
| Catalogo | `flows/regression/catalog/search-product.yaml` | Cubierto | Parcial | Parcial | P1 |
| Catalogo | `flows/regression/catalog/search-no-results.yaml` | Cubierto | Parcial | Parcial | P1 |
| Catalogo | `flows/regression/catalog/product-detail.yaml` | Cubierto | Parcial | Parcial | P1 |
| Catalogo | `flows/regression/catalog/product-unavailable.yaml` | Parcial | Parcial | Parcial | P1 |
| Catalogo | `flows/regression/catalog/browse-category.yaml` | Cubierto | Parcial | Parcial | P2 |
| Catalogo | `flows/regression/catalog/filter-category.yaml` | Parcial | Parcial | Parcial | P2 |
| Carrito | `flows/regression/cart/add-product-to-cart.yaml` | Cubierto | Parcial | Parcial | P1 |
| Carrito | `flows/regression/cart/cart-from-search.yaml` | Cubierto | Parcial | Parcial | P1 |
| Carrito | `flows/regression/cart/apply-coupon.yaml` | Parcial | Parcial | Parcial | P1 |
| Carrito | `flows/regression/cart/update-quantity.yaml` | Parcial | Parcial | Parcial | P1 |
| Carrito | `flows/regression/cart/remove-product.yaml` | Parcial | Parcial | Parcial | P1 |
| Checkout | `flows/regression/checkout/checkout-basic.yaml` | Parcial | Parcial | Parcial | P0 |
| Checkout | `flows/regression/checkout/checkout-address.yaml` | Parcial | Parcial | Parcial | P0 |
| Checkout | `flows/regression/checkout/checkout-payment-entry.yaml` | Parcial | Parcial | Parcial | P0 |
| Cuenta | `flows/regression/account/address-book.yaml` | Cubierto | Parcial | Parcial | P2 |
| Cuenta | `flows/regression/account/order-history.yaml` | Cubierto | Parcial | Parcial | P2 |
| Cuenta | `flows/regression/account/edit-profile.yaml` | Parcial | Parcial | Parcial | P2 |
| Deeplink | `flows/regression/deeplink/deeplink-category.yaml` | Cubierto | Parcial | Parcial | P2 |
| Deeplink | `flows/regression/deeplink/deeplink-product-detail.yaml` | Cubierto | Parcial | Parcial | P2 |
| Deeplink | `flows/regression/deeplink/deeplink-cart-empty.yaml` | Cubierto | Parcial | Parcial | P2 |
| Deeplink | `flows/regression/deeplink/deeplink-cart-with-product.yaml` | Cubierto | Parcial | Parcial | P2 |
| Deeplink | `flows/regression/deeplink/deeplink-faq.yaml` | Cubierto | Parcial | Parcial | P2 |

## Gaps Priorizados (No Cubierto)

| Dominio | Flujo faltante | Estado | Prioridad |
| --- | --- | --- | --- |
| Auth | Login invalido | Cubierto | P0 |
| Auth | Recuperar password | Cubierto | P1 |
| Catalogo | Busqueda sin resultados | Cubierto | P1 |
| Catalogo | Producto sin stock / no disponible | Parcial | P1 |
| Carrito | Aplicar cupon valido/invalido | Parcial | P1 |
| Checkout | Validaciones de telefono/direccion obligatoria | No cubierto | P0 |
| Checkout | Error de pago sandbox controlado (sin compra real) | No cubierto | P1 |
| Cuenta | Wishlist / favoritos | No cubierto | P2 |
| Deeplink | Deeplink PDP, categoria y carrito | Parcial | P2 |
| Resiliencia | Error de red y recuperacion en home/catalogo | No cubierto | P1 |

## Criterios de Salida por Fase

- Fase 1: todos los smoke en `Cubierto` Android y al menos `Parcial` iOS sin flakes bloqueantes.
- Fase 2: dominios `catalog`, `cart` y `checkout` con estado minimo `Parcial` estable en ambos OS.
- Fase 3: al menos 6 gaps `No cubierto` convertidos a `Parcial/Cubierto` con pipeline activo.
