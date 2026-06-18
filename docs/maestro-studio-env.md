# Maestro Studio — variables de entorno

Maestro Studio **no lee** tu `.env` ni el `config.yaml` del repo. Por eso ves:

```text
Unable to launch app undefined
```

al ejecutar flows con `appId: ${APP_ID_ANDROID}`.

## Por qué falla `Unable to launch app undefined`

Las variables del panel **Env** de Studio aplican al flow que ejecutas, pero **no siempre llegan a los subflows** (`ensure-home.yaml`, `ensure-logged-in.yaml`, etc.). Por eso el padre puede hacer `clearState` bien y el hijo falla en `Launch app`.

**Fix en el repo:** todos los flows usan  
`appId: ${APP_ID_ANDROID || "com.enviaflores.android"}`  
para que los subflows arranquen aunque Studio no inyecte la variable.

Si el **login** falla en Studio (credenciales), usa:

```bash
npm run maestro:flow:android -- flows/regression/account/edit-profile.yaml
```

(ese comando sí carga tu `.env` completo).

## Solución (entorno Studio + defaults)

1. Abre **Maestro Studio** (desde terminal o IDE).
2. Haz clic en el icono **Env** (arriba en Studio).
3. **Manage Environments** → **Create** (ej. nombre `QA Android`).
4. Pega las variables de `maestro-studio.env.example` (o las generadas con el script abajo).
5. Asegúrate de que el entorno **QA Android** esté **seleccionado/activo** antes de dar **Run**.

### Variables obligatorias en Studio (catálogo / carrito)

| KEY | Ejemplo |
|-----|---------|
| `PRODUCT_SEARCH_TERM` | `rosas` |
| `PRODUCT_NAME` | `Clásico Amor con 24 Rosas Rojas` |
| `DEFAULT_STATE` | `Nuevo León` |
| `DEFAULT_CITY` | `Monterrey` |

Flows como `add-product-to-cart.yaml` y `address-book-add.yaml` requieren login QA (`USER_EMAIL` / `USER_PASSWORD`; fallback mailinator en el YAML para Studio).

### Variables obligatorias en Studio (login)

| KEY | Notas |
|-----|--------|
| `USER_EMAIL` | Cuenta QA mailinator / email |
| `USER_PASSWORD` | Password de esa cuenta |
| `GOOGLE_ACCOUNT_EMAIL` | Solo si usas fallback Google; debe coincidir con la cuenta del dispositivo |

Si falta `USER_EMAIL`, el subflow intentaba `qa.user@example.com` y luego **Google** con otra cuenta del emulador (lento y confuso).

| Key | Valor de referencia |
| --- | --- |
| `APP_ID_ANDROID` | `com.enviaflores.android` |
| `APP_ID_IOS` | `com.enviaflores.ios` |
| `USER_EMAIL` | tu cuenta QA en `.env` |
| `USER_PASSWORD` | tu password en `.env` |
| `DEFAULT_STATE` | `Nuevo León` |
| `DEFAULT_CITY` | `Monterrey` |
| `PRODUCT_SEARCH_TERM` | `rosas` |
| `PRODUCT_NAME` | nombre del producto en QA |
| `CATEGORY_NAME` | `Cumpleaños` |
| `DEEPLINK_HOME` | `enviaflores://` |

Copia el resto desde tu `.env` local (mismas claves que `.env.example`).

## Generar lista desde tu `.env`

```bash
npm run maestro:studio:env
```

Imprime pares `KEY=value` listos para copiar al panel **Env** de Studio.

## Ejecutar flows sin Studio

Los scripts npm sí cargan `.env` automáticamente:

```bash
npm run maestro:flow:android -- flows/regression/account/my-coupons.yaml
```

## Referencias

- [Environments and variables (Maestro Studio)](https://docs.maestro.dev/maestro-studio/environments-and-variables)
- `config.yaml` en la raíz: solo documentación / CLI; **Studio lo ignora**.
