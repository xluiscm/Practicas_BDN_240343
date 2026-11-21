DROP TABLE IF EXISTS tb_users CASCADE;
CREATE TABLE tb_users (
  ID serial PRIMARY KEY,
  email varchar(100) NOT NULL,
  nick varchar(50) NOT NULL,
  password varchar(255) NOT NULL,
  status boolean DEFAULT TRUE
);
INSERT INTO tb_users (email, nick, password) VALUES
('aylin@utxicotepec.edu.mx', 'Aylin', 'hash1'),
('angel@utxicotepec.edu.mx', 'Angel', 'hash2'),
('luis@utxicotepec.edu.mx', 'Luis', 'hash3'),
('jonhy@utxicotepec.edu.mx', 'Jonhy', 'hash4'),
('erick@utxicotepec.edu.mx', 'Erick', 'hash5'),
('pablo@utxicotepec.edu.mx', 'Pablo', 'hash6'),
('carlos@utxicotepec.edu.mx', 'Carlos', 'hash7'),
('maria@utxicotepec.edu.mx', 'Maria', 'hash8'),
('jose@utxicotepec.edu.mx', 'Jose', 'hash9'),
('ana@utxicotepec.edu.mx', 'Ana', 'hash10');

DROP TABLE IF EXISTS tb_products CASCADE;
CREATE TABLE tb_products (
  ID serial PRIMARY KEY,
  SKU varchar(50) NOT NULL,
  name varchar(250) NOT NULL,
  current_price decimal(10,2) DEFAULT '0.00',
  current_stock int DEFAULT 0
);
INSERT INTO tb_products (SKU, name, current_price, current_stock) VALUES
('PROD-001', 'Teclado Mecanico RGB', 899.00, 50),
('PROD-002', 'Mouse Inalambrico', 399.00, 100),
('PROD-003', 'Monitor 24 pulgadas', 3500.00, 20),
('PROD-004', 'Laptop HP Victus', 15999.00, 10),
('PROD-005', 'Audifonos Sony WH-1000XM5', 6999.00, 15),
('PROD-006', 'Silla Ergonomica', 4500.00, 8),
('PROD-007', 'Freidora de Aire', 1899.00, 25),
('PROD-008', 'Taladro DeWalt', 2999.00, 12),
('PROD-009', 'Bufanda Ejecutivo', 199.00, 200),
('PROD-010', 'Zapatos Formal', 899.00, 60);

DROP TABLE IF EXISTS tb_buyer_orders CASCADE;
CREATE TABLE tb_buyer_orders (
  ID serial PRIMARY KEY,
  seller_ID int NOT NULL,
  subtotal decimal(12,2) DEFAULT '0.00',
  fulfillment_status varchar(9) DEFAULT 'Pending'
);
INSERT INTO tb_buyer_orders (seller_ID, subtotal, fulfillment_status) VALUES
(1, 899.00, 'Delivered'),
(2, 399.00, 'Sent'),
(3, 3500.00, 'Preparing'),
(4, 15999.00, 'Pending'),
(5, 6999.00, 'Delivered'),
(6, 4500.00, 'Sent'),
(7, 1899.00, 'Preparing'),
(8, 2999.00, 'Pending'),
(9, 199.00, 'Delivered'),
(10, 899.00, 'Canceled');

DROP TABLE IF EXISTS tb_logs CASCADE;
CREATE TABLE tb_logs (
  ID serial PRIMARY KEY,
  table_name varchar(100) NOT NULL,
  operation varchar(6) NOT NULL,
  db_user varchar(80) NOT NULL,
  description text NOT NULL
);
INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES
('tb_users', 'Create', 'admin', 'Usuario creado'),
('tb_products', 'Create', 'admin', 'Producto creado'),
('tb_buyer_orders', 'Create', 'admin', 'Orden creada');
