const fs = require('node:fs');
const path = require('node:path');

const base = path.resolve(__dirname, '..');
const backupsDir = path.join(base, 'backups');
const requestedDump = process.argv[2];
const dumpPath = requestedDump ? path.resolve(process.cwd(), requestedDump) : fs.readdirSync(backupsDir)
  .filter(name => name.toLowerCase().endsWith('.sql'))
  .map(name => path.join(backupsDir, name))
  .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs)[0];
const csvPath = path.join(base, 'diccionario', 'campos.csv');
const outPath = path.join(base, 'diccionario', 'diccionario.html');
const pagesDir = path.resolve(base, '..', 'docs');
const pagesDictionaryDir = path.join(pagesDir, 'diccionario');
if (!dumpPath || !fs.existsSync(dumpPath)) throw new Error('No se encontró el respaldo SQL: ' + (requestedDump || backupsDir));
const sql = fs.readFileSync(dumpPath, 'utf8');

const tables = new Map();
const splitDefinitions = text => {
  const parts = []; let start = 0, depth = 0, quote = '', escaped = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quote) {
      if (escaped) escaped = false;
      else if (c === '\\') escaped = true;
      else if (c === quote) { if (text[i + 1] === quote) i++; else quote = ''; }
      continue;
    }
    if (c === "'" || c === '"' || c === '`') quote = c;
    else if (c === '(') depth++;
    else if (c === ')') depth--;
    else if (c === ',' && depth === 0) { parts.push(text.slice(start, i).trim()); start = i + 1; }
  }
  if (text.slice(start).trim()) parts.push(text.slice(start).trim());
  return parts;
};
const ddlRe = /CREATE TABLE\s+`([^`]+)`\s*\(([\s\S]*?)\)\s*ENGINE\s*=/g;
let ddl;
while ((ddl = ddlRe.exec(sql))) {
  const table = { name: ddl[1], fields: [], rows: 0, fks: [] };
  for (const part of splitDefinitions(ddl[2])) {
    const column = part.match(/^`((?:``|[^`])+)`\s+([\s\S]+)$/);
    if (column) {
      const definition = column[2].trim(), nullable = !/\bNOT NULL\b/i.test(column[2]);
      const defaultMatch = definition.match(/\bDEFAULT\s+((?:_binary\s+)?(?:b)?'(?:\\.|''|[^'])*'|[^\s,]+)/i);
      table.fields.push({ name: column[1].replace(/``/g, '`'), type: definition,
        nullable: nullable ? 'Sí' : 'No', pk: false, fk: '',
        default: defaultMatch ? defaultMatch[1] : (nullable ? 'NULL' : '—'),
        auto: /\bAUTO_INCREMENT\b/i.test(definition), indexes: '' });
      continue;
    }
    let key = part.match(/^PRIMARY KEY\s*\(([\s\S]+?)\)/i);
    if (key) {
      for (const m of key[1].matchAll(/`((?:``|[^`])+)`/g)) {
        const field = table.fields.find(f => f.name === m[1].replace(/``/g, '`'));
        if (field) { field.pk = true; field.indexes = 'PRIMARY KEY'; }
      }
      continue;
    }
    key = part.match(/^(?:UNIQUE\s+)?(?:KEY|INDEX)\s+`([^`]+)`\s*\(([\s\S]+?)\)/i);
    if (key) {
      for (const m of key[2].matchAll(/`((?:``|[^`])+)`/g)) {
        const field = table.fields.find(f => f.name === m[1].replace(/``/g, '`'));
        if (field) field.indexes = [field.indexes, key[1]].filter(Boolean).join('; ');
      }
      continue;
    }
    const fk = part.match(/^CONSTRAINT\s+`([^`]+)`\s+FOREIGN KEY\s*\(([^)]+)\)\s+REFERENCES\s+`([^`]+)`\s*\(([^)]+)\)([\s\S]*)$/i);
    if (fk) {
      const fromCols = [...fk[2].matchAll(/`([^`]+)`/g)].map(m => m[1]);
      const toCols = [...fk[4].matchAll(/`([^`]+)`/g)].map(m => m[1]);
      table.fks.push({ name: fk[1], from: table.name, to: fk[3], fromCols, toCols,
        deleteRule: (fk[5].match(/ON DELETE\s+(CASCADE|SET NULL|RESTRICT|NO ACTION|SET DEFAULT)/i) || [])[1] || 'NO ACTION',
        updateRule: (fk[5].match(/ON UPDATE\s+(CASCADE|SET NULL|RESTRICT|NO ACTION|SET DEFAULT)/i) || [])[1] || 'NO ACTION' });
    }
  }
  tables.set(table.name, table);
}
if (!tables.size) throw new Error('El respaldo no contiene instrucciones CREATE TABLE compatibles: ' + dumpPath);
const fields = [...tables.values()].flatMap(table => table.fields.map(field => ({ table: table.name, ...field })));
const csvEscape = value => '"' + String(value ?? '').replace(/"/g, '""') + '"';
const csvRows = [['tabla','campo','tipo_SQL','definicion_SQL','NULL','PK','FK','default','auto_increment','indices']];
for (const table of tables.values()) for (const field of table.fields) {
  csvRows.push([table.name, field.name, (field.type.match(/^\S+/) || [''])[0], field.type,
    field.nullable, field.pk ? 'Sí' : 'No', field.fk, field.default, field.auto ? 'Sí' : 'No', field.indexes]);
}
fs.writeFileSync(csvPath, csvRows.map(row => row.map(csvEscape).join(',')).join('\r\n') + '\r\n', 'utf8');

// Count top-level INSERT tuples from the dump while ignoring parentheses in strings.
const insertRe = /^INSERT INTO \x60([^ \x60]+)\x60[\s\S]*?\bVALUES\b/gm;
let match;
while ((match = insertRe.exec(sql))) {
  const table = match[1];
  const t = tables.get(table);
  if (!t) continue;
  let i = insertRe.lastIndex, depth = 0, quote = '', escaped = false, count = 0;
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
    if (c === '(') { if (depth === 0) count++; depth++; }
    else if (c === ')') depth--;
    else if (c === ';' && depth === 0) break;
  }
  t.rows += count;
  insertRe.lastIndex = i + 1;
}

const all = [...tables.values()];
for (const table of all) for (const fk of table.fks) {
  fk.fromCols.forEach((name, index) => {
    const field = table.fields.find(item => item.name === name);
    if (field) field.fk = fk.to + '.' + fk.toCols[index];
  });
}
const countObjects = (source, type) => {
  const normalized = source
    .replace(/\/\*!\d+\s*([\s\S]*?)\*\//g, '$1')
    .replace(/\bDEFINER\s*=\s*(?:`[^`]*`|'[^']*'|[^\s@]+)@(?:`[^`]*`|'[^']*'|[^\s]+)\s*/gi, '');
  const patterns = {
    VIEW: /\bCREATE\s+(?:(?:OR\s+REPLACE)\s+)?(?:ALGORITHM\s*=\s*\w+\s+)?(?:SQL\s+SECURITY\s+\w+\s+)?VIEW\s+`([^`]+)`/gi,
    TRIGGER: /\bCREATE\s+TRIGGER\s+`([^`]+)`/gi,
    PROCEDURE: /\bCREATE\s+PROCEDURE\s+`([^`]+)`/gi
  };
  return new Set([...normalized.matchAll(patterns[type])].map(match => match[1].toLowerCase())).size;
};
const objectCounts = {
  views: countObjects(sql, 'VIEW'),
  triggers: countObjects(sql, 'TRIGGER'),
  procedures: countObjects(sql, 'PROCEDURE')
};
const rowsFor = name => (all.find(table => table.name.toLowerCase() === name)?.rows || 0);
const db = (sql.match(/^USE\s+`([^`]+)`/im) || [,'desconocida'])[1];
const categories = [
  { name: 'Usuarios', color: '#48DCC6', test: t => /user|people|address/i.test(t.name) },
  { name: 'Catálogo', color: '#75A7FF', test: t => /product|categor/i.test(t.name) },
  { name: 'Compras', color: '#FFC36E', test: t => /order|cart|shipment/i.test(t.name) },
  { name: 'Pagos', color: '#B99AFF', test: t => /payment/i.test(t.name) },
  { name: 'Devoluciones', color: '#FF829D', test: t => /return|refund|cancellation/i.test(t.name) },
  { name: 'Auditoría', color: '#A8B7CC', test: t => /logs/i.test(t.name) }
];
for (const t of all) t.module = (categories.find(c => c.test(t)) || categories[0]).name;

const layout = new Map();
const boxW = 205, boxH = 78, colGap = 54, rowGap = 32, left = 45, top = 54;
const groups = categories.map(c => ({ ...c, tables: all.filter(t => t.module === c.name) })).filter(g => g.tables.length);
groups.forEach((g, col) => g.tables.forEach((t, row) => layout.set(t.name, {
  x: left + col * (boxW + colGap), y: top + row * (boxH + rowGap)
})));
const svgW = left * 2 + groups.length * boxW + (groups.length - 1) * colGap;
const maxRows = Math.max(...groups.map(g => g.tables.length));
const svgH = top * 2 + maxRows * boxH + (maxRows - 1) * rowGap;
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[c]));

let edgeSvg = '';
for (const t of all) for (const fk of t.fks) {
  const a = layout.get(fk.from), b = layout.get(fk.to);
  if (!a || !b) continue;
  if (fk.from === fk.to) {
    const sx = a.x + boxW, sy = a.y + 37;
    edgeSvg += '<path class="edge" d="M '+sx+' '+sy+' C '+(sx+85)+' '+(sy-38)+', '+(sx+85)+' '+(sy+42)+', '+sx+' '+(sy+48)+'" marker-end="url(#arrow)"><title>'+esc(fk.name)+': autorreferencia</title></path>';
  } else {
    const ax = a.x + boxW, ay = a.y + boxH/2, bx = b.x, by = b.y + boxH/2;
    const mid = (ax + bx) / 2;
    edgeSvg += '<path class="edge" d="M '+ax+' '+ay+' C '+mid+' '+ay+', '+mid+' '+by+', '+bx+' '+by+'" marker-end="url(#arrow)"><title>'+esc(fk.name)+': '+esc(fk.fromCols.join(', '))+' → '+esc(fk.to)+'.'+esc(fk.toCols.join(', '))+'; DELETE '+esc(fk.deleteRule)+'; UPDATE '+esc(fk.updateRule)+'</title></path>';
  }
}
let nodesSvg = '';
for (const t of all) {
  const p = layout.get(t.name), g = groups.find(x => x.name === t.module);
  nodesSvg += '<g class="node" tabindex="0" role="button" data-table="'+esc(t.name)+'" transform="translate('+p.x+' '+p.y+')"><rect width="'+boxW+'" height="'+boxH+'" rx="12" stroke="'+g.color+'"/><text class="node-name" x="13" y="25">'+esc(t.name)+'</text><text class="node-meta" x="13" y="48">'+t.fields.length+' campos · '+t.rows.toLocaleString('es-MX')+' registros</text><text class="node-open" x="'+(boxW-19)+'" y="68">↗</text></g>';
}
const tableJson = JSON.stringify(all).replace(/</g, '\\u003c');
const moduleCards = groups.map(g => '<button class="module-chip" data-module="'+esc(g.name)+'"><i style="--c:'+g.color+'"></i>'+esc(g.name)+' <b>'+g.tables.length+'</b></button>').join('');

const stylePolish = `
:root{color-scheme:dark;--bg:#0b1020;--surface:#121a2b;--surface-raised:#1a2540;--line:#303c58;--text:#f3f2ff;--muted:#a6b1c8;--accent:#a78bfa;--accent-soft:#2a2145;--violet:#c4b5fd}
body{background:radial-gradient(ellipse at 12% -10%,#153449 0,transparent 38%),radial-gradient(ellipse at 100% 0%,#1b2440 0,transparent 30%),var(--bg);color:var(--text);line-height:1.5}
.app{max-width:1760px;padding:clamp(16px,2.5vw,36px)}
.top{align-items:center;padding:8px 2px 2px}.eyebrow{display:inline-flex;align-items:center;gap:8px;color:#c4b5fd;background:#211b39;border:1px solid #493c70;border-radius:999px;padding:5px 10px;letter-spacing:.12em}.eyebrow:before{content:"";width:7px;height:7px;border-radius:50%;background:var(--accent);box-shadow:0 0 12px #a78bfa99}h1{font-weight:760;letter-spacing:-.045em}.sub{font-size:14px}.source{line-height:1.8;background:#111a2c;border:1px solid var(--line);border-radius:12px;padding:10px 14px}
.stats{grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;margin:24px 0}.stat,.panel{background:linear-gradient(145deg,#121f31,#0e1827);border-color:#26374c;box-shadow:0 12px 35px #0002}.stat{position:relative;overflow:hidden;padding:18px 20px}.stat:after{content:"";position:absolute;inset:0 auto 0 0;width:3px;background:linear-gradient(var(--accent),transparent);opacity:.85}.stat b{font-size:clamp(23px,2vw,30px);font-variant-numeric:tabular-nums}.stat span{display:block;margin-top:2px;letter-spacing:.025em}
.tabs{gap:6px;border-bottom:1px solid #303c58}.tab{position:relative;padding:12px 16px;color:#9ba7bf;border-radius:9px 9px 0 0;transition:color .16s,background .16s}.tab:hover{color:var(--text);background:#ffffff08}.tab.active{color:#c4b5fd;background:#211c39;border-color:transparent}.tab.active:after{content:"";position:absolute;bottom:-1px;left:12px;right:12px;height:2px;background:var(--accent);border-radius:3px}
.panel{padding:clamp(14px,1.5vw,20px);border-radius:18px}.panel-head{margin-bottom:16px}.panel h2{font-size:17px;letter-spacing:-.015em}.muted{color:var(--muted)}.search{background:#0d1425;border-color:#394663;transition:border-color .16s,box-shadow .16s}.search:focus{border-color:var(--accent);box-shadow:0 0 0 3px #a78bfa24}.btn{background:#1a2540;border-color:#3d4a68;transition:transform .15s,border-color .15s,background .15s}.btn:hover{background:#242e4c;border-color:var(--accent);transform:translateY(-1px)}button:focus-visible,[tabindex]:focus-visible{outline:2px solid var(--accent);outline-offset:3px}
.module-list{gap:9px;margin:12px 0 16px}.module-chip{padding:8px 12px;background:#101a2d;border-color:#34415e;transition:all .16s}.module-chip.active{color:#f1eaff;background:#292143;border-color:var(--accent);box-shadow:0 0 0 2px #a78bfa20}.module-chip b{font-variant-numeric:tabular-nums}
.diagram-scroll{max-height:78vh;border-color:#303c58;border-radius:15px;box-shadow:inset 0 1px #ffffff08;scrollbar-color:#4a5676 #111827}.node rect{transition:fill .16s,stroke-width .16s,filter .16s}.node:hover rect,.node:focus rect,.node.selected rect{stroke:var(--accent);filter:drop-shadow(0 4px 13px #a78bfa55)}.edge{stroke:#909db7;opacity:.58}
.tables-layout{gap:16px}.table-list{border-radius:16px}.table-item{border-radius:9px;margin:2px 0;padding:12px 10px;transition:background .14s,color .14s}.table-item:hover{background:#202d48;color:#fff}.table-item.active{background:#292143;color:#f2ecff;box-shadow:inset 3px 0 var(--accent)}.table-item .pill{background:#101a2d;font-variant-numeric:tabular-nums}.detail-title h2{letter-spacing:-.025em}.pill{background:#111a2c;border-color:#394663}.field-table-wrap{border:1px solid #303c58;border-radius:12px;scrollbar-color:#4a5676 #111827}.field-table{min-width:800px}.field-table th{background:#1a2540;color:#d1d9ea;padding-top:12px;padding-bottom:12px}.field-table tbody tr:nth-child(even) td{background:#ffffff04}.field-table td,.field-table th{border-bottom-color:#303c58}.field-table tr:hover td{background:#202d48}.key{background:#173a39;color:#8ce4ce}.key.fk{background:#30294e;color:#c7baff}.key.none{background:#202c3b;color:#a6b1c8}.footer{padding-top:20px;line-height:1.7}
::-webkit-scrollbar{width:10px;height:10px}::-webkit-scrollbar-track{background:#0c1522;border-radius:8px}::-webkit-scrollbar-thumb{background:#344961;border:2px solid #0c1522;border-radius:8px}::-webkit-scrollbar-thumb:hover{background:#4c6682}
@media(max-width:850px){.app{padding:16px}.stats{gap:10px}.source{display:inline-block;margin-top:14px}.tables-layout{gap:12px}.table-list{max-height:260px}}
@media(max-width:520px){.app{padding:12px}.stats{grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin:16px 0}.stat{padding:13px 14px}.stat b{font-size:22px}.stat span{font-size:11px}.tabs{gap:2px}.tab{padding:10px 11px;font-size:13px}.module-chip{font-size:12px;padding:7px 10px}.diagram-scroll{max-height:68vh}.detail-title{flex-direction:column}.field-table{min-width:740px}}
`;

const relationScript = String.raw`const showBase=showTable;
showTable=function(name){
  showBase(name);
  const t=DB.find(x=>x.name===name);
  if(!t)return;
  const outgoing=t.fks.map(f=>({table:f.to,label:"FK "+f.name+" · "+f.fromCols.join(", ")+" → "+f.toCols.join(", "),kind:"Saliente"}));
  const incoming=DB.flatMap(x=>x.fks.filter(f=>f.to===name).map(f=>({table:x.name,label:"FK "+f.name+" · "+f.fromCols.join(", ")+" → "+f.toCols.join(", "),kind:"Entrante"})));
  const relations=outgoing.concat(incoming);
  const section=document.createElement("section");
  section.style.cssText="margin-top:20px;border-top:1px solid #26374e;padding-top:16px";
  const heading=document.createElement("h3");
  heading.textContent="Relaciones de la tabla ("+relations.length+")";
  section.appendChild(heading);
  if(!relations.length){const empty=document.createElement("p");empty.className="muted";empty.textContent="No hay relaciones FK entrantes o salientes en el DDL.";section.appendChild(empty)}
  for(const relation of relations){
    const row=document.createElement("div");
    row.style.cssText="display:flex;justify-content:space-between;gap:12px;align-items:center;padding:10px 0;border-bottom:1px solid #223047";
    const description=document.createElement("span");
    const direction=document.createElement("small");direction.className="muted";direction.textContent=relation.kind;
    const label=document.createElement("code");label.textContent=relation.label;
    description.append(direction,document.createElement("br"),label);
    const button=document.createElement("button");button.className="btn relation-link";button.textContent=relation.table+" ↗";button.onclick=()=>showTable(relation.table);
    row.append(description,button);section.appendChild(row);
  }
  document.querySelector("#detail").appendChild(section);
};`;

const html = '<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="dark"><meta name="theme-color" content="#0b1020"><title>Nexo de Datos | Diccionario interactivo</title><style>'+ 
'*{box-sizing:border-box}body{margin:0;background:#09111e;color:#edf3fb;font:14px Inter,ui-sans-serif,system-ui,Segoe UI,sans-serif}button,input{font:inherit}.app{max-width:1680px;margin:auto;padding:24px}.top{display:flex;justify-content:space-between;align-items:flex-start;gap:20px}.eyebrow{color:#68d3bb;font-size:11px;letter-spacing:.16em;text-transform:uppercase;font-weight:800}h1{margin:7px 0 4px;font-size:clamp(25px,3vw,38px);letter-spacing:-.04em}.sub{color:#91a2b8;margin:0}.source{color:#8292a8;font-size:12px}.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin:22px 0}.stat,.panel{background:#101b2a;border:1px solid #203047;border-radius:16px}.stat{padding:16px 18px}.stat b{display:block;font-size:25px;letter-spacing:-.03em}.stat span{color:#91a2b8;font-size:12px}.tabs{display:flex;gap:8px;border-bottom:1px solid #223249;margin-bottom:14px}.tab{border:0;background:none;color:#8192a8;padding:12px 15px;cursor:pointer;border-bottom:2px solid transparent}.tab.active{color:#eff6ff;border-color:#57cbb2}.view{display:none}.view.active{display:block}.panel{padding:16px}.panel-head{display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:13px}.panel h2{font-size:16px;margin:0}.muted{color:#91a2b8}.toolbar{display:flex;gap:8px;align-items:center}.search{background:#0b1421;color:#eff6ff;border:1px solid #293a52;border-radius:9px;padding:10px 12px;min-width:240px;outline:none}.search:focus{border-color:#57cbb2}.btn{border:1px solid #293a52;background:#152338;color:#dbe7f5;border-radius:8px;padding:9px 11px;cursor:pointer}.btn:hover,.module-chip:hover{border-color:#57cbb2}.module-list{display:flex;gap:7px;flex-wrap:wrap;margin:9px 0 15px}.module-chip{border:1px solid #293a52;background:#0c1625;color:#d4deeb;border-radius:999px;padding:7px 10px;cursor:pointer}.module-chip i{display:inline-block;width:8px;height:8px;border-radius:50%;background:var(--c);margin-right:7px}.module-chip b{margin-left:5px;color:#8292a8}.diagram-scroll{overflow:auto;max-height:76vh;border:1px solid #202f44;border-radius:13px;background:radial-gradient(#23344a 1px,transparent 1px) 0 0/22px 22px,#0b1523;cursor:grab}.diagram-scroll.dragging{cursor:grabbing}svg{display:block;max-width:none}.edge{fill:none;stroke:#60738b;stroke-width:1.5;opacity:.58}.node rect{fill:#142238;stroke-width:1.5;transition:.15s}.node{cursor:pointer}.node:hover rect,.node:focus rect,.node.selected rect{fill:#1b3049;stroke-width:2.5;filter:drop-shadow(0 3px 9px #0008)}.node-name{fill:#edf4ff;font-size:12px;font-weight:750}.node-meta,.node-open{fill:#93a6bf;font-size:10px}.node-open{fill:#5fd1b7;font-size:13px}.tables-layout{display:grid;grid-template-columns:minmax(220px,290px) 1fr;gap:14px}.table-list{max-height:75vh;overflow:auto}.table-item{display:flex;justify-content:space-between;gap:10px;width:100%;text-align:left;color:#dce7f4;background:transparent;border:0;border-bottom:1px solid #223047;padding:11px 8px;cursor:pointer}.table-item:hover,.table-item.active{background:#17263a;border-radius:8px}.table-item small{display:block;color:#8395ac;margin-top:3px}.detail-title{display:flex;align-items:flex-start;justify-content:space-between;gap:12px}.detail-title h2{font-size:21px}.pill{border:1px solid #2b4059;border-radius:999px;padding:5px 9px;color:#a9b8cb;font-size:11px;white-space:nowrap}.field-table-wrap{overflow:auto;max-height:65vh;margin-top:14px}.field-table{width:100%;border-collapse:collapse;min-width:760px}.field-table th{position:sticky;top:0;background:#132137;color:#a7b7ca;text-align:left;font-size:10px;letter-spacing:.08em;text-transform:uppercase}.field-table td,.field-table th{padding:10px;border-bottom:1px solid #223047;vertical-align:top}.field-table td{color:#dbe5f1}.field-table tr:hover td{background:#142237}.field-table code{color:#9edbcf;font:12px ui-monospace,Consolas,monospace;white-space:pre-wrap;overflow-wrap:anywhere}.key{display:inline-block;background:#1d3448;color:#8fd9c8;border-radius:5px;padding:3px 6px;font-size:10px}.key.fk{color:#bda8ff;background:#2c2647}.key.none{color:#8392a5;background:#1a2534}.empty{padding:28px;color:#92a2b6;text-align:center}.footer{color:#788aa2;font-size:11px;padding:17px 2px}.hidden{display:none!important}@media(max-width:850px){.app{padding:14px}.stats{grid-template-columns:repeat(2,1fr)}.tables-layout{grid-template-columns:1fr}.table-list{max-height:220px}.top{display:block}.source{margin-top:12px}}@media(max-width:520px){.toolbar{flex-wrap:wrap}.search{min-width:0;width:100%}.panel-head{align-items:flex-start;flex-direction:column}.stats{gap:8px}.stat{padding:12px}.stat b{font-size:21px}}'+
' </style></head><body><main class="app"><header class="top"><div><div class="eyebrow">DICCIONARIO INTERACTIVO</div><h1>Nexo de Datos</h1><p class="sub">Explora la estructura de la plataforma de comercio electrónico</p></div><div class="source"><label class="btn" for="backupFile">Seleccionar respaldo SQL</label><input id="backupFile" type="file" accept=".sql,.txt,text/plain"><div id="backupStatus">Respaldo de referencia: '+esc(path.basename(dumpPath))+'</div><br>Conteos del contenido exportado; no son métricas de una instancia en vivo.</div></header>'+ 
'<section class="stats"><div class="stat"><b>'+all.length+'</b><span>tablas</span></div><div class="stat"><b>'+fields.length+'</b><span>campos</span></div><div class="stat"><b>'+all.reduce((n,t)=>n+t.rows,0).toLocaleString('es-MX')+'</b><span>registros exportados</span></div><div class="stat"><b>'+rowsFor('tb_users').toLocaleString('es-MX')+'</b><span>registros de usuarios</span></div><div class="stat"><b>'+rowsFor('tb_products').toLocaleString('es-MX')+'</b><span>registros de productos</span></div><div class="stat"><b>'+all.reduce((n,t)=>n+t.fks.length,0)+'</b><span>relaciones FK</span></div><div class="stat"><b>'+objectCounts.views+'</b><span>vistas</span></div><div class="stat"><b>'+objectCounts.triggers+'</b><span>triggers</span></div><div class="stat"><b>'+objectCounts.procedures+'</b><span>procedimientos</span></div></section>'+
'<nav class="tabs"><button class="tab active" data-view="diagram">Diagrama ER</button><button class="tab" data-view="tables">Tablas y campos</button><button class="tab" id="selectedBackupTab" data-view="backup" hidden>Respaldo seleccionado</button></nav>'+
'<section id="diagram" class="view active"><div class="panel"><div class="panel-head"><div><h2>Modelo entidad-relación</h2><span class="muted">Selecciona una entidad para abrir sus campos y registros.</span></div><div class="toolbar"><input id="diagramSearch" class="search" placeholder="Filtrar entidades…"><button class="btn" id="fit">Restablecer vista</button></div></div><div class="module-list">'+moduleCards+'</div><div class="diagram-scroll" id="diagramScroll"><svg id="erd" xmlns="http://www.w3.org/2000/svg" width="'+svgW+'" height="'+svgH+'" viewBox="0 0 '+svgW+' '+svgH+'"><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#8ba1bb"/></marker></defs>'+groups.map((g,i)=>'<text x="'+(left+i*(boxW+colGap))+'" y="26" fill="'+g.color+'" font-size="12" font-weight="800">'+esc(g.name.toUpperCase())+'</text>').join('')+edgeSvg+nodesSvg+'</svg></div></div></section>'+
'<section id="tables" class="view"><div class="tables-layout"><div class="panel table-list"><div class="panel-head"><h2>Tablas <span class="muted">('+all.length+')</span></h2></div><input id="tableSearch" class="search" style="width:100%;min-width:0" placeholder="Buscar tabla o campo…"><div id="tableList"></div></div><div class="panel" id="detail"><div class="empty">Elige una tabla del listado o haz clic en una entidad del diagrama.</div></div></div></section>'+
'<section id="backup" class="view"><header class="panel"><div class="top"><div><div class="eyebrow">Respaldo seleccionado</div><h1 id="backupDatabase">Respaldo analizado</h1><p class="sub" id="backupFileName"></p></div><div class="source">Se procesa localmente en el navegador; no se sube el respaldo.</div></div></header><section class="stats"><div class="stat"><b id="backupStatTables">0</b><span>tablas</span></div><div class="stat"><b id="backupStatFields">0</b><span>campos</span></div><div class="stat"><b id="backupStatRows">0</b><span>registros exportados</span></div><div class="stat"><b id="backupStatUsers">0</b><span>registros de usuarios</span></div><div class="stat"><b id="backupStatProducts">0</b><span>registros de productos</span></div><div class="stat"><b id="backupStatFks">0</b><span>relaciones FK</span></div><div class="stat"><b id="backupStatViews">0</b><span>vistas</span></div><div class="stat"><b id="backupStatTriggers">0</b><span>triggers</span></div><div class="stat"><b id="backupStatProcedures">0</b><span>procedimientos</span></div></section><div class="panel"><div class="panel-head"><div><h2>Diagrama entidad-relación</h2><span class="muted">Selecciona una entidad para abrir sus campos.</span></div><div class="toolbar"><input id="backupDiagramSearch" class="search" placeholder="Filtrar entidades…"><button class="btn" id="backupFit">Restablecer vista</button></div></div><div class="module-list" id="backupModuleList"></div><div class="diagram-scroll" id="backupDiagramScroll"><svg id="backupErd" xmlns="http://www.w3.org/2000/svg" width="1" height="1" viewBox="0 0 1 1"></svg></div></div><div class="tables-layout"><div class="panel table-list"><div class="panel-head"><h2>Tablas <span class="muted" id="backupTableCount">0</span></h2></div><input id="backupSearch" class="search" style="width:100%;min-width:0" placeholder="Buscar tabla o campo…"><div id="backupTableList"></div></div><div class="panel" id="backupDetail"><div class="empty">Selecciona una tabla para ver sus campos y relaciones.</div></div></div></section><footer class="footer">Los conteos corresponden a filas INSERT y objetos definidos en el respaldo. No equivalen necesariamente al estado actual de MySQL.</footer></main><script>'+
'const DB='+tableJson+';let selected=null;const escHtml=s=>String(s??"").replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\\"":"&quot;"}[c]));'+
'function showTable(name){selected=name;const t=DB.find(x=>x.name===name);if(!t)return;document.querySelectorAll(".node").forEach(n=>n.classList.toggle("selected",n.dataset.table===name));document.querySelectorAll(".table-item").forEach(n=>n.classList.toggle("active",n.dataset.table===name));document.querySelector("#detail").innerHTML="<div class=\\"detail-title\\"><div><h2>"+escHtml(t.name)+"</h2><span class=\\"muted\\">Módulo: "+escHtml(t.module)+"</span></div><div class=\\"pill\\">"+t.fields.length+" campos · "+t.rows.toLocaleString("es-MX")+" registros exportados</div></div><div class=\\"field-table-wrap\\"><table class=\\"field-table\\"><thead><tr><th>Campo</th><th>Tipo / definición SQL</th><th>Claves</th><th>NULL</th><th>DEFAULT</th><th>Índices</th></tr></thead><tbody>"+t.fields.map(f=>"<tr><td><code>"+escHtml(f.name)+"</code></td><td><code>"+escHtml(f.type)+"</code></td><td>"+(f.pk?"<span class=\\"key\\">PK</span> ":"")+(f.fk?"<span class=\\"key fk\\">FK → "+escHtml(f.fk)+"</span>":(!f.pk?"<span class=\\"key none\\">—</span>":""))+"</td><td>"+escHtml(f.nullable)+"</td><td><code>"+escHtml(f.default)+"</code></td><td>"+escHtml(f.indexes||"—")+"</td></tr>").join("")+"</tbody></table></div>";document.querySelector("#tables").classList.add("active");document.querySelector("#diagram").classList.remove("active");document.querySelectorAll(".tab").forEach(b=>b.classList.toggle("active",b.dataset.view==="tables"));}'+
'function renderList(q=""){const root=document.querySelector("#tableList");root.innerHTML="";for(const t of DB){const hit=(t.name+" "+t.fields.map(f=>f.name).join(" ")).toLowerCase().includes(q.toLowerCase());if(!hit)continue;const b=document.createElement("button");b.className="table-item"+(selected===t.name?" active":"");b.dataset.table=t.name;b.innerHTML="<span>"+escHtml(t.name)+"<small>"+t.fields.length+" campos · "+escHtml(t.module)+"</small></span><span class=\\"pill\\">"+t.rows.toLocaleString("es-MX")+"</span>";b.onclick=()=>showTable(t.name);root.appendChild(b)}}'+
'document.querySelectorAll(".tab").forEach(b=>b.onclick=()=>{document.querySelectorAll(".tab").forEach(x=>x.classList.toggle("active",x===b));document.querySelectorAll(".view").forEach(x=>x.classList.toggle("active",x.id===b.dataset.view))});'+
'document.querySelectorAll(".node").forEach(n=>{n.onclick=()=>showTable(n.dataset.table);n.onkeydown=e=>{if(e.key==="Enter"||e.key===" "){e.preventDefault();showTable(n.dataset.table)}}});'+
'document.querySelector("#tableSearch").oninput=e=>renderList(e.target.value);document.querySelector("#diagramSearch").oninput=e=>{const q=e.target.value.toLowerCase();document.querySelectorAll(".node").forEach(n=>{const t=DB.find(x=>x.name===n.dataset.table);const match=(t.name+" "+t.fields.map(f=>f.name).join(" ")).toLowerCase().includes(q);n.classList.toggle("hidden",!match)});document.querySelectorAll(".edge").forEach(e=>e.classList.toggle("hidden",!!q))};'+
'let activeModule="";document.querySelectorAll(".module-chip").forEach(b=>b.onclick=()=>{activeModule=activeModule===b.dataset.module?"":b.dataset.module;document.querySelectorAll(".module-chip").forEach(x=>x.classList.toggle("active",x.dataset.module===activeModule));document.querySelectorAll(".node").forEach(n=>{const t=DB.find(x=>x.name===n.dataset.table);n.classList.toggle("hidden",!!activeModule&&t.module!==activeModule)});document.querySelectorAll(".edge").forEach(e=>e.classList.toggle("hidden",!!activeModule))});'+
'document.querySelector("#fit").onclick=()=>{const s=document.querySelector("#diagramScroll");s.scrollTo({left:0,top:0,behavior:"smooth"});document.querySelectorAll(".node,.edge").forEach(n=>n.classList.remove("hidden"));activeModule="";document.querySelectorAll(".module-chip").forEach(b=>b.classList.remove("active"))};'+
'let drag=null;const sc=document.querySelector("#diagramScroll");sc.onpointerdown=e=>{if(e.target.closest(".node"))return;drag=[e.clientX,e.clientY,sc.scrollLeft,sc.scrollTop];sc.classList.add("dragging");sc.setPointerCapture(e.pointerId)};sc.onpointermove=e=>{if(drag){sc.scrollLeft=drag[2]-(e.clientX-drag[0]);sc.scrollTop=drag[3]-(e.clientY-drag[1])}};sc.onpointerup=()=>{drag=null;sc.classList.remove("dragging")};'+
relationScript+'renderList();</script><script src="backup-picker.js"></script></body></html>';

fs.writeFileSync(outPath, html.replace('</head>', '<style>'+stylePolish+'</style></head>'), 'utf8');
fs.mkdirSync(pagesDictionaryDir, { recursive: true });
fs.copyFileSync(outPath, path.join(pagesDictionaryDir, 'diccionario.html'));
fs.copyFileSync(path.join(base, 'diccionario', 'backup-picker.js'), path.join(pagesDictionaryDir, 'backup-picker.js'));
console.log('Generado: ' + outPath);
console.log('Preparado para GitHub Pages: ' + pagesDir);
console.log(JSON.stringify({
  database: db, tables: all.length, fields: fields.length,
  foreignKeys: all.reduce((n, t) => n + t.fks.length, 0),
  rowsInDump: all.reduce((n, t) => n + t.rows, 0),
  usersInDump: rowsFor('tb_users'), productsInDump: rowsFor('tb_products'),
  views: objectCounts.views, triggers: objectCounts.triggers, procedures: objectCounts.procedures,
  perTable: all.map(t => ({ table: t.name, fields: t.fields.length, rows: t.rows }))
}, null, 2));
