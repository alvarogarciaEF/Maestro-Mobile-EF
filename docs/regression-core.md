# Regression Core y Checkout Sandbox

La regresion por defecto (`npm run maestro:regression:android` / `:ios`) puede incluir checkout cuando el ambiente esta marcado como sandbox. Staging apunta a gateways sandbox, por lo que es seguro concluir flows de checkout/purchase en ese ambiente.

Control principal:

```env
TARGET_ENV=staging
CHECKOUT_PURCHASE_MODE=sandbox
ALLOW_SANDBOX_PURCHASES=auto
INCLUDE_CHECKOUT_IN_REGRESSION=auto
```

## Dominios incluidos

- `flows/regression/auth`
- `flows/regression/catalog`
- `flows/regression/cart`
- `flows/regression/account`
- `flows/regression/deeplink`
- `flows/regression/checkout` cuando `INCLUDE_CHECKOUT_IN_REGRESSION` resuelve a true.

## Purchase sandbox

Los flows que concluyen compra estan permitidos en staging/sandbox:

- `flows/regression/checkout/oxxo-confirmation-contract.yaml`
- `flows/regression/checkout/oxxo-no-double-purchase.yaml`
- `flows/regression/account/coupon-used-after-purchase.yaml`

Fuera de sandbox, los scripts los omiten de suites amplias y bloquean el suite `purchase`.

## Comandos

```bash
npm run maestro:regression:android
npm run maestro:regression:core:ios
npm run maestro:regression:core:android
npm run maestro:regression:full:android
npm run maestro:regression:full:ios
npm run maestro:purchase:android
npm run maestro:auth:android
npm run maestro:deeplink:android
```

Reportes:

- Core: `reports/regression-core-android.xml` / `reports/regression-core-ios.xml`
- Full: `reports/regression-full-android.xml` / `reports/regression-full-ios.xml`
- Purchase: `reports/purchase-android.xml` / `reports/purchase-ios.xml`

## Modo sin checkout

Para mantener regression sin checkout:

```bash
INCLUDE_CHECKOUT_IN_REGRESSION=false npm run maestro:regression:android
npm run maestro:regression:core:android
```
