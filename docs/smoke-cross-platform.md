# Smoke Cross-Platform

Guia para ejecutar smoke en Android e iOS con los mismos flows YAML.

## Requisitos

- Maestro CLI instalado.
- Android: emulador/dispositivo + APK QA instalado.
- iOS: simulador macOS + app QA instalada.
- `.env` con `APP_ID_ANDROID`, `APP_ID_IOS`, credenciales y ciudad.

## Comando unificado

```bash
npm run maestro:smoke:cross-platform
```

Ejecuta en secuencia:

1. `npm run maestro:smoke:android` -> `reports/smoke-android.xml`
2. `npm run maestro:smoke:ios` -> `reports/smoke-ios.xml`

## Smoke incluido

- `launch-app`
- `home`
- `select-city`
- `login`
- `empty-cart`
- `deeplink-home`

## Notas iOS

Los flows comparten YAML y mapean `APP_ID_IOS` a `APP_ID_ANDROID` en runtime iOS.

Para estabilidad iOS, prioriza `accessibilityIdentifier` equivalentes a Android (ver `docs/ios-accessibility-ids.md`).

## Criterio de salida sugerido

- Pass rate >= 95% en 10 corridas consecutivas por plataforma.
- Sin flakes bloqueantes en login, home y deeplink-home.
