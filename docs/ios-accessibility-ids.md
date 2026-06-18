# iOS Accessibility IDs

Lista sugerida para instrumentar `enviaflores/ef-storefront-ios` con `accessibilityIdentifier` y poder reutilizar los flows Maestro en iOS con menos dependencia de texto visible.

## Prioridad 1 - Smoke

| Pantalla/area | Identifier sugerido | Uso |
| --- | --- | --- |
| Root app/home | `layout_main` | Validar arranque |
| Toolbar principal | `main_toolbar` | Validar chrome principal |
| Bottom navigation | `bottom_nav_view` | Navegacion base |
| Home location/date holder | `location_date_holder` | Smoke home |
| Selector ciudad/estado | `state_and_city_container` | Cambio de ciudad |
| Busqueda toolbar | `toolbar_search` | Entrada a busqueda |
| Carrito toolbar | `toolbar_shoppingcart` | Entrada a carrito |
| Tab inicio | `tab_home` | Volver a home |
| Tab categorias | `tab_categories` | Navegar a categorias |
| Tab cuenta | `tab_account` | Login/cuenta |

## Prioridad 2 - Login Y Cuenta

| Pantalla/area | Identifier sugerido |
| --- | --- |
| Login email input | `loginEmailEditText` |
| Login password input | `loginPasswordEditText` |
| Login submit | `start_button` |
| Perfil nombre input | `nameEditText` |
| Perfil apellido input | `lastnameEditText` |
| Perfil guardar nombre | `btn_save_cl` |
| Pedidos | `my_orders_fragment_compose_view` |
| Direcciones vacias | `empty_address_container` |
| Direcciones guardadas | `address_container` |
| Lista direcciones guardadas | `rcv_address_saved` |

## Prioridad 3 - Catalogo Y Carrito

| Pantalla/area | Identifier sugerido |
| --- | --- |
| Busqueda producto input | `search_product_input` |
| Lista categorias | `recyclerViewCategory` |
| Catalogo productos | `rcv_category_products` |
| Card de producto | `productCard` |
| Detalle imagenes | `productImagesViewPager` |
| Detalle descripcion | `productGeneralDescriptionHolder` |
| Detalle entrega | `dateNdeliveryContainer` |
| Detalle agregar carrito | `addToCartButton` |
| Carrito | `cl_shopping_cart` |
| Carrito checkout | `btn_continue_shoppig_container` |
| Carrito incrementar | `btn_plus_quantity` |
| Carrito decrementar | `btn_minus_quantity` |
| Carrito eliminar | `btn_delete` |

## Prioridad 4 - Checkout

| Pantalla/area | Identifier sugerido |
| --- | --- |
| Checkout progreso | `phone_progressbar` |
| Checkout contenedor transaccion | `transaction_container` |
| Checkout continuar | `continueProcessBtn` |
| Pago tarjeta | `ll_card_transaction` |
| Pago nueva tarjeta | `ll_add_new_card` |
| Otros metodos de pago | `ll_other_methods` |

## Ejemplo SwiftUI

```swift
Button(action: onSearch) {
    Image(systemName: "magnifyingglass")
}
.accessibilityIdentifier("toolbar_search")
```

## Criterios

- Mantener identifiers en ingles tecnico o snake/camel case estable, sin copy visible.
- No incluir datos dinamicos como nombre de producto, precio, usuario o ciudad dentro del identifier.
- Preferir identifiers iguales a Android cuando representen el mismo concepto funcional.
- Agregar identifiers en contenedores importantes y controles accionables.
