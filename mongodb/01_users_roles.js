db = db.getSiblingDB('ecommerce');
db.createRole({ role: "rol_admin", privileges: [
  { resource: { db: "ecommerce", collection: "col_users_adress" }, actions: ["find","insert","update","remove"] },
  { resource: { db: "ecommerce", collection: "col_products_reviews" }, actions: ["find","insert","update","remove"] },
  { resource: { db: "ecommerce", collection: "col_shipment_tracking" }, actions: ["find","insert","update","remove"] },
  { resource: { db: "ecommerce", collection: "col_logs" }, actions: ["find"] }
], roles: [] });
db.createRole({ role: "rol_seller", privileges: [
  { resource: { db: "ecommerce", collection: "col_products_reviews" }, actions: ["find","insert","update"] },
  { resource: { db: "ecommerce", collection: "col_shipment_tracking" }, actions: ["find"] },
  { resource: { db: "ecommerce", collection: "col_users_adress" }, actions: ["find"] }
], roles: [] });
db.createRole({ role: "rol_buyer", privileges: [
  { resource: { db: "ecommerce", collection: "col_users_adress" }, actions: ["find","insert"] },
  { resource: { db: "ecommerce", collection: "col_products_reviews" }, actions: ["find","insert"] },
  { resource: { db: "ecommerce", collection: "col_shipment_tracking" }, actions: ["find"] }
], roles: [] });
db.createRole({ role: "rol_support", privileges: [
  { resource: { db: "ecommerce", collection: "col_users_adress" }, actions: ["find","update"] },
  { resource: { db: "ecommerce", collection: "col_products_reviews" }, actions: ["find"] },
  { resource: { db: "ecommerce", collection: "col_shipment_tracking" }, actions: ["find","update"] },
  { resource: { db: "ecommerce", collection: "col_logs" }, actions: ["find","insert"] }
], roles: [] });
db.createRole({ role: "rol_common", privileges: [
  { resource: { db: "ecommerce", collection: "col_products_reviews" }, actions: ["find"] }
], roles: [] });
db.createRole({ role: "rol_not_registered", privileges: [
  { resource: { db: "ecommerce", collection: "vw_public_reviews" }, actions: ["find"] }
], roles: [] });
db.createUser({ user: "admin1", pwd: "admin123", roles: ["rol_admin"] });
db.createUser({ user: "seller1", pwd: "seller123", roles: ["rol_seller"] });
db.createUser({ user: "buyer1", pwd: "buyer123", roles: ["rol_buyer"] });
db.createUser({ user: "support1", pwd: "support123", roles: ["rol_support"] });
db.createUser({ user: "common1", pwd: "common123", roles: ["rol_common"] });
db.createUser({ user: "guest1", pwd: "guest123", roles: ["rol_not_registered"] });
print("✓ Roles y usuarios creados");
