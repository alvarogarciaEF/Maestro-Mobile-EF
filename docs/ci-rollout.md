# CI Rollout Android+iOS

Plan operativo para evolucionar de ejecucion manual a cobertura continua por niveles.

## Estado actual (Fase 1)

- **Gate estatico obligatorio** (`validate.yml`): corre `npm run validate` en cada PR y push a
  `main`, sin emulador ni app. Valida YAML, grafo de subflows, comentarios de cabecera, politica
  de esperas, variables declaradas, seguridad de pagos y **credenciales embebidas**.
- **Scaffold de emulador Android**: los workflows `maestro-smoke-android.yml`,
  `maestro-regression-android.yml` y el job Android de `maestro-regression-mobile-segmented.yml`
  bootean un emulador con `reactivecircus/android-emulator-runner` y reusan la composite
  `.github/actions/android-maestro` (Node, Maestro, KVM y descarga del APK).
- **Pendiente para dejar Android en verde**: definir el secret `APK_DOWNLOAD_URL` (origen del
  binario). Mientras este vacio, los jobs Android **fallan claro** en el paso de descarga del
  APK, en lugar de dar un verde falso.
- **Limitacion conocida del smoke**: `flows/smoke/login.yaml` usa login con Google, que requiere
  una cuenta Google provisionada en el AVD (ver `docs/emulator-google-setup.md`). En un emulador
  CI estandar ese flujo fallara; opciones: runner self-hosted con Google provisionado, o excluir
  `login.yaml` del smoke en CI. La regression autentica con email/password
  (Secrets `USER_EMAIL`/`USER_PASSWORD`) y no depende de Google.
- **iOS: Fase 2**. Los jobs iOS (`maestro-smoke-ios.yml` y el job iOS del segmentado) tienen un
  guard que falla si no hay simulador booteado con la app instalada. Falta wiring de simulador +
  binario en runner macOS.

## Nivel 1 - Smoke Obligatorio

- Android: `maestro-smoke-android.yml`
- iOS: `maestro-smoke-ios.yml`
- Objetivo: validar rutas criticas (`launch`, `home`, `login`, `empty-cart`, `deeplink-home`) por cada cambio relevante.
- Criterio de adopcion: 10 corridas consecutivas con pass rate >= 95%.

## Nivel 2 - Regression Segmentada

- Workflow: `maestro-regression-mobile-segmented.yml`
- Segmentacion por dominio:
  - `catalog`
  - `cart`
  - `checkout`
  - `account`
- Objetivo: ejecutar solo el dominio impactado para reducir tiempo de feedback.
- Criterio de adopcion: flaky rate < 5% por dominio durante 2 semanas.

### Ejecucion en paralelo (matrix)

- Workflow: `maestro-regression-matrix-android.yml` — corre los dominios core en **paralelo** via
  `strategy.matrix` (auth, catalog, cart, location, account, deeplink; `fail-fast: false`), cada
  uno en su propio emulador. Reduce el tiempo total de regresion vs la corrida secuencial.
- `checkout` queda fuera del matrix por seguridad de pagos (igual que `regression-core`).
- Requiere el secret `APK_DOWNLOAD_URL`: sin el, cada celda falla claro en el paso de descarga.
- Alternativa futura: sharding de Maestro (`--shard-split`) dentro de un runner (requiere
  multi-emulador por job). Optimizacion futura: bajar el APK una sola vez y compartirlo por artifact
  en vez de por celda.

## Nivel 3 - Regression Completa

- Android: `maestro-regression-android.yml`
- iOS: `maestro-regression-mobile-segmented.yml` con suite `regression`
- Objetivo: corrida completa nocturna o pre-release.
- Criterio de adopcion: 0 bloqueos de pago real y estabilidad mantenida en checkout.

## Metricas Minimas

- Pass rate global por corrida.
- Fallas por suite/dominio.
- Tiempo total por corrida.
- Tendencia semanal de flaky tests.

Los workflows publican resumen JUnit en `GITHUB_STEP_SUMMARY` con:

- total de tests
- passed/failed/errors/skipped
- pass rate

## Siguiente Paso Recomendado

- Definir el secret `APK_DOWNLOAD_URL` para que Android descargue e instale el binario y la
  regression quede en verde.
- Resolver el login-Google del smoke en CI (runner con Google provisionado o excluir `login.yaml`).
- Fase 2: wiring de simulador iOS + descarga del `.app`/IPA en runner macOS.
