# CI Rollout Android+iOS

Plan operativo para evolucionar de ejecucion manual a cobertura continua por niveles.

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

- Integrar instalacion automatica de APK/IPA en cada workflow para evitar dependencia manual del runner.
