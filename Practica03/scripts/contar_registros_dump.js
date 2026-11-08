const fs = require('node:fs');
const file = process.argv[2];
if (!file) throw new Error('Uso: node contar_registros_dump.js <archivo.sql>');
const sql = fs.readFileSync(file, 'utf8');
const counts = new Map();
for (const table of sql.matchAll(/^CREATE TABLE\s+\x60([^\x60]+)\x60/gm)) {
  counts.set(table[1], 0);
}
const insert = /^INSERT INTO \x60([^ \x60]+)\x60[\s\S]*?\bVALUES\b/gm;
let m;
while ((m = insert.exec(sql))) {
  const table = m[1];
  let i = insert.lastIndex, depth = 0, quote = '', escaped = false, n = 0;
  for (; i < sql.length; i++) {
    const c = sql[i];
    if (quote) {
      if (escaped) escaped = false;
      else if (c === '\\') escaped = true;
      else if (c === quote) {
        if (sql[i + 1] === quote) i++;
        else quote = '';
      }
      continue;
    }
    if (c === "'" || c === '"' || c === '\x60') { quote = c; continue; }
    if (c === '(') { if (depth === 0) n++; depth++; }
    else if (c === ')') depth--;
    else if (c === ';' && depth === 0) break;
  }
  counts.set(table, (counts.get(table) || 0) + n);
  insert.lastIndex = i + 1;
}
const rows = [...counts].sort((a, b) => b[1] - a[1]);
console.log(JSON.stringify({
  file, insertTables: counts.size,
  totalRecords: rows.reduce((sum, x) => sum + x[1], 0),
  byTable: rows.map(([table, records]) => ({ table, records }))
}, null, 2));
