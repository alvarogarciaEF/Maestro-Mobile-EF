# Naming And Selectors

Convenciones para mantener legibles y estables los flows Maestro.

## Nombres De Archivos

- Usar `kebab-case`.
- El nombre debe describir una intencion de negocio concreta.
- Evitar nombres genericos como `test.yaml`, `flow1.yaml` o `happy-path.yaml`.
- Preferir verbo + objeto cuando aplique:
  - `search-product.yaml`
  - `add-product-to-cart.yaml`
  - `checkout-payment-entry.yaml`

## Ubicacion

- `flows/smoke/`: pruebas criticas y rapidas.
- `flows/regression/<dominio>/`: escenarios funcionales por dominio.
- `flows/reusable/`: pasos compartidos sin intencion de negocio completa.
- `flows/utils/`: acciones tecnicas como limpiar estado.

## Tags

Cada flow ejecutable debe incluir tags utiles para filtrado futuro:

```yaml
tags:
  - regression
  - cart
```

Tags recomendados:

- Tipo: `smoke`, `regression`, `utility`
- Dominio: `catalog`, `cart`, `checkout`, `account`, `login`, `location`, `deeplink`
- Rasgo opcional: `search`, `payment`, `filter`, `address`

## Comentarios Iniciales

Cada YAML debe iniciar con comentarios claros:

```yaml
# Proposito: que valida o documenta este archivo.
# Precondiciones: estado, datos o ambiente necesarios.
# Valida/Nota: resultado esperado, restriccion o punto de corte.
```

## Selectores

Prioridad para interactuar con UI:

1. `id`: preferido para controles estables.
2. `text`: aceptable para copy estable de negocio o navegacion.
3. Coordenadas: evitar salvo bloqueo temporal y documentar por que.

Ejemplo preferido:

```yaml
- tapOn:
    id: "toolbar_search"
```

Ejemplo aceptable:

```yaml
- tapOn:
    text: "Mi cuenta"
```

## Variables

- Toda variable `${VARIABLE}` usada en flows debe existir en `.env.example`.
- Usar mayusculas y snake case.
- Poner comillas en `.env.example` cuando el valor tenga espacios:

```env
DEFAULT_STATE="Nuevo León"
PRODUCT_NAME="Clásico Amor con 24 Rosas Rojas"
```

## Seguridad De Pago

- No usar `tapOn` sobre acciones finales de pago.
- Es aceptable usar `assertVisible` para validar que se llego a pantalla de pago.
- Todo flow de checkout debe incluir comentario de punto de corte si se acerca al pago.

Ejemplo aceptable:

```yaml
# Nota: se detiene en la pantalla de pago antes de confirmar compra.
- assertVisible:
    text: "Pagar y completar compra"
```

## Reusables

- No lanzar app dentro de reusables salvo que el objetivo del reusable lo requiera.
- Deben ser idempotentes cuando sea posible.
- Si cierran modales o permisos, usar `runFlow.when`.
- Mantenerlos chicos y con una sola responsabilidad.

## Datos De Prueba

- Credenciales reales van en `.env` local o GitHub Secrets.
- `data/*.yaml` documenta defaults y escenarios dummy.
- No versionar tarjetas, direcciones reales, telefonos reales o datos personales productivos.
