db = db.getSiblingDB('ecommerce');
db.col_users_adress.createIndex({ user_id: 1 }, { unique: true });
db.col_products_reviews.createIndex({ product_id: 1, created_at: -1 });
db.col_products_reviews.createIndex({ comment: "text" });
db.col_shipment_tracking.createIndex({ order_id: 1 }, { unique: true });
db.col_logs.createIndex({ fecha_hora: -1 });
db.col_logs.createIndex({ usuario: 1, operacion: 1 });
print("✓ Índices creados");
