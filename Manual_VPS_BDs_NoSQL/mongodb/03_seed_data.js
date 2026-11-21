db = db.getSiblingDB('ecommerce');

db.col_users_adress.insertMany([
  { user_id: 1, street: "Av. Juárez 123", city: "Xicotepec", state: "Puebla", zip: "73080", country: "México", is_default: true },
  { user_id: 2, street: "Calle Hidalgo 45", city: "Puebla", state: "Puebla", zip: "72000", country: "México", is_default: true },
  { user_id: 3, street: "Blvd. Reforma 789", city: "CDMX", state: "CDMX", zip: "06000", country: "México", is_default: true },
  { user_id: 4, street: "Av. Universidad 1000", city: "CDMX", state: "CDMX", zip: "04510", country: "México", is_default: false },
  { user_id: 5, street: "Calle 5 de Mayo 22", city: "Guadalajara", state: "Jalisco", zip: "44100", country: "México", is_default: true },
  { user_id: 6, street: "Av. Vallarta 1500", city: "Guadalajara", state: "Jalisco", zip: "44110", country: "México", is_default: false },
  { user_id: 7, street: "Calle Morelos 33", city: "Monterrey", state: "Nuevo León", zip: "64000", country: "México", is_default: true },
  { user_id: 8, street: "Av. Constitución 500", city: "Monterrey", state: "Nuevo León", zip: "64060", country: "México", is_default: false },
  { user_id: 9, street: "Calle Zaragoza 77", city: "Querétaro", state: "Querétaro", zip: "76000", country: "México", is_default: true },
  { user_id: 10, street: "Av. Tecnológico 100", city: "Querétaro", state: "Querétaro", zip: "76010", country: "México", is_default: false }
]);

db.col_products_reviews.insertMany([
  { product_id: 1, user_id: 1, seller_id: 1, rating: 5, comment: "Excelente producto", created_at: new Date("2026-11-01") },
  { product_id: 2, user_id: 2, seller_id: 1, rating: 4, comment: "Muy bueno", created_at: new Date("2026-11-02") },
  { product_id: 3, user_id: 3, seller_id: 2, rating: 5, comment: "Calidad superior", created_at: new Date("2026-11-03") },
  { product_id: 4, user_id: 4, seller_id: 2, rating: 3, comment: "Cumple", created_at: new Date("2026-11-04") },
  { product_id: 5, user_id: 5, seller_id: 1, rating: 5, comment: "Increíble", created_at: new Date("2026-11-05") },
  { product_id: 6, user_id: 6, seller_id: 3, rating: 4, comment: "Buen precio", created_at: new Date("2026-11-06") },
  { product_id: 7, user_id: 7, seller_id: 3, rating: 2, comment: "No era lo esperado", created_at: new Date("2026-11-07") },
  { product_id: 8, user_id: 8, seller_id: 1, rating: 5, comment: "Perfecto", created_at: new Date("2026-11-08") },
  { product_id: 9, user_id: 9, seller_id: 2, rating: 4, comment: "Buena atención", created_at: new Date("2026-11-09") },
  { product_id: 10, user_id: 10, seller_id: 3, rating: 5, comment: "Recomendado", created_at: new Date("2026-11-10") }
]);

db.col_shipment_tracking.insertMany([
  { order_id: 1, user_id: 1, status: "entregado", events: [{ fecha: new Date("2026-11-01"), estado: "preparando" }, { fecha: new Date("2026-11-05"), estado: "entregado" }] },
  { order_id: 2, user_id: 2, status: "en_transito", events: [{ fecha: new Date("2026-11-02"), estado: "preparando" }] },
  { order_id: 3, user_id: 3, status: "preparando", events: [{ fecha: new Date("2026-11-03"), estado: "preparando" }] },
  { order_id: 4, user_id: 4, status: "entregado", events: [{ fecha: new Date("2026-11-04"), estado: "preparando" }] },
  { order_id: 5, user_id: 5, status: "en_transito", events: [{ fecha: new Date("2026-11-05"), estado: "preparando" }] },
  { order_id: 6, user_id: 6, status: "devuelto", events: [{ fecha: new Date("2026-11-06"), estado: "preparando" }] },
  { order_id: 7, user_id: 7, status: "entregado", events: [{ fecha: new Date("2026-11-07"), estado: "preparando" }] },
  { order_id: 8, user_id: 8, status: "preparando", events: [{ fecha: new Date("2026-11-08"), estado: "preparando" }] },
  { order_id: 9, user_id: 9, status: "en_transito", events: [{ fecha: new Date("2026-11-09"), estado: "preparando" }] },
  { order_id: 10, user_id: 10, status: "entregado", events: [{ fecha: new Date("2026-11-10"), estado: "preparando" }] }
]);

print("✓ Datos de prueba insertados");
