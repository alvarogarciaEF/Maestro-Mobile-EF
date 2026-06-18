# Regression Core (sin checkout)

La regresion por defecto (`npm run maestro:regression:android` / `:ios`) ejecuta **regression core** y excluye checkout hasta habilitar sandbox CyberSource en dev.

## Dominios incluidos

- `flows/regression/auth`
- `flows/regression/catalog`
- `flows/regression/cart`
- `flows/regression/account`
- `flows/regression/deeplink`

## Dominios pausados

- `flows/regression/checkout` (requiere sandbox de pagos)
- `flows/special/validacion-bines*` (on-demand, no en regression core)

## Comandos

```bash
npm run maestro:regression:android
npm run maestro:regression:core:ios
npm run maestro:regression:full:android
npm run maestro:regression:full:ios
npm run maestro:auth:android
npm run maestro:deeplink:android
```

Reportes:

- Core: `reports/regression-core-android.xml` / `reports/regression-core-ios.xml`
- Full: `reports/regression-full-android.xml` / `reports/regression-full-ios.xml`

## Reactivacion futura (dev + CyberSource)

1. Validar dataset sandbox en `.env` de dev.
2. Endurecer `flows/regression/checkout/*` contra sandbox.
3. Mover checkout de vuelta a regression core o mantener suite `regression-full` como gate pre-release.
