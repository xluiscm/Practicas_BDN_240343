# Anexo técnico — db_test_corregida

Fuente única: respaldo_5casostotalesfinal.sql. Se documenta el DDL; se excluyen los valores de las filas.

Inventario: 27 tablas, 225 campos y 33 claves foráneas.

## Tablas

- tb_buyer_orders: 9 campos
- tb_carts: 5 campos
- tb_logs: 9 campos
- tb_order_cancellations: 11 campos
- tb_payment_transactions: 7 campos
- tb_payments: 13 campos
- tb_people: 12 campos
- tb_products: 9 campos
- tb_refunds: 13 campos
- tb_returns: 13 campos
- tb_seller_orders: 8 campos
- tb_shipments: 12 campos
- tb_user_addresses: 12 campos
- tb_users: 8 campos
- tbc_categories: 7 campos
- tbc_payment_methods_types: 6 campos
- tbc_payment_methods_types_res: 4 campos
- tbd_address_components: 8 campos
- tbd_cancellation_items: 5 campos
- tbd_cart_items: 5 campos
- tbd_order_items: 8 campos
- tbd_orders: 9 campos
- tbd_products_categories: 5 campos
- tbd_return_items: 5 campos
- tbd_user_payment_methods: 11 campos
- tbd_users_offer_products: 8 campos
- tbd_wishlist_products: 3 campos

El diccionario HTML y campos.csv detallan tipos, nulabilidad, definiciones SQL y claves. El ERE Mermaid representa los atributos PK/FK y las relaciones declaradas.
