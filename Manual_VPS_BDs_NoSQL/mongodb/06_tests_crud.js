db = db.getSiblingDB('ecommerce');

db.col_products_reviews.insertOne({ product_id: 99, user_id: 1, seller_id: 1, rating: 5, comment: "Producto de prueba CRUD", created_at: new Date() });
db.col_logs.insertOne({ fecha_hora: new Date(), operacion: "CREATE", usuario: "admin1", rol: "admin", ip: "192.168.1.1", coleccion: "col_products_reviews", documento: "99", descripcion: "Inserción de prueba", estado: "éxito" });

db.col_products_reviews.findOne({ product_id: 99 });
db.col_logs.insertOne({ fecha_hora: new Date(), operacion: "READ", usuario: "admin1", rol: "admin", ip: "192.168.1.1", coleccion: "col_products_reviews", documento: "99", descripcion: "Consulta de prueba", estado: "éxito" });

db.col_products_reviews.updateOne({ product_id: 99 }, { $set: { rating: 4 } });
db.col_logs.insertOne({ fecha_hora: new Date(), operacion: "UPDATE", usuario: "admin1", rol: "admin", ip: "192.168.1.1", coleccion: "col_products_reviews", documento: "99", descripcion: "Actualización de rating", estado: "éxito" });

db.col_products_reviews.deleteOne({ product_id: 99 });
db.col_logs.insertOne({ fecha_hora: new Date(), operacion: "DELETE", usuario: "admin1", rol: "admin", ip: "192.168.1.1", coleccion: "col_products_reviews", documento: "99", descripcion: "Eliminación de prueba", estado: "éxito" });

print("✓ Pruebas CRUD completadas");
