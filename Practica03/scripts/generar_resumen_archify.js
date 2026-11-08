const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..', '..');
const erdPath = path.join(root, '.archify', 'erd-db-test-corregida-20261107-220000', 'candidate.json');
const outputDir = path.join(root, '.archify', 'db-test-corregida-resumen-20261108');
const erd = JSON.parse(fs.readFileSync(erdPath, 'utf8'));
const domains = [
  { id: 'usuarios', name: 'Usuarios y direcciones', type: 'database', tables: ['tb_users', 'tb_people', 'tb_user_addresses', 'tbd_address_components', 'tbd_user_payment_methods', 'tbd_wishlist_products'] },
  { id: 'catalogo', name: 'Catálogo y ofertas', type: 'database', tables: ['tb_products', 'tbc_categories', 'tbd_products_categories', 'tbd_users_offer_products'] },
  { id: 'compras', name: 'Carritos y pedidos', type: 'database', tables: ['tb_carts', 'tbd_cart_items', 'tb_buyer_orders', 'tbd_orders', 'tb_seller_orders', 'tbd_order_items', 'tb_shipments'] },
  { id: 'pagos', name: 'Pagos', type: 'database', tables: ['tbc_payment_methods_types', 'tbc_payment_methods_types_res', 'tbd_user_payment_methods', 'tb_payments', 'tb_payment_transactions'] },
  { id: 'devoluciones', name: 'Cancelaciones y devoluciones', type: 'database', tables: ['tb_order_cancellations', 'tbd_cancellation_items', 'tb_returns', 'tbd_return_items', 'tb_refunds'] },
  { id: 'auditoria', name: 'Auditoría', type: 'database', tables: ['tb_logs'] }
];
const tableDomain = new Map(domains.flatMap(d => d.tables.map(t => [t, d.id])));
const domainById = new Map(domains.map(d => [d.id, d]));
const fields = new Map(erd.entities.map(e => [e.id, e.attributes.length]));
for (const d of domains) {
  d.fieldCount = d.tables.reduce((n, t) => n + (fields.get(t) || 0), 0);
  d.foreignKeys = erd.relationships.filter(r => tableDomain.get(r.from) === d.id).length;
}
const aggregate = new Map();
for (const rel of erd.relationships) {
  const from = tableDomain.get(rel.from);
  const to = tableDomain.get(rel.to);
  if (!from || !to || from === to) continue;
  const key = `${from}->${to}`;
  aggregate.set(key, (aggregate.get(key) || 0) + 1);
}
const positions = [[70, 105], [450, 105], [830, 105], [70, 390], [450, 390], [830, 390]];
const components = domains.map((d, i) => ({
  id: d.id,
  type: d.type,
  icon: 'database',
  label: d.name,
  sublabel: `${d.tables.length} tablas · ${d.fieldCount} campos · ${d.foreignKeys} relaciones FK`,
  pos: positions[i],
  size: [310, 110]
}));
const connections = [...aggregate.entries()].map(([key, count], i) => {
  const [from, to] = key.split('->');
  return { id: `fk-${i + 1}`, from, to, label: `${count} FK`, route: 'auto' };
});
const candidate = {
  schema_version: 1,
  diagram_type: 'architecture',
  meta: {
    title: 'db_test_corregida · mapa del esquema',
    subtitle: 'Vista general por áreas; el diccionario interactivo conserva el detalle de tablas y columnas.',
    locale: 'es',
    output: '.archify/db-test-corregida-resumen-20261108/diccionario-esquema.html',
    quality_profile: 'standard',
    views: [
      ...domains.slice(0, 3).map(d => ({ id: d.id, label: d.name, focus: [d.id], note: `${d.tables.length} tablas, ${d.fieldCount} campos. Incluye ${d.tables.slice(0, 3).join(', ')}${d.tables.length > 3 ? ' y más.' : '.'}` })),
      { id: 'pagos', label: 'Pagos', focus: ['pagos'], note: `${domains[3].tables.length} tablas y ${domains[3].fieldCount} campos relacionados con los pagos.` },
      { id: 'operacion-final', label: 'Devoluciones y auditoría', focus: ['devoluciones', 'auditoria'], note: 'Cancelaciones, devoluciones, reembolsos y registros de auditoría.' }
    ]
  },
  layout: { mode: 'grid', cols: 3, gapX: 70, gapY: 120 },
  components,
  connections,
  cards: [{
    dot: 'cyan',
    title: 'Alcance del mapa',
    items: [
      `${erd.entities.length} tablas y ${erd.entities.reduce((n, e) => n + e.attributes.length, 0)} campos del respaldo db_test_corregida.`,
      `${erd.relationships.length} relaciones FK reconocidas; las líneas agrupan las relaciones entre áreas.`,
      'El explorador del diccionario contiene el detalle por tabla, campo, tipo y conteo de registros.'
    ]
  }]
};
fs.mkdirSync(outputDir, { recursive: true });
fs.writeFileSync(path.join(outputDir, 'candidate.json'), JSON.stringify(candidate, null, 2));
console.log(JSON.stringify({ tables: erd.entities.length, fields: erd.entities.reduce((n, e) => n + e.attributes.length, 0), relationships: erd.relationships.length, crossDomainConnections: connections.length, output: path.join(outputDir, 'candidate.json') }, null, 2));
