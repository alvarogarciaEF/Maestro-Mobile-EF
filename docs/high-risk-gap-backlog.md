# High-Risk Gap Backlog

Backlog operativo para cerrar los escenarios `No cubierto` con foco en riesgo de negocio y facilidad de estabilizacion.

## Sprint 1 (Semana 1-2)

| Prioridad | Flujo nuevo | Ruta propuesta | Dependencias | Definition of done |
| --- | --- | --- | --- | --- |
| P0 | Login invalido | `flows/regression/auth/login-invalid.yaml` | Selectores login estables | Implementado |
| P0 | Checkout validacion telefono | `flows/regression/checkout/checkout-phone-validation.yaml` | Cuenta QA sin telefono confirmado | Implementado |
| P1 | Busqueda sin resultados | `flows/regression/catalog/search-no-results.yaml` | Termino inexistente controlado | Implementado |
| P1 | Producto no disponible | `flows/regression/catalog/product-unavailable.yaml` | SKU no disponible por ciudad | Implementado (requiere dataset QA) |

## Sprint 2 (Semana 3-4)

| Prioridad | Flujo nuevo | Ruta propuesta | Dependencias | Definition of done |
| --- | --- | --- | --- | --- |
| P1 | Cupon valido/invalido | `flows/regression/cart/apply-coupon*.yaml` | Cupones QA vigentes | Implementado (invalido + valido) |
| P1 | Error controlado de pago sandbox | `flows/regression/checkout/payment-sandbox-error.yaml` | Metodo sandbox habilitado | Implementado |
| P1 | Recuperar password | `flows/regression/auth/recover-password.yaml` | Canal de QA para recovery | Implementado |
| P2 | Deeplink categoria | `flows/regression/deeplink/deeplink-category.yaml` | URL/scheme por ambiente | Implementado |

## Sprint 3 (Semana 5-6)

| Prioridad | Flujo nuevo | Ruta propuesta | Dependencias | Definition of done |
| --- | --- | --- | --- | --- |
| P2 | Deeplink PDP | `flows/regression/deeplink/deeplink-product-detail.yaml` | SKU deeplink estable | Implementado |
| P2 | Deeplink carrito | `flows/regression/deeplink/deeplink-cart-*.yaml` | Carrito con/ sin producto | Implementado (empty + with product) |
| P2 | Deeplink FAQ | `flows/regression/deeplink/deeplink-faq.yaml` | Host HTTPS QA | Implementado |
| P2 | Wishlist/favoritos | `flows/regression/account/wishlist.yaml` | Feature habilitado en app | Agrega y remueve favorito con persistencia |
| P1 | Recuperacion de red catalogo | `flows/regression/resilience/catalog-network-retry.yaml` | Toggle red en dispositivo/simulador | Simula error y recuperacion con retry exitoso |

## Criterios de Priorizacion

- P0: bloquea compra o autenticacion principal.
- P1: alto impacto en conversion y soporte.
- P2: valor incremental y cobertura de rutas secundarias.

## Capacidad Recomendada

- 2 flows nuevos por semana en paralelo con hardening de existentes.
- 1 ventana semanal para re-baselining de dataset (`PRODUCT_NAME`, ciudad, usuario QA).
- 1 corrida de regresion por dominio despues de integrar cada flujo nuevo.
