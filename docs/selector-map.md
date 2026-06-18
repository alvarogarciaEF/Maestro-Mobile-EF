# Selector Map

Mapa inicial de selectores para estabilizar los flows Maestro de EnviaFlores mobile.

## Android

Selectores ya detectados en la ruta principal actual de `enviaflores/ef-storefront-android`:

| Pantalla/area | Selector Maestro | Fuente |
| --- | --- | --- |
| Activity principal | `id: "layout_main"` | `activity_main.xml` |
| Toolbar principal | `id: "main_toolbar"` | `activity_main.xml` |
| Bottom navigation | `id: "bottom_nav_view"` | `activity_main.xml` |
| Lista categorias | `id: "recyclerViewCategory"` | `fragment_category.xml` |
| Home location/date holder | `id: "location_date_holder"` | `fragment_home.xml` |
| Selector ciudad/estado | `id: "state_and_city_container"` | `fragment_home.xml` |
| Ciudad actual | `id: "txtViewCity"` | `fragment_home.xml` |
| Fecha entrega | `id: "textViewDate"` | `fragment_home.xml` |
| Busqueda toolbar | `id: "toolbar_search"` | `toolbar_main.xml` |
| Carrito toolbar | `id: "toolbar_shoppingcart"` | `toolbar_main.xml` |
| Busqueda producto input | `id: "search_product_input"` | `v3_search_product_layout.xml` |
| Catalogo productos | `id: "rcv_category_products"` | `fragment_category_detail_v3.xml` |
| Catalogo filtros | `id: "ll_filter_and_sort"` | `fragment_category_detail_v3.xml` |
| Catalogo filtros seleccionados | `id: "rcv_selected_filters"` | `fragment_category_detail_v3.xml` |
| Dialogo filtro menor a mayor | `id: "ll_min_to_max"` | `filters_dialog_v3.xml` |
| Dialogo filtro aplicar | `id: "apply_button"` | `filters_dialog_v3.xml` |
| Selector ciudad input | `id: "search_store_and_city_input"` | `layout_select_store_and_city.xml` |
| Login email input | `id: "loginEmailEditText"` | `v3_login_dialog_content.xml` |
| Login password input | `id: "loginPasswordEditText"` | `v3_login_dialog_content.xml` |
| Login submit | `id: "start_button"` | `v3_login_dialog_content.xml` |
| Detalle: imagenes | `id: "productImagesViewPager"` | `v3_product_detail_layout.xml` |
| Detalle: descripcion | `id: "productGeneralDescriptionHolder"` | `v3_product_detail_layout.xml` |
| Detalle: entrega | `id: "dateNdeliveryContainer"` | `v3_product_detail_layout.xml` |
| Detalle: agregar carrito | `id: "addToCartButton"` | `v3_product_detail_layout.xml` |
| Carrito | `id: "cl_shopping_cart"` | `fragment_shoppincart_v3.xml` |
| Carrito checkout | `id: "btn_continue_shoppig_container"` | `fragment_shoppincart_v3.xml` |
| Carrito incrementar | `id: "btn_plus_quantity"` | `row_shoppingcart_product_v3.xml` |
| Carrito decrementar | `id: "btn_minus_quantity"` | `row_shoppingcart_product_v3.xml` |
| Carrito eliminar | `id: "btn_delete"` | `row_shoppingcart_product_v3.xml` |
| Perfil nombre input | `id: "nameEditText"` | `edit_name_lastname_dialog.xml` |
| Perfil apellido input | `id: "lastnameEditText"` | `edit_name_lastname_dialog.xml` |
| Perfil guardar nombre | `id: "btn_save_cl"` | `edit_name_lastname_dialog.xml` |
| Direcciones vacias | `id: "empty_address_container"` | `fragment_my_address.xml` |
| Direcciones guardadas | `id: "address_container"` | `fragment_my_address.xml` |
| Lista direcciones guardadas | `id: "rcv_address_saved"` | `fragment_my_address.xml` |
| Pedidos | `id: "my_orders_fragment_compose_view"` | `fragment_my_orders.xml` |
| Checkout progreso | `id: "phone_progressbar"` | `v3_main_pay_process_layout.xml` |
| Checkout contenedor transaccion | `id: "transaction_container"` | `v3_main_pay_process_layout.xml` |
| Checkout continuar | `id: "continueProcessBtn"` | `v3_main_pay_process_layout.xml` |
| Pago tarjeta | `id: "ll_card_transaction"` | `pay_process_payment_methods_layout.xml` |
| Pago nueva tarjeta | `id: "ll_add_new_card"` | `pay_process_payment_methods_layout.xml` |
| Otros metodos de pago | `id: "ll_other_methods"` | `pay_process_payment_methods_layout.xml` |

Tambien existen `testTag` en pantallas Compose nuevas (`mainScreen`, `homeScreen`, `searchButton`, `cartButton`, `productDescription`, etc.). No se usan como selectores base en estos flows porque la ruta principal actual de `HomeActivity` sigue usando XML/fragments.

## iOS

En `enviaflores/ef-storefront-ios` no se detectaron `accessibilityIdentifier` existentes en la primera revision.

Para que los flows sean estables en iOS, conviene agregar identificadores equivalentes en SwiftUI:

| Area | Identificador sugerido |
| --- | --- |
| Root/Home | `homeScreen` |
| Busqueda | `searchButton` |
| Carrito | `cartButton` |
| Bottom navigation | `mainBottomNavigation` |
| Tab inicio | `Home` |
| Tab regalos | `Gifts` |
| Tab perfil | `Profile` |
| Resultados de busqueda | `searchResults` |
| Card de producto | `productCard` |
| Detalle: imagenes | `productImageCarousel` |
| Detalle: descripcion | `productDescription` |
| Detalle: entrega | `deliverySelection` |
| CTA agregar a carrito | `addToCartButton` |

## Pendientes Para Cerrar Placeholders

- Catalogo: agregar id estable a card de producto y contenedor de resultados para evitar depender de `PRODUCT_NAME`.
- iOS: agregar `accessibilityIdentifier` equivalentes a los ids Android de esta tabla.
- Checkout: confirmar textos finales de metodo de pago en ambiente QA antes de habilitarlo en CI.
