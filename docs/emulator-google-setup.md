# Configurar cuenta Google en el emulador Android (AVD)

Los flujos **smoke login** y **account** usan `login-valid-user.yaml`, que inicia sesión con **Continuar con Google**. Eso requiere una cuenta Google real registrada en el emulador, no solo variables en `.env`.

## Requisitos

| Variable | Uso |
|----------|-----|
| `GOOGLE_ACCOUNT_EMAIL` | Debe coincidir con la cuenta Google **agregada al AVD** (Gmail o Google Workspace). Maestro la selecciona en el picker. |
| `USER_EMAIL` / `USER_PASSWORD` | Login por correo en la app (auth regression, fallback en account). Puede ser distinto (ej. Mailinator). |

**Importante:** `enviafloresQA@mailinator.com` sirve para login email/password, pero **no** se puede agregar como cuenta Google en Android. Para Google necesitas un `@gmail.com` o cuenta Workspace (ej. `alvaro.garcia@enviaflores.com`).

## Setup manual (una vez por AVD)

1. Arranca el emulador:
   ```bash
   export ANDROID_HOME="$HOME/Library/Android/sdk"
   "$ANDROID_HOME/emulator/emulator" -avd Pixel_9 &
   ```

2. Abre ajustes de cuentas (o usa el script del repo):
   ```bash
   npm run emulator:google-setup
   ```

3. En el emulador:
   - **Settings → Passwords & accounts → Add account → Google**
   - Inicia sesión con la cuenta QA que pondrás en `GOOGLE_ACCOUNT_EMAIL`
   - Completa verificación si Google la pide

4. Verifica:
   ```bash
   npm run emulator:google-check
   ```

5. Actualiza `.env`:
   ```env
   GOOGLE_ACCOUNT_EMAIL=tu-cuenta-google-real@enviaflores.com
   USER_EMAIL=enviafloresQA@mailinator.com
   USER_PASSWORD=...
   ```

## Persistencia

- **Reinicio normal:** la cuenta suele conservarse.
- **`emulator -wipe-data`:** borra la cuenta; hay que repetir este setup.
- **Snapshot del AVD:** puedes guardar un snapshot con la cuenta ya configurada para no repetir el paso manual.

## Validación con Maestro

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"

npm run emulator:google-check
npm run maestro:flow:android -- flows/smoke/login.yaml
npm run maestro:account:android
```

## Troubleshooting

| Síntoma | Causa probable | Acción |
|---------|----------------|--------|
| Picker Google vacío | Sin cuenta en el AVD | Repetir setup manual |
| Maestro no encuentra el email | `GOOGLE_ACCOUNT_EMAIL` ≠ cuenta del dispositivo | Alinear `.env` con la cuenta agregada |
| Login smoke falla tras wipe | Datos del emulador borrados | Reinstalar app + volver a agregar Google |
| Account falla pero auth pasa | Solo email/password funciona | Configurar Google o revisar fallback en `ensure-logged-in.yaml` |
| Se activa stylus / handwriting | Gboard o Extended controls del emulador | `npm run emulator:disable-stylus`; no uses el icono de lapiz en el AVD |
