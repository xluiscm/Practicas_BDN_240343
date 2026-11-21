db = db.getSiblingDB('ecommerce');

db.createCollection("col_users_adress", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["user_id","street","city","state","zip","country"],
  properties: {
    user_id: { bsonType: "int" }, street: { bsonType: "string" },
    city: { bsonType: "string" }, state: { bsonType: "string" },
    zip: { bsonType: "string" }, country: { bsonType: "string" },
    is_default: { bsonType: "bool" }
  }
}}});

db.createCollection("col_products_reviews", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["product_id","user_id","rating","comment","created_at"],
  properties: {
    product_id: { bsonType: "int" }, user_id: { bsonType: "int" },
    seller_id: { bsonType: "int" }, rating: { bsonType: "int", minimum: 1, maximum: 5 },
    comment: { bsonType: "string" }, created_at: { bsonType: "date" }
  }
}}});

db.createCollection("col_shipment_tracking", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["order_id","user_id","status","events"],
  properties: {
    order_id: { bsonType: "int" }, user_id: { bsonType: "int" },
    status: { enum: ["preparando","en_transito","entregado","devuelto"] },
    events: { bsonType: "array" }
  }
}}});

db.createCollection("col_logs", { validator: { $jsonSchema: {
  bsonType: "object",
  required: ["fecha_hora","operacion","usuario","rol","ip","coleccion","documento","descripcion","estado"],
  properties: {
    fecha_hora: { bsonType: "date" }, operacion: { enum: ["CREATE","READ","UPDATE","DELETE"] },
    usuario: { bsonType: "string" }, rol: { bsonType: "string" },
    ip: { bsonType: "string" }, coleccion: { bsonType: "string" },
    documento: { bsonType: "string" }, descripcion: { bsonType: "string" },
    estado: { enum: ["éxito","denegado"] }
  }
}}});

print("✓ Colecciones y schemas creados");
