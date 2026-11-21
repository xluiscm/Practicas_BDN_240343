db = db.getSiblingDB('ecommerce');

db.createView("vw_public_reviews", "col_products_reviews", [
  { $match: { rating: { $gte: 4 } } },
  { $project: { product_id: 1, rating: 1, comment: 1, created_at: 1 } }
]);

db.createView("vw_user_addresses", "col_users_adress", [
  { $group: { _id: "$user_id", total_direcciones: { $sum: 1 } } }
]);

db.createView("vw_shipments_in_transit", "col_shipment_tracking", [
  { $match: { status: "en_transito" } }
]);

db.createView("vw_seller_reviews", "col_products_reviews", [
  { $group: { _id: "$seller_id", total: { $sum: 1 }, promedio: { $avg: "$rating" } } }
]);

db.createView("vw_logs_denied", "col_logs", [
  { $match: { estado: "denegado" } }
]);

print("✓ Vistas creadas");
