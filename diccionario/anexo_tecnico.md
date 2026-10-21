# Anexo técnico — db_test

Fuente única: `Practica03/backups/21102026.sql`. Se copian definiciones de esquema; se excluyen INSERT y cualquier valor de fila. Los bloques siguientes son **definiciones comprobadas**, transcritas del respaldo.

## Tablas

```sql
CREATE TABLE `tb_buyer_orders` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(40) NOT NULL,
  `user_ID` int NOT NULL,
  `total_products` int NOT NULL,
  `total_cost` decimal(10,3) NOT NULL DEFAULT '0.000',
  `status_string` enum('Registered','Wishlist','Payed','Canceled','Delivered','Devolved','Attended','Sended') NOT NULL DEFAULT 'Registered',
  `status` bit(1) DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_user_2_idx` (`user_ID`),
  CONSTRAINT `fk_user_2` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_carts` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int NOT NULL,
  `status` enum('Active','Converted','Abandoned') NOT NULL DEFAULT 'Active',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_cart_user` (`user_ID`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_logs` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL,
  `table_operation` enum('Create','Read','Update','Delete') NOT NULL,
  `db_user` varchar(80) NOT NULL,
  `description` text NOT NULL,
  `operation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `operation_status` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=14669 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_payment_transactions` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_ID` int unsigned NOT NULL,
  `event_type` enum('Created','Authorized','Captured','Failed','Refunded','PartiallyRefunded','Voided') NOT NULL,
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `event_reference` varchar(150) DEFAULT NULL,
  `remarks` text,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_payment_event_reference` (`event_reference`),
  KEY `idx_payment_transactions_payment` (`payment_ID`),
  CONSTRAINT `fk_payment_transaction_payment` FOREIGN KEY (`payment_ID`) REFERENCES `tb_payments` (`ID`),
  CONSTRAINT `chk_payment_transaction_amount` CHECK ((`amount` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_payments` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'MXN',
  `payment_method` enum('Card','SPEI','Transfer','Cash','Other') NOT NULL,
  `provider` varchar(50) DEFAULT NULL,
  `provider_reference` varchar(150) DEFAULT NULL,
  `idempotency_key` varchar(100) DEFAULT NULL,
  `payment_status` enum('Pending','Authorized','Paid','Failed','Refunded','PartiallyRefunded') NOT NULL DEFAULT 'Pending',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid_date` datetime DEFAULT NULL,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_payment_provider_reference` (`provider`,`provider_reference`),
  UNIQUE KEY `uk_payment_idempotency` (`idempotency_key`),
  KEY `idx_payments_order` (`order_ID`),
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `chk_payment_amount` CHECK ((`amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_products` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `SKU` varchar(50) NOT NULL,
  `name` varchar(250) NOT NULL,
  `description` text,
  `current_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `current_stock` int unsigned NOT NULL DEFAULT '0',
  `status` bit(1) DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `SKU` (`SKU`)
) ENGINE=InnoDB AUTO_INCREMENT=5018 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_seller_orders` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `order_ID` int unsigned NOT NULL,
  `seller_ID` int NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `shipping_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `fulfillment_status` enum('Pending','Accepted','Preparing','Sent','Delivered','Canceled','Returned') NOT NULL DEFAULT 'Pending',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_order_seller` (`order_ID`,`seller_ID`),
  KEY `idx_seller_orders_seller` (`seller_ID`),
  CONSTRAINT `fk_seller_order_order` FOREIGN KEY (`order_ID`) REFERENCES `tb_buyer_orders` (`ID`),
  CONSTRAINT `fk_seller_order_seller` FOREIGN KEY (`seller_ID`) REFERENCES `tb_users` (`ID`),
  CONSTRAINT `chk_seller_order_shipping` CHECK ((`shipping_cost` >= 0)),
  CONSTRAINT `chk_seller_order_subtotal` CHECK ((`subtotal` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tb_users` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `email` varchar(80) NOT NULL,
  `nick` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `nickname` (`nick`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbc_categories` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `description` text,
  `sup_id_category` int unsigned DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `name` (`name`),
  KEY `fk_superior_category` (`sup_id_category`),
  CONSTRAINT `fk_superior_category` FOREIGN KEY (`sup_id_category`) REFERENCES `tbc_categories` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbc_payment_methods_types` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `description` text NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `code_UNIQUE` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbd_cart_items` (
  `cart_ID` int unsigned NOT NULL,
  `product_offer_ID` int unsigned NOT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_ID`,`product_offer_ID`),
  KEY `idx_cart_item_offer` (`product_offer_ID`),
  CONSTRAINT `fk_cart_item_cart` FOREIGN KEY (`cart_ID`) REFERENCES `tb_carts` (`ID`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_item_offer` FOREIGN KEY (`product_offer_ID`) REFERENCES `tbd_users_offer_products` (`product_offer_ID`),
  CONSTRAINT `chk_cart_item_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbd_order_items` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `seller_order_ID` int unsigned NOT NULL,
  `product_offer_ID` int unsigned NOT NULL,
  `product_name` varchar(250) NOT NULL,
  `quantity` int unsigned NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `subtotal` decimal(14,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_order_items_seller_order` (`seller_order_ID`),
  KEY `idx_order_items_offer` (`product_offer_ID`),
  CONSTRAINT `fk_order_item_offer` FOREIGN KEY (`product_offer_ID`) REFERENCES `tbd_users_offer_products` (`product_offer_ID`),
  CONSTRAINT `fk_order_item_seller_order` FOREIGN KEY (`seller_order_ID`) REFERENCES `tb_seller_orders` (`ID`),
  CONSTRAINT `chk_order_item_price` CHECK ((`unit_price` >= 0)),
  CONSTRAINT `chk_order_item_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbd_orders` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(40) NOT NULL,
  `total_products` int NOT NULL,
  `total_cost` decimal(10,3) NOT NULL DEFAULT '0.000',
  `status_string` enum('Registered','Attend','Canceled','Whistlist','Payed','Delivered','Devolved','Sended') DEFAULT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime DEFAULT NULL,
  `last_update` datetime DEFAULT NULL,
  `User_ID` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbd_products_categories` (
  `category_ID` int unsigned NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_ID`,`product_ID`),
  KEY `fk_product` (`product_ID`),
  CONSTRAINT `fk_category` FOREIGN KEY (`category_ID`) REFERENCES `tbc_categories` (`ID`),
  CONSTRAINT `fk_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbd_users_offer_products` (
  `product_offer_ID` int unsigned NOT NULL AUTO_INCREMENT,
  `user_ID` int unsigned DEFAULT NULL,
  `product_ID` int unsigned NOT NULL,
  `available_stock` int NOT NULL DEFAULT '1',
  `status` bit(1) NOT NULL DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `available_date` datetime DEFAULT NULL,
  `last_update` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_offer_ID`),
  KEY `fk_user_1` (`user_ID`),
  KEY `fk_product_2` (`product_ID`),
  CONSTRAINT `fk_product_2` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

```sql
CREATE TABLE `tbd_wishlist_products` (
  `user_ID` int NOT NULL,
  `product_ID` int unsigned NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_ID`,`product_ID`),
  KEY `idx_wishlist_product` (`product_ID`),
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_ID`) REFERENCES `tb_products` (`ID`),
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_ID`) REFERENCES `tb_users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

## Vistas

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_total_products_by_category` AS with recursive `categoryhierarchy` as (select `tbc_categories`.`ID` AS `category_ID`,cast(`tbc_categories`.`name` as char(500) charset utf8mb4) AS `category_path`,1 AS `category_level` from `tbc_categories` where (`tbc_categories`.`sup_id_category` is null) union all select `c`.`ID` AS `category_ID`,concat(`h`.`category_path`,' -> ',`c`.`name`) AS `category_path`,(`h`.`category_level` + 1) AS `category_level` from (`tbc_categories` `c` join `categoryhierarchy` `h` on((`c`.`sup_id_category` = `h`.`category_ID`)))) select `ch`.`category_ID` AS `category_ID`,`ch`.`category_path` AS `category_path`,`ch`.`category_level` AS `category_level`,count(`pc`.`product_ID`) AS `total_products`,sum((case when (`pc`.`status` = 1) then 1 else 0 end)) AS `total_active_products`,sum((case when (`pc`.`status` = 0) then 1 else 0 end)) AS `total_inactive_products`,0 AS `total_uncategorized_products` from (`categoryhierarchy` `ch` left join `tbd_products_categories` `pc` on((`ch`.`category_ID` = `pc`.`category_ID`))) group by `ch`.`category_ID`,`ch`.`category_path`,`ch`.`category_level` union all select NULL AS `category_ID`,'Sin categoría' AS `category_path`,0 AS `category_level`,count(`p`.`ID`) AS `total_products`,sum((case when (`p`.`status` = 1) then 1 else 0 end)) AS `total_active_products`,sum((case when (`p`.`status` = 0) then 1 else 0 end)) AS `total_inactive_products`,count(`p`.`ID`) AS `total_uncategorized_products` from (`tb_products` `p` left join `tbd_products_categories` `pc` on((`p`.`ID` = `pc`.`product_ID`))) where (`pc`.`product_ID` is null) */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_buyer_orders` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `buyer_order_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_buyer_orders') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_carts` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `cart_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_carts') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_carts_items` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,'cart_ID=',-(1)),',',1) as unsigned) AS `cart_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_cart_items') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_categorias` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `category_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_categories') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_order_items` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `order_item_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_order_items') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_payment_methods_types` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `payment_method_type_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbc_payment_methods_types') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_payment_transactions` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `payment_transaction_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_payment_transactions') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_payments` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `payment_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_payments') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_productos` AS select `p`.`ID` AS `id`,`p`.`name` AS `name`,`p`.`description` AS `description`,`b`.`db_user` AS `inserted_by`,coalesce(group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', '),'Sin rol') AS `roles`,`b`.`description` AS `operation_description`,`b`.`operation_date` AS `operation_date` from ((`tb_products` `p` join `tb_logs` `b` on((`b`.`description` like concat('%ID=',`p`.`ID`,',%')))) left join `mysql`.`role_edges` `re` on((`re`.`TO_USER` = substring_index(`b`.`db_user`,'@',1)))) where ((`b`.`table_operation` = 'Create') and (`b`.`table_name` = 'tb_products')) group by `p`.`ID`,`p`.`name`,`p`.`description`,`b`.`db_user`,`b`.`description`,`b`.`operation_date` */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_seller_orders` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,' ID=',-(1)),',',1) as unsigned) AS `seller_order_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tb_seller_orders') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_users_offer_products` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,'product_offer_ID=',-(1)),',',1) as unsigned) AS `product_offer_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_users_offer_products') */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_usuarios` AS select `l`.`ID` AS `ID`,`l`.`table_name` AS `table_name`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,`l`.`description` AS `description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where ((`l`.`table_name` = 'tb_users') and (`l`.`operation_status` = 0x01)) */;
```

```sql
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_trazabilidad_wishlist_products` AS select `l`.`ID` AS `log_id`,cast(substring_index(substring_index(`l`.`description`,'user_ID=',-(1)),',',1) as unsigned) AS `user_id`,`l`.`table_operation` AS `operation`,`l`.`db_user` AS `db_user`,substring_index(`l`.`db_user`,'@',1) AS `username`,coalesce((select group_concat(distinct `re`.`FROM_USER` order by `re`.`FROM_USER` ASC separator ', ') from `mysql`.`role_edges` `re` where (`re`.`TO_USER` = substring_index(`l`.`db_user`,'@',1))),'Sin rol asignado') AS `roles`,`l`.`description` AS `operation_description`,`l`.`operation_date` AS `operation_date`,`l`.`operation_status` AS `operation_status` from `tb_logs` `l` where (`l`.`table_name` = 'tbd_wishlist_products') */;
```

## Triggers

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_buyer_orders_after_insert` AFTER INSERT ON `tb_buyer_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_buyer_orders',
        'Create',
        USER(),
        CONCAT(
            'Orden de compra creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', key=', COALESCE(NEW.key, 'NULL'),
            ', user_ID=', COALESCE(NEW.user_ID, 'NULL'),
            ', total_products=', COALESCE(NEW.total_products, 'NULL'),
            ', total_cost=', COALESCE(NEW.total_cost, 'NULL'),
            ', status_string=', COALESCE(NEW.status_string, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_buyer_orders_after_update` AFTER UPDATE ON `tb_buyer_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_buyer_orders',
        'Update',
        USER(),
        CONCAT(
            'Orden de compra actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.user_ID <=> NEW.user_ID),
                    CONCAT('user_ID: [', COALESCE(OLD.user_ID, 'NULL'), '] -> [', COALESCE(NEW.user_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.total_products <=> NEW.total_products),
                    CONCAT('total_products: [', COALESCE(OLD.total_products, 'NULL'), '] -> [', COALESCE(NEW.total_products, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.total_cost <=> NEW.total_cost),
                    CONCAT('total_cost: [', COALESCE(OLD.total_cost, 'NULL'), '] -> [', COALESCE(NEW.total_cost, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status_string <=> NEW.status_string),
                    CONCAT('status_string: [', COALESCE(OLD.status_string, 'NULL'), '] -> [', COALESCE(NEW.status_string, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status <=> NEW.status),
                    CONCAT('status: [', COALESCE(OLD.status + 0, 'NULL'), '] -> [', COALESCE(NEW.status + 0, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_buyer_orders_after_delete` AFTER DELETE ON `tb_buyer_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_buyer_orders',
        'Delete',
        USER(),
        CONCAT(
            'Orden de compra eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', key=', COALESCE(OLD.key, 'NULL'),
            ', user_ID=', COALESCE(OLD.user_ID, 'NULL'),
            ', total_products=', COALESCE(OLD.total_products, 'NULL'),
            ', total_cost=', COALESCE(OLD.total_cost, 'NULL'),
            ', status_string=', COALESCE(OLD.status_string, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_carts_after_insert` AFTER INSERT ON `tb_carts` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_carts',
        'Create',
        USER(),
        CONCAT(
            'Carrito creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', user_ID=', COALESCE(NEW.user_ID, 'NULL'),
            ', status=', COALESCE(NEW.status, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_carts_after_update` AFTER UPDATE ON `tb_carts` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_carts',
        'Update',
        USER(),
        CONCAT(
            'Carrito actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.user_ID <=> NEW.user_ID),
                    CONCAT('user_ID: [', COALESCE(OLD.user_ID, 'NULL'), '] -> [', COALESCE(NEW.user_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status <=> NEW.status),
                    CONCAT('status: [', COALESCE(OLD.status, 'NULL'), '] -> [', COALESCE(NEW.status, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_carts_after_delete` AFTER DELETE ON `tb_carts` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_carts',
        'Delete',
        USER(),
        CONCAT(
            'Carrito eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', user_ID=', COALESCE(OLD.user_ID, 'NULL'),
            ', status=', COALESCE(OLD.status, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payment_transactions_after_insert` AFTER INSERT ON `tb_payment_transactions` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_payment_transactions',
        'Create',
        USER(),
        CONCAT(
            'Transacción de pago creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', payment_ID=', COALESCE(NEW.payment_ID, 'NULL'),
            ', event_type=', COALESCE(NEW.event_type, 'NULL'),
            ', amount=', COALESCE(NEW.amount, 'NULL'),
            ', event_reference=', COALESCE(NEW.event_reference, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payment_transactions_after_update` AFTER UPDATE ON `tb_payment_transactions` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_payment_transactions',
        'Update',
        USER(),
        CONCAT(
            'Transacción de pago actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.payment_ID <=> NEW.payment_ID),
                    CONCAT('payment_ID: [', COALESCE(OLD.payment_ID, 'NULL'), '] -> [', COALESCE(NEW.payment_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.event_type <=> NEW.event_type),
                    CONCAT('event_type: [', COALESCE(OLD.event_type, 'NULL'), '] -> [', COALESCE(NEW.event_type, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.amount <=> NEW.amount),
                    CONCAT('amount: [', COALESCE(OLD.amount, 'NULL'), '] -> [', COALESCE(NEW.amount, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.event_reference <=> NEW.event_reference),
                    CONCAT('event_reference: [', COALESCE(OLD.event_reference, 'NULL'), '] -> [', COALESCE(NEW.event_reference, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payment_transactions_after_delete` AFTER DELETE ON `tb_payment_transactions` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_payment_transactions',
        'Delete',
        USER(),
        CONCAT(
            'Transacción de pago eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', payment_ID=', COALESCE(OLD.payment_ID, 'NULL'),
            ', event_type=', COALESCE(OLD.event_type, 'NULL'),
            ', amount=', COALESCE(OLD.amount, 'NULL'),
            ', event_reference=', COALESCE(OLD.event_reference, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payments_after_insert` AFTER INSERT ON `tb_payments` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_payments',
        'Create',
        USER(),
        CONCAT(
            'Pago creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', order_ID=', COALESCE(NEW.order_ID, 'NULL'),
            ', amount=', COALESCE(NEW.amount, 'NULL'),
            ', currency=', COALESCE(NEW.currency, 'NULL'),
            ', payment_method=', COALESCE(NEW.payment_method, 'NULL'),
            ', payment_status=', COALESCE(NEW.payment_status, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payments_after_update` AFTER UPDATE ON `tb_payments` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_payments',
        'Update',
        USER(),
        CONCAT(
            'Pago actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.order_ID <=> NEW.order_ID),
                    CONCAT('order_ID: [', COALESCE(OLD.order_ID, 'NULL'), '] -> [', COALESCE(NEW.order_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.amount <=> NEW.amount),
                    CONCAT('amount: [', COALESCE(OLD.amount, 'NULL'), '] -> [', COALESCE(NEW.amount, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.currency <=> NEW.currency),
                    CONCAT('currency: [', COALESCE(OLD.currency, 'NULL'), '] -> [', COALESCE(NEW.currency, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.payment_method <=> NEW.payment_method),
                    CONCAT('payment_method: [', COALESCE(OLD.payment_method, 'NULL'), '] -> [', COALESCE(NEW.payment_method, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.provider <=> NEW.provider),
                    CONCAT('provider: [', COALESCE(OLD.provider, 'NULL'), '] -> [', COALESCE(NEW.provider, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.provider_reference <=> NEW.provider_reference),
                    CONCAT('provider_reference: [', COALESCE(OLD.provider_reference, 'NULL'), '] -> [', COALESCE(NEW.provider_reference, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.payment_status <=> NEW.payment_status),
                    CONCAT('payment_status: [', COALESCE(OLD.payment_status, 'NULL'), '] -> [', COALESCE(NEW.payment_status, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.paid_date <=> NEW.paid_date),
                    CONCAT('paid_date: [', COALESCE(OLD.paid_date, 'NULL'), '] -> [', COALESCE(NEW.paid_date, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_payments_after_delete` AFTER DELETE ON `tb_payments` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_payments',
        'Delete',
        USER(),
        CONCAT(
            'Pago eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', order_ID=', COALESCE(OLD.order_ID, 'NULL'),
            ', amount=', COALESCE(OLD.amount, 'NULL'),
            ', currency=', COALESCE(OLD.currency, 'NULL'),
            ', payment_method=', COALESCE(OLD.payment_method, 'NULL'),
            ', payment_status=', COALESCE(OLD.payment_status, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_products_after_insert` AFTER INSERT ON `tb_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tb_products',
        'Create',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Producto creado. ID=', NEW.ID,
            ', SKU=', NEW.SKU,
            ', nombre=', NEW.name
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_products_after_update` AFTER UPDATE ON `tb_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tb_products',
        'Update',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Producto actualizado. ID=', NEW.ID,
            ', SKU=', NEW.SKU,
            ', nombre=', NEW.name
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_products_after_delete` AFTER DELETE ON `tb_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tb_products',
        'Delete',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Producto eliminado. ID=', OLD.ID,
            ', SKU=', OLD.SKU,
            ', nombre=', OLD.name
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_seller_orders_after_insert` AFTER INSERT ON `tb_seller_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_seller_orders',
        'Create',
        USER(),
        CONCAT(
            'Orden de vendedor creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', order_ID=', COALESCE(NEW.order_ID, 'NULL'),
            ', seller_ID=', COALESCE(NEW.seller_ID, 'NULL'),
            ', subtotal=', COALESCE(NEW.subtotal, 'NULL'),
            ', shipping_cost=', COALESCE(NEW.shipping_cost, 'NULL'),
            ', fulfillment_status=', COALESCE(NEW.fulfillment_status, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_seller_orders_after_update` AFTER UPDATE ON `tb_seller_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_seller_orders',
        'Update',
        USER(),
        CONCAT(
            'Orden de vendedor actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.order_ID <=> NEW.order_ID),
                    CONCAT('order_ID: [', COALESCE(OLD.order_ID, 'NULL'), '] -> [', COALESCE(NEW.order_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.seller_ID <=> NEW.seller_ID),
                    CONCAT('seller_ID: [', COALESCE(OLD.seller_ID, 'NULL'), '] -> [', COALESCE(NEW.seller_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.subtotal <=> NEW.subtotal),
                    CONCAT('subtotal: [', COALESCE(OLD.subtotal, 'NULL'), '] -> [', COALESCE(NEW.subtotal, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.shipping_cost <=> NEW.shipping_cost),
                    CONCAT('shipping_cost: [', COALESCE(OLD.shipping_cost, 'NULL'), '] -> [', COALESCE(NEW.shipping_cost, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.fulfillment_status <=> NEW.fulfillment_status),
                    CONCAT('fulfillment_status: [', COALESCE(OLD.fulfillment_status, 'NULL'), '] -> [', COALESCE(NEW.fulfillment_status, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_seller_orders_after_delete` AFTER DELETE ON `tb_seller_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_seller_orders',
        'Delete',
        USER(),
        CONCAT(
            'Orden de vendedor eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', order_ID=', COALESCE(OLD.order_ID, 'NULL'),
            ', seller_ID=', COALESCE(OLD.seller_ID, 'NULL'),
            ', subtotal=', COALESCE(OLD.subtotal, 'NULL'),
            ', shipping_cost=', COALESCE(OLD.shipping_cost, 'NULL'),
            ', fulfillment_status=', COALESCE(OLD.fulfillment_status, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_after_insert` AFTER INSERT ON `tb_users` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_users',
        'Create',
        USER(),
        CONCAT(
            'Usuario creado. ID=', NEW.ID,
            ', email=', NEW.email,
            ', nickname=', NEW.nick
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_after_update` AFTER UPDATE ON `tb_users` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_users',
        'Update',
        USER(),
        CONCAT(
            'Usuario creado. ID=', NEW.ID,
            ', email=', NEW.email,
            ', nickname=', NEW.nick
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_after_delete` AFTER DELETE ON `tb_users` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tb_users',
        'Delete',
        USER(),
        CONCAT(
            'Usuario creado. ID=', OLD.ID,
            ', email=', OLD.email,
            ', nickname=', OLD.nick
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbc_categories_after_insert` AFTER INSERT ON `tbc_categories` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tbc_categories',
        'Create',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Categoría creada. ID=', NEW.ID,
            ', nombre=', NEW.name
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbc_categories_after_update` AFTER UPDATE ON `tbc_categories` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tbc_categories',
        'Update',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Categoría actualizada. ID=', NEW.ID,
            ', nombre antiguo=', OLD.name, ', nombre nuevo=', NEW.name,
            ', estado antiguo=', OLD.status, ', estado nuevo=', NEW.status
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbc_categories_after_delete` AFTER DELETE ON `tbc_categories` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tbc_categories',
        'Delete',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Categoría eliminada. ID=', OLD.ID,
            ', nombre=', OLD.name
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbc_payment_methods_types_after_insert` AFTER INSERT ON `tbc_payment_methods_types` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbc_payment_methods_types',
        'Create',
        USER(),
        CONCAT(
            'Tipo de método de pago creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', code=', COALESCE(NEW.code, 'NULL'),
            ', status=', COALESCE(NEW.status + 0, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbc_payment_methods_types_after_update` AFTER UPDATE ON `tbc_payment_methods_types` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbc_payment_methods_types',
        'Update',
        USER(),
        CONCAT(
            'Tipo de método de pago actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.code <=> NEW.code),
                    CONCAT('code: [', COALESCE(OLD.code, 'NULL'), '] -> [', COALESCE(NEW.code, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status <=> NEW.status),
                    CONCAT('status: [', COALESCE(OLD.status + 0, 'NULL'), '] -> [', COALESCE(NEW.status + 0, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbc_payment_methods_types_after_delete` AFTER DELETE ON `tbc_payment_methods_types` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbc_payment_methods_types',
        'Delete',
        USER(),
        CONCAT(
            'Tipo de método de pago eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', code=', COALESCE(OLD.code, 'NULL'),
            ', status=', COALESCE(OLD.status + 0, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_cart_items_after_insert` AFTER INSERT ON `tbd_cart_items` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_cart_items',
        'Create',
        USER(),
        CONCAT(
            'Ítem de carrito creado. cart_ID=', COALESCE(NEW.cart_ID, 'NULL'),
            ', product_offer_ID=', COALESCE(NEW.product_offer_ID, 'NULL'),
            ', quantity=', COALESCE(NEW.quantity, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_cart_items_after_update` AFTER UPDATE ON `tbd_cart_items` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_cart_items',
        'Update',
        USER(),
        CONCAT(
            'Ítem de carrito actualizado. cart_ID=', COALESCE(NEW.cart_ID, 'NULL'),
            ', product_offer_ID=', COALESCE(NEW.product_offer_ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.quantity <=> NEW.quantity),
                    CONCAT('quantity: [', COALESCE(OLD.quantity, 'NULL'), '] -> [', COALESCE(NEW.quantity, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_cart_items_after_delete` AFTER DELETE ON `tbd_cart_items` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_cart_items',
        'Delete',
        USER(),
        CONCAT(
            'Ítem de carrito eliminado. cart_ID=', COALESCE(OLD.cart_ID, 'NULL'),
            ', product_offer_ID=', COALESCE(OLD.product_offer_ID, 'NULL'),
            ', quantity=', COALESCE(OLD.quantity, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_order_items_after_insert` AFTER INSERT ON `tbd_order_items` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_order_items',
        'Create',
        USER(),
        CONCAT(
            'Ítem de orden creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', seller_order_ID=', COALESCE(NEW.seller_order_ID, 'NULL'),
            ', product_offer_ID=', COALESCE(NEW.product_offer_ID, 'NULL'),
            ', product_name=', COALESCE(NEW.product_name, 'NULL'),
            ', quantity=', COALESCE(NEW.quantity, 'NULL'),
            ', unit_price=', COALESCE(NEW.unit_price, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_order_items_after_update` AFTER UPDATE ON `tbd_order_items` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_order_items',
        'Update',
        USER(),
        CONCAT(
            'Ítem de orden actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.seller_order_ID <=> NEW.seller_order_ID),
                    CONCAT('seller_order_ID: [', COALESCE(OLD.seller_order_ID, 'NULL'), '] -> [', COALESCE(NEW.seller_order_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.product_offer_ID <=> NEW.product_offer_ID),
                    CONCAT('product_offer_ID: [', COALESCE(OLD.product_offer_ID, 'NULL'), '] -> [', COALESCE(NEW.product_offer_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.product_name <=> NEW.product_name),
                    CONCAT('product_name: [', COALESCE(OLD.product_name, 'NULL'), '] -> [', COALESCE(NEW.product_name, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.quantity <=> NEW.quantity),
                    CONCAT('quantity: [', COALESCE(OLD.quantity, 'NULL'), '] -> [', COALESCE(NEW.quantity, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.unit_price <=> NEW.unit_price),
                    CONCAT('unit_price: [', COALESCE(OLD.unit_price, 'NULL'), '] -> [', COALESCE(NEW.unit_price, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_order_items_after_delete` AFTER DELETE ON `tbd_order_items` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_order_items',
        'Delete',
        USER(),
        CONCAT(
            'Ítem de orden eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', seller_order_ID=', COALESCE(OLD.seller_order_ID, 'NULL'),
            ', product_offer_ID=', COALESCE(OLD.product_offer_ID, 'NULL'),
            ', product_name=', COALESCE(OLD.product_name, 'NULL'),
            ', quantity=', COALESCE(OLD.quantity, 'NULL'),
            ', unit_price=', COALESCE(OLD.unit_price, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_orders_after_insert` AFTER INSERT ON `tbd_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_orders',
        'Create',
        USER(),
        CONCAT(
            'Orden (legado) creado. ID=', COALESCE(NEW.ID, 'NULL'),
            ', key=', COALESCE(NEW.key, 'NULL'),
            ', User_ID=', COALESCE(NEW.User_ID, 'NULL'),
            ', total_products=', COALESCE(NEW.total_products, 'NULL'),
            ', total_cost=', COALESCE(NEW.total_cost, 'NULL'),
            ', status_string=', COALESCE(NEW.status_string, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_orders_after_update` AFTER UPDATE ON `tbd_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_orders',
        'Update',
        USER(),
        CONCAT(
            'Orden (legado) actualizado. ID=', COALESCE(NEW.ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.User_ID <=> NEW.User_ID),
                    CONCAT('User_ID: [', COALESCE(OLD.User_ID, 'NULL'), '] -> [', COALESCE(NEW.User_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.total_products <=> NEW.total_products),
                    CONCAT('total_products: [', COALESCE(OLD.total_products, 'NULL'), '] -> [', COALESCE(NEW.total_products, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.total_cost <=> NEW.total_cost),
                    CONCAT('total_cost: [', COALESCE(OLD.total_cost, 'NULL'), '] -> [', COALESCE(NEW.total_cost, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status_string <=> NEW.status_string),
                    CONCAT('status_string: [', COALESCE(OLD.status_string, 'NULL'), '] -> [', COALESCE(NEW.status_string, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status <=> NEW.status),
                    CONCAT('status: [', COALESCE(OLD.status + 0, 'NULL'), '] -> [', COALESCE(NEW.status + 0, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_orders_after_delete` AFTER DELETE ON `tbd_orders` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_orders',
        'Delete',
        USER(),
        CONCAT(
            'Orden (legado) eliminado. ID=', COALESCE(OLD.ID, 'NULL'),
            ', key=', COALESCE(OLD.key, 'NULL'),
            ', User_ID=', COALESCE(OLD.User_ID, 'NULL'),
            ', total_products=', COALESCE(OLD.total_products, 'NULL'),
            ', total_cost=', COALESCE(OLD.total_cost, 'NULL'),
            ', status_string=', COALESCE(OLD.status_string, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_products_categories_after_insert` AFTER INSERT ON `tbd_products_categories` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tbd_products_categories',
        'Create',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Asociación producto-categoría creada. category_ID=', NEW.category_ID,
            ', product_ID=', NEW.product_ID
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_products_categories_after_update` AFTER UPDATE ON `tbd_products_categories` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tbd_products_categories',
        'Update',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Asociación producto-categoría actualizada. category_ID=', NEW.category_ID,
            ', product_ID=', NEW.product_ID,
            ', estado antiguo=', OLD.status, ', estado nuevo=', NEW.status
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_products_categories_after_delete` AFTER DELETE ON `tbd_products_categories` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        operation_date,
        description,
        operation_status
    )
    VALUES (
        'tbd_products_categories',
        'Delete',
        USER(),
        CURRENT_TIMESTAMP,
        CONCAT(
            'Asociación producto-categoría eliminada. category_ID=', OLD.category_ID,
            ', product_ID=', OLD.product_ID
        ),
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_users_offer_products_after_insert` AFTER INSERT ON `tbd_users_offer_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_users_offer_products',
        'Create',
        USER(),
        CONCAT(
            'Oferta de producto creado. product_offer_ID=', COALESCE(NEW.product_offer_ID, 'NULL'),
            ', user_ID=', COALESCE(NEW.user_ID, 'NULL'),
            ', product_ID=', COALESCE(NEW.product_ID, 'NULL'),
            ', available_stock=', COALESCE(NEW.available_stock, 'NULL'),
            ', status=', COALESCE(NEW.status + 0, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_users_offer_products_after_update` AFTER UPDATE ON `tbd_users_offer_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_users_offer_products',
        'Update',
        USER(),
        CONCAT(
            'Oferta de producto actualizado. product_offer_ID=', COALESCE(NEW.product_offer_ID, 'NULL'),
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(
                    NOT (OLD.user_ID <=> NEW.user_ID),
                    CONCAT('user_ID: [', COALESCE(OLD.user_ID, 'NULL'), '] -> [', COALESCE(NEW.user_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.product_ID <=> NEW.product_ID),
                    CONCAT('product_ID: [', COALESCE(OLD.product_ID, 'NULL'), '] -> [', COALESCE(NEW.product_ID, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.available_stock <=> NEW.available_stock),
                    CONCAT('available_stock: [', COALESCE(OLD.available_stock, 'NULL'), '] -> [', COALESCE(NEW.available_stock, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.status <=> NEW.status),
                    CONCAT('status: [', COALESCE(OLD.status + 0, 'NULL'), '] -> [', COALESCE(NEW.status + 0, 'NULL'), ']'),
                    NULL
                ),
                IF(
                    NOT (OLD.available_date <=> NEW.available_date),
                    CONCAT('available_date: [', COALESCE(OLD.available_date, 'NULL'), '] -> [', COALESCE(NEW.available_date, 'NULL'), ']'),
                    NULL
                )
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_users_offer_products_after_delete` AFTER DELETE ON `tbd_users_offer_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_users_offer_products',
        'Delete',
        USER(),
        CONCAT(
            'Oferta de producto eliminado. product_offer_ID=', COALESCE(OLD.product_offer_ID, 'NULL'),
            ', user_ID=', COALESCE(OLD.user_ID, 'NULL'),
            ', product_ID=', COALESCE(OLD.product_ID, 'NULL'),
            ', available_stock=', COALESCE(OLD.available_stock, 'NULL'),
            ', status=', COALESCE(OLD.status + 0, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_wishlist_products_after_insert` AFTER INSERT ON `tbd_wishlist_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_wishlist_products',
        'Create',
        USER(),
        CONCAT(
            'Producto en wishlist creado. user_ID=', COALESCE(NEW.user_ID, 'NULL'),
            ', product_ID=', COALESCE(NEW.product_ID, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_wishlist_products_after_update` AFTER UPDATE ON `tbd_wishlist_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_wishlist_products',
        'Update',
        USER(),
        CONCAT(
            'Producto en wishlist actualizado. user_ID=', NEW.user_ID,
            ', product_ID=', NEW.product_ID,
            '. Cambios: ',
            CONCAT_WS(
                ', ',
                IF(NOT (OLD.user_ID <=> NEW.user_ID), CONCAT('user_ID: [', OLD.user_ID, '] -> [', NEW.user_ID, ']'), NULL),
                IF(NOT (OLD.product_ID <=> NEW.product_ID), CONCAT('product_ID: [', OLD.product_ID, '] -> [', NEW.product_ID, ']'), NULL)
            )
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

```sql
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_tbd_wishlist_products_after_delete` AFTER DELETE ON `tbd_wishlist_products` FOR EACH ROW BEGIN
    INSERT INTO tb_logs (
        table_name,
        table_operation,
        db_user,
        description,
        operation_date,
        operation_status
    )
    VALUES (
        'tbd_wishlist_products',
        'Delete',
        USER(),
        CONCAT(
            'Producto en wishlist eliminado. user_ID=', COALESCE(OLD.user_ID, 'NULL'),
            ', product_ID=', COALESCE(OLD.product_ID, 'NULL')
        ),
        CURRENT_TIMESTAMP,
        b'1'
    );
END */;;
```

## Procedimientos

```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_restore_product`(IN p_product_id INT UNSIGNED)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM tb_products 
        WHERE ID = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto especificado no existe';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM tb_products 
        WHERE ID = p_product_id 
          AND status = b'1'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto ya se encuentra activo';
    END IF;

    UPDATE tb_products 
    SET status = b'1' 
    WHERE ID = p_product_id;
END ;;
```

```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_soft_delete`(
    IN p_table_name VARCHAR(64),
    IN p_id         INT UNSIGNED,
    IN p_id2        INT UNSIGNED
)
BEGIN
    DECLARE v_table  VARCHAR(64);
    DECLARE v_found  INT DEFAULT 0;
    DECLARE v_active INT DEFAULT 0;

    -- Ante cualquier error: deshacer y relanzar el mismo error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_table = LOWER(TRIM(p_table_name));

    -- 1) Validaciones generales
    IF v_table IS NULL OR v_table = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debes indicar el nombre de la tabla';
    END IF;

    IF v_table = 'tb_logs' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'tb_logs es la bitácora de auditoría y no se puede eliminar';
    END IF;

    IF v_table NOT IN ('tb_products', 'tb_users', 'tbc_categories', 'tbd_products_categories') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tabla no permitida para borrado lógico';
    END IF;

    IF p_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debes indicar el ID del registro';
    END IF;

    IF v_table = 'tbd_products_categories' AND p_id2 IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Para tbd_products_categories indica category_ID en p_id y product_ID en p_id2';
    END IF;

    -- tb_users necesita la columna status
    IF v_table = 'tb_users' AND NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'tb_users'
          AND COLUMN_NAME  = 'status'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'tb_users no tiene columna status; agrégala para habilitar el borrado lógico';
    END IF;

    START TRANSACTION;

    -- 2) tb_products
    IF v_table = 'tb_products' THEN
        SELECT COUNT(*), COALESCE(SUM(status = b'1'), 0)
          INTO v_found, v_active
          FROM tb_products WHERE ID = p_id FOR UPDATE;

        IF v_found = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto especificado no existe';
        END IF;
        IF v_active = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto ya se encuentra eliminado';
        END IF;

        UPDATE tb_products SET status = b'0' WHERE ID = p_id;

    -- 3) tbc_categories
    ELSEIF v_table = 'tbc_categories' THEN
        SELECT COUNT(*), COALESCE(SUM(status = b'1'), 0)
          INTO v_found, v_active
          FROM tbc_categories WHERE ID = p_id FOR UPDATE;

        IF v_found = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría especificada no existe';
        END IF;
        IF v_active = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría ya se encuentra eliminada';
        END IF;

        IF EXISTS (
            SELECT 1 FROM tbc_categories
            WHERE sup_id_category = p_id AND status = b'1'
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La categoría tiene subcategorías activas; elimínalas primero';
        END IF;

        UPDATE tbc_categories SET status = b'0' WHERE ID = p_id;

    -- 4) tbd_products_categories (llave compuesta)
    ELSEIF v_table = 'tbd_products_categories' THEN
        SELECT COUNT(*), COALESCE(SUM(status = b'1'), 0)
          INTO v_found, v_active
          FROM tbd_products_categories
          WHERE category_ID = p_id AND product_ID = p_id2 FOR UPDATE;

        IF v_found = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La relación producto-categoría no existe';
        END IF;
        IF v_active = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La relación producto-categoría ya se encuentra eliminada';
        END IF;

        UPDATE tbd_products_categories
           SET status = b'0'
         WHERE category_ID = p_id AND product_ID = p_id2;

    -- 5) tb_users (solo si existe la columna status)
    ELSEIF v_table = 'tb_users' THEN
        SELECT COUNT(*), COALESCE(SUM(status = b'1'), 0)
          INTO v_found, v_active
          FROM tb_users WHERE ID = p_id FOR UPDATE;

        IF v_found = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario especificado no existe';
        END IF;
        IF v_active = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario ya se encuentra eliminado';
        END IF;

        UPDATE tb_users SET status = b'0' WHERE ID = p_id;
    END IF;

    COMMIT;
END ;;
```

```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_soft_delete_product`(IN p_product_id INT UNSIGNED)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM tb_products 
        WHERE ID = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto especificado no existe';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM tb_products 
        WHERE ID = p_product_id 
          AND status = b'0'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto ya se encuentra eliminado';
    END IF;

    UPDATE tb_products 
    SET status = b'0' 
    WHERE ID = p_product_id;
END ;;
```

```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_soft_delete_user`(
    IN p_user_id INT UNSIGNED
)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_db_user VARCHAR(32);
    DECLARE v_has_role INT DEFAULT 0;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_status TINYINT DEFAULT NULL;
    DECLARE v_affected INT DEFAULT 0;

    -- 1. Identificar usuario de conexión
    SET v_db_user = SUBSTRING_INDEX(USER(), '@', 1);

    -- 2. Verificar roles autorizados asignados
    SELECT COUNT(*)
    INTO v_has_role
    FROM mysql.role_edges re
    WHERE re.TO_USER = v_db_user
      AND re.TO_HOST = '%'
      AND re.FROM_HOST = '%'
      AND re.FROM_USER IN (
          'superadmin',
          'admin',
          'support'
      );

    IF v_has_role = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Acceso denegado: rol no autorizado';
    END IF;

    -- 3. Validar identificador
    IF p_user_id IS NULL OR p_user_id = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El identificador del usuario es inválido';
    END IF;

    -- 4. Comprobar existencia y estado
    SELECT COUNT(*), MAX(status + 0)
    INTO v_exists, v_status
    FROM tb_users
    WHERE ID = p_user_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El usuario especificado no existe';
    END IF;

    -- 5. Comprobar estado actual
    IF v_status = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El usuario ya se encuentra inactivo';
    END IF;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El usuario tiene un estado inválido';
    END IF;

    -- 6. Eliminación lógica
    UPDATE tb_users
    SET status = b'0'
    WHERE ID = p_user_id
      AND status = b'1';

    SET v_affected = ROW_COUNT();

    IF v_affected <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'No se pudo desactivar el usuario';
    END IF;

    -- 7. Confirmación
    SELECT
        'Usuario desactivado correctamente' AS mensaje,
        p_user_id AS user_id,
        v_db_user AS ejecutado_por,
        'Inactivo' AS estado_actual,
        CURRENT_TIMESTAMP AS fecha_operacion;

END ;;
```

## Índices comprobados

| Tabla | Tipo | Nombre | Columnas |
|---|---|---|---|
| tb_buyer_orders | PRIMARY KEY | PRIMARY | `ID` |
| tb_buyer_orders | KEY | fk_user_2_idx | `user_ID` |
| tb_carts | PRIMARY KEY | PRIMARY | `ID` |
| tb_carts | UNIQUE KEY | uk_cart_user | `user_ID` |
| tb_logs | PRIMARY KEY | PRIMARY | `ID` |
| tb_payment_transactions | PRIMARY KEY | PRIMARY | `ID` |
| tb_payment_transactions | UNIQUE KEY | uk_payment_event_reference | `event_reference` |
| tb_payment_transactions | KEY | idx_payment_transactions_payment | `payment_ID` |
| tb_payments | PRIMARY KEY | PRIMARY | `ID` |
| tb_payments | UNIQUE KEY | uk_payment_provider_reference | `provider`,`provider_reference` |
| tb_payments | UNIQUE KEY | uk_payment_idempotency | `idempotency_key` |
| tb_payments | KEY | idx_payments_order | `order_ID` |
| tb_products | PRIMARY KEY | PRIMARY | `ID` |
| tb_products | UNIQUE KEY | SKU | `SKU` |
| tb_seller_orders | PRIMARY KEY | PRIMARY | `ID` |
| tb_seller_orders | UNIQUE KEY | uk_order_seller | `order_ID`,`seller_ID` |
| tb_seller_orders | KEY | idx_seller_orders_seller | `seller_ID` |
| tb_users | PRIMARY KEY | PRIMARY | `ID` |
| tb_users | UNIQUE KEY | email | `email` |
| tb_users | UNIQUE KEY | nickname | `nick` |
| tbc_categories | PRIMARY KEY | PRIMARY | `ID` |
| tbc_categories | UNIQUE KEY | name | `name` |
| tbc_categories | KEY | fk_superior_category | `sup_id_category` |
| tbc_payment_methods_types | PRIMARY KEY | PRIMARY | `ID` |
| tbc_payment_methods_types | UNIQUE KEY | code_UNIQUE | `code` |
| tbd_cart_items | PRIMARY KEY | PRIMARY | `cart_ID`,`product_offer_ID` |
| tbd_cart_items | KEY | idx_cart_item_offer | `product_offer_ID` |
| tbd_order_items | PRIMARY KEY | PRIMARY | `ID` |
| tbd_order_items | KEY | idx_order_items_seller_order | `seller_order_ID` |
| tbd_order_items | KEY | idx_order_items_offer | `product_offer_ID` |
| tbd_orders | PRIMARY KEY | PRIMARY | `ID` |
| tbd_products_categories | PRIMARY KEY | PRIMARY | `category_ID`,`product_ID` |
| tbd_products_categories | KEY | fk_product | `product_ID` |
| tbd_users_offer_products | PRIMARY KEY | PRIMARY | `product_offer_ID` |
| tbd_users_offer_products | KEY | fk_user_1 | `user_ID` |
| tbd_users_offer_products | KEY | fk_product_2 | `product_ID` |
| tbd_wishlist_products | PRIMARY KEY | PRIMARY | `user_ID`,`product_ID` |
| tbd_wishlist_products | KEY | idx_wishlist_product | `product_ID` |

## Claves foráneas comprobadas

| Restricción | Desde | Hacia | Acción SQL adicional |
|---|---|---|---|
| fk_user_2 | tb_buyer_orders.user_ID | tb_users.ID | sin cláusula explícita |
| fk_cart_user | tb_carts.user_ID | tb_users.ID | sin cláusula explícita |
| fk_payment_transaction_payment | tb_payment_transactions.payment_ID | tb_payments.ID | , |
| fk_payment_order | tb_payments.order_ID | tb_buyer_orders.ID | , |
| fk_seller_order_order | tb_seller_orders.order_ID | tb_buyer_orders.ID | , |
| fk_seller_order_seller | tb_seller_orders.seller_ID | tb_users.ID | , |
| fk_superior_category | tbc_categories.sup_id_category | tbc_categories.ID | sin cláusula explícita |
| fk_cart_item_cart | tbd_cart_items.cart_ID | tb_carts.ID | ON DELETE CASCADE, |
| fk_cart_item_offer | tbd_cart_items.product_offer_ID | tbd_users_offer_products.product_offer_ID | , |
| fk_order_item_offer | tbd_order_items.product_offer_ID | tbd_users_offer_products.product_offer_ID | , |
| fk_order_item_seller_order | tbd_order_items.seller_order_ID | tb_seller_orders.ID | , |
| fk_category | tbd_products_categories.category_ID | tbc_categories.ID | , |
| fk_product | tbd_products_categories.product_ID | tb_products.ID | sin cláusula explícita |
| fk_product_2 | tbd_users_offer_products.product_ID | tb_products.ID | sin cláusula explícita |
| fk_wishlist_product | tbd_wishlist_products.product_ID | tb_products.ID | , |
| fk_wishlist_user | tbd_wishlist_products.user_ID | tb_users.ID | sin cláusula explícita |
