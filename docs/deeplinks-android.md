# Deeplinks Android (referencia)

Patrones soportados por `DeepLinkHandler` en `ef-storefront-android`:

| Caso | Ejemplo URL | Variable Maestro |
| --- | --- | --- |
| Home | `https://www.enviaflores.com` | `DEEPLINK_HOME` (`enviaflores://`) |
| Home + ciudad | `https://www.enviaflores.com/florerias-nuevo-leon/monterrey` | opcional |
| Categoria + ciudad | `https://www.enviaflores.com/florerias-nuevo-leon/monterrey/cumpleanos` | `DEEPLINK_CATEGORY` |
| Categoria + query | `https://www.enviaflores.com/galletas?msbl=351` | `DEEPLINK_CATEGORY` |
| PDP por SKU | `https://www.enviaflores.com/product/001` | `DEEPLINK_PRODUCT` |
| PDP + ciudad | `https://www.enviaflores.com/florerias-nuevo-leon/monterrey/001` | `DEEPLINK_PRODUCT` |
| Carrito | `https://www.enviaflores.com/shoppingcart` | `DEEPLINK_CART` |
| FAQ | `https://www.enviaflores.com/faq` | `DEEPLINK_FAQ` |

Hosts HTTPS registrados en `AndroidManifest.xml`:

- `enviaflores.com`, `www.enviaflores.com`
- `ef-storefront-web-dev.enviaflores.com`, `ef-storefront-web-staging.enviaflores.com`
- Scheme custom: `enviaflores://`

Ajusta `.env` con slugs/SKU reales del catalogo QA antes de correr `npm run maestro:deeplink:android`.
