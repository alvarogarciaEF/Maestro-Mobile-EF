# QA Mobile EnviaFlores Maestro Framework

Framework base para automatizacion mobile de las apps de EnviaFlores usando [Maestro](https://maestro.mobile.dev/). Esta primera version esta orientada a smoke tests y deja una estructura limpia para crecer hacia regression tests en Android e iOS.

## Repos Fuente

- Android: `enviaflores/ef-storefront-android`
- iOS: `enviaflores/ef-storefront-ios`
- `applicationId` Android: `com.enviaflores.android`
- Bundle id iOS: `com.enviaflores.ios`
- Launcher principal Android: `SplashActivity`, con navegacion posterior hacia `HomeActivity`.
- Deep links Android detectados: `https://enviaflores.com`, `https://www.enviaflores.com`, hosts de dev/staging storefront web y scheme `enviaflores://`.
- App principal iOS: `EnviaFloresApp`, con entrada SwiftUI en `RootView`.
- Deep links iOS detectados: scheme `enviaflores://`, associated domains para `www.enviaflores.com` y hosts storefront web de dev/qa/staging.

## Requisitos Previos

- macOS, Linux o runner compatible con Maestro.
- Node.js 18+ para ejecutar scripts npm.
- Maestro CLI instalado localmente.
- Android SDK y un emulador/dispositivo disponible para Android.
- Xcode y un simulador iniciado para iOS.
- App de pruebas disponible en `apps/android/` o `apps/ios/`.

## Instalacion De Maestro

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
maestro --version
```

Si el comando no queda disponible, agrega Maestro al `PATH` siguiendo las instrucciones que muestra el instalador.

## Estructura Del Proyecto

```text
qa-mobile-enviaflores/
├── .github/workflows/       # Workflows on-demand para GitHub Actions
├── apps/                    # Binarios locales: APK o app iOS
├── data/                    # Datos dummy y estructura para test data
├── flows/                   # Flows Maestro por suite y reusables
│   ├── smoke/               # Pruebas criticas de arranque
│   ├── regression/          # Base para escenarios extendidos
│   ├── reusable/            # Subflows compartidos
│   └── utils/               # Utilidades tecnicas
├── reports/                 # Salida de ejecucion
├── scripts/                 # Entrypoints shell usados por npm y CI
├── config.yaml              # Configuracion documental/base del framework
└── package.json             # Comandos npm
```

## Variables De Ambiente

1. Copia el archivo de ejemplo:

```bash
cp .env.example .env
```

2. Reemplaza los valores segun tu app:

```env
APP_ID_ANDROID=com.enviaflores.android
APP_ID_IOS=com.enviaflores.ios
USER_EMAIL=qa.user@example.com
USER_PASSWORD=change-me
DEFAULT_STATE="Nuevo León"
DEFAULT_CITY=Monterrey
PRODUCT_SEARCH_TERM=rosas
PRODUCT_NAME="Clásico Amor con 24 Rosas Rojas"
CATEGORY_NAME="Cumpleaños"
DEEPLINK_HOME=enviaflores://
DEEPLINK_CATEGORY=https://www.enviaflores.com/florerias-nuevo-leon/monterrey/cumpleanos
DEEPLINK_PRODUCT=https://www.enviaflores.com/product/001
DEEPLINK_CART=https://www.enviaflores.com/shoppingcart
DEEPLINK_FAQ=https://www.enviaflores.com/faq
```

Los scripts cargan `.env` automaticamente si existe. No subas `.env` al repositorio.

## Comandos Locales

Instala metadata npm del proyecto:

```bash
npm install
```

Revisa preflight local:

```bash
npm run maestro:doctor
```

### Login con Google en el emulador (smoke + account)

El smoke `login.yaml` usa **Continuar con Google**. La cuenta debe existir en el AVD (no basta con `.env`). Guia completa: [docs/emulator-google-setup.md](docs/emulator-google-setup.md).

```bash
npm run emulator:google-setup   # abre Settings → Add account en el emulador
npm run emulator:google-check     # valida que GOOGLE_ACCOUNT_EMAIL este en el dispositivo
```

`GOOGLE_ACCOUNT_EMAIL` debe ser Gmail o Google Workspace. `USER_EMAIL` puede ser otro correo (ej. Mailinator) para login email/password.

### Stylus en el emulador (Pixel 9 / API 36)

Si aparece el teclado de **stylus/handwriting** de Gboard, Maestro no puede teclear ni tocar bien. Antes de correr suites:

```bash
npm run emulator:disable-stylus
```

En la ventana del emulador, no actives el icono de **lapiz/stylus** en Extended controls (...). Si ya esta activo, desactivalo ahi.

Valida estructura del framework sin ejecutar Maestro:

```bash
npm run validate
```

El validador puede advertir referencias a textos de pago como `Pagar y completar compra`; eso es aceptable si aparecen solo como `assertVisible` y nunca como `tapOn`.

Ejecuta smoke Android:

```bash
npm run maestro:smoke:android
```

Primer paquete smoke:

```text
flows/smoke/launch-app.yaml
flows/smoke/home.yaml
flows/smoke/select-city.yaml
flows/smoke/login.yaml
flows/smoke/empty-cart.yaml
flows/smoke/deeplink-home.yaml
```

Ejecuta regression Android (core, sin checkout):

```bash
npm run maestro:regression:android
```

Ejecuta regression completa Android (incluye checkout pausado):

```bash
npm run maestro:regression:full:android
```

Ejecuta suites parciales Android:

```bash
npm run maestro:catalog:android
npm run maestro:cart:android
npm run maestro:checkout:android
npm run maestro:account:android
npm run maestro:deeplink:android
```

Ejecuta un flow individual Android:

```bash
npm run maestro:flow:android -- flows/smoke/home.yaml
```

Primer paquete regression:

```text
flows/regression/auth/login-invalid.yaml
flows/regression/auth/recover-password.yaml
flows/regression/catalog/search-product.yaml
flows/regression/catalog/search-no-results.yaml
flows/regression/catalog/product-detail.yaml
flows/regression/catalog/product-unavailable.yaml
flows/regression/catalog/browse-category.yaml
flows/regression/catalog/filter-category.yaml
flows/regression/cart/cart-from-search.yaml
flows/regression/cart/add-product-to-cart.yaml
flows/regression/cart/apply-coupon.yaml
flows/regression/cart/update-quantity.yaml
flows/regression/cart/remove-product.yaml
flows/regression/checkout/checkout-address.yaml
flows/regression/checkout/checkout-payment-entry.yaml
flows/regression/account/address-book.yaml
flows/regression/account/order-history.yaml
flows/regression/deeplink/deeplink-category.yaml
flows/regression/deeplink/deeplink-product-detail.yaml
flows/regression/deeplink/deeplink-cart-empty.yaml
flows/regression/deeplink/deeplink-cart-with-product.yaml
flows/regression/deeplink/deeplink-faq.yaml
```

Ejecuta smoke iOS:

```bash
npm run maestro:smoke:ios
```

Ejecuta smoke Android + iOS en secuencia:

```bash
npm run maestro:smoke:cross-platform
```

Ejecuta regression iOS (core, sin checkout):

```bash
npm run maestro:regression:core:ios
```

Ejecuta suites parciales iOS:

```bash
npm run maestro:catalog:ios
npm run maestro:cart:ios
npm run maestro:checkout:ios
npm run maestro:account:ios
```

Ejecuta un flow individual iOS:

```bash
npm run maestro:flow:ios -- flows/smoke/home.yaml
```

Abre Maestro Studio:

```bash
npm run maestro:studio
```

Ejecuta solo el smoke de login:

```bash
npm run maestro:login
```

## Checklist Primera Corrida Android

- Maestro instalado y visible con `maestro --version`.
- Emulador/dispositivo Android iniciado y visible con `adb devices`.
- APK instalado:

```bash
./scripts/install-app.sh android apps/android/app-qa.apk
```

- `.env` creado desde `.env.example`.
- Usuario QA valido en `USER_EMAIL` y `USER_PASSWORD`.
- Usuario QA con direccion guardada si vas a correr checkout hasta metodo de pago.
- `DEFAULT_STATE` y `DEFAULT_CITY` disponibles en el ambiente probado.
- `PRODUCT_NAME` corresponde a un producto activo para `PRODUCT_SEARCH_TERM` en esa ciudad.
- Primera corrida sugerida:

```bash
npm run maestro:flow:android -- flows/smoke/launch-app.yaml
npm run maestro:flow:android -- flows/smoke/home.yaml
npm run maestro:flow:android -- flows/regression/catalog/search-product.yaml
npm run maestro:flow:android -- flows/regression/cart/cart-from-search.yaml
```

- Despues corre suites parciales antes de `regression` completa:

```bash
npm run maestro:catalog:android
npm run maestro:cart:android
```

## Instalacion De La App

El script `scripts/install-app.sh` deja una base para instalar builds locales:

```bash
./scripts/install-app.sh android apps/android/app-qa.apk
./scripts/install-app.sh ios apps/ios/MyApp.app
```

Adapta ese script si tu pipeline descarga builds desde un artifact store.

## Convenciones Para Nuevos Flows

- Ubica flows criticos en `flows/smoke/`.
- Ubica escenarios extensos por dominio en `flows/regression/<dominio>/`.
- Usa nombres descriptivos en kebab-case: `add-product-to-cart.yaml`.
- Agrega `tags` al encabezado del flow.
- Usa variables de ambiente para credenciales, appId, ciudad, estado y datos sensibles.
- Mantén cada flow enfocado en una intencion de negocio.
- Consulta `docs/selector-map.md` antes de crear o ajustar selectores.
- Consulta `docs/naming-and-selectors.md` para convenciones completas.
- Consulta `docs/flow-coverage.md` para entender cobertura, riesgo y orden sugerido de ejecucion.
- Consulta `docs/web-mobile-parity.md` para mapeo de paridad con el framework web Playwright.
- Consulta `docs/coverage-matrix.md` para seguimiento por estado `Cubierto/Parcial/No cubierto`.
- Consulta `docs/high-risk-gap-backlog.md` para calendarizacion de escenarios faltantes.
- Consulta `docs/regression-core.md` para regresion sin checkout (pausado hasta sandbox dev).
- Consulta `docs/smoke-cross-platform.md` para corrida smoke Android+iOS.
- Consulta `docs/deeplinks-android.md` para patrones de URL y variables de deeplink.
- Agrega comentarios iniciales claros en cada YAML:

```yaml
# Proposito: explica que valida o documenta el archivo.
# Precondiciones: datos, estado o ambiente necesarios antes de correrlo.
# Valida/Nota: resultado esperado, punto de corte o restriccion importante.
```

## Convenciones Para Reutilizar Flows

- Coloca pasos compartidos en `flows/reusable/`.
- Evita que un reusable lance la app salvo que ese sea su objetivo explicito.
- Invoca subflows con `runFlow`.
- Mantén selectores reales aislados y faciles de reemplazar.

Ejemplo:

```yaml
- runFlow: ../reusable/close-modals.yaml
- runFlow: ../reusable/login-valid-user.yaml
```

## Buenas Practicas

- Prefiere `testID`/accessibility ids estables sobre texto visible.
- No automatices pagos reales; usa ambientes sandbox y tarjetas dummy.
- Mantén datos sensibles en `.env` local o GitHub Secrets.
- Haz que los smoke tests sean rapidos, deterministas y pequenos.
- Revisa reportes en `reports/` despues de cada corrida.
- Evita duplicar pasos: extrae login, logout, seleccion de ciudad y cierre de modales.
- Versiona solo ejemplos y estructura, no builds ni reportes generados.

## GitHub Actions

El gate estatico `validate.yml` corre automaticamente en cada **pull request** y push a `main` (sin device). Los workflows con device siguen siendo `workflow_dispatch` manual y permiten elegir `environment` (`qa` o `dev`). Configura estos secrets en GitHub:

- `USER_EMAIL`
- `USER_PASSWORD`
- `APK_DOWNLOAD_URL` — URL de descarga del APK de QA; requerido para los jobs Android con emulador.

Tambien puedes adaptar `APP_ID_ANDROID`, `DEFAULT_STATE`, `DEFAULT_CITY`, `PRODUCT_SEARCH_TERM`, `PRODUCT_NAME`, `CATEGORY_NAME` y `DEEPLINK_HOME` en los workflows o convertirlos en variables/secrets del repositorio.

Workflows disponibles:

- `validate.yml` (PR + push a `main`; gate estatico sin device)
- `maestro-smoke-android.yml`
- `maestro-smoke-ios.yml`
- `maestro-regression-android.yml`
- `maestro-regression-mobile-segmented.yml`

Los workflows con device bootean emulador Android (`reactivecircus/android-emulator-runner` + composite `.github/actions/android-maestro`). Estado, limitaciones (login-Google, iOS Fase 2) y pendientes en [docs/ci-rollout.md](docs/ci-rollout.md).

Todos publican resumen JUnit en `GITHUB_STEP_SUMMARY` y artifacts en `reports/`.

## Roadmap Sugerido

- Agregar smoke iOS en GitHub Actions.
- Integrar instalacion automatica de APK/IPA desde artifacts.
- Agregar estrategia de datos por ambiente.
- Incorporar reportes enriquecidos y publicacion como artifact.
- Definir estandar de accessibility ids con el equipo mobile.
- Separar suites por tags y dominios funcionales.
- Agregar regression para busqueda, catalogo, carrito, checkout y cuenta.
