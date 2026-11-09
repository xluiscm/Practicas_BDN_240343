(() => {
  const input = document.querySelector('#backupFile');
  if (!input) return;

  const status = document.querySelector('#backupStatus');
  const tab = document.querySelector('#selectedBackupTab');
  const list = document.querySelector('#backupTableList');
  const detail = document.querySelector('#backupDetail');
  let tables = [];
  const categories = [
    { name: 'Usuarios', color: '#48DCC6', test: n => /user|people|address/i.test(n) },
    { name: 'Catálogo', color: '#75A7FF', test: n => /product|categor/i.test(n) },
    { name: 'Compras', color: '#FFC36E', test: n => /order|cart|shipment/i.test(n) },
    { name: 'Pagos', color: '#B99AFF', test: n => /payment/i.test(n) },
    { name: 'Devoluciones', color: '#FF829D', test: n => /return|refund|cancellation/i.test(n) },
    { name: 'Auditoría', color: '#A8B7CC', test: n => /logs/i.test(n) }
  ];
  const moduleList = document.querySelector('#backupModuleList');
  const svg = document.querySelector('#backupErd');
  const diagramScroll = document.querySelector('#backupDiagramScroll');
  const esc = value => String(value ?? '').replace(/[&<>"']/g, c => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
  const columns = text => [...text.matchAll(/`((?:``|[^`])+)`/g)].map(m => m[1].replace(/``/g, '`'));

  function splitDefinitions(text) {
    const result = [];
    let start = 0, depth = 0, quote = '', escaped = false;
    for (let i = 0; i < text.length; i++) {
      const c = text[i];
      if (quote) {
        if (escaped) escaped = false;
        else if (c === '\\') escaped = true;
        else if (c === quote) {
          if (text[i + 1] === quote) i++;
          else quote = '';
        }
        continue;
      }
      if (c === "'" || c === '"' || c === '`') { quote = c; continue; }
      if (c === '(') depth++;
      else if (c === ')') depth--;
      else if (c === ',' && depth === 0) { result.push(text.slice(start, i).trim()); start = i + 1; }
    }
    if (text.slice(start).trim()) result.push(text.slice(start).trim());
    return result;
  }

  function countTuples(sql, start) {
    let depth = 0, quote = '', escaped = false, count = 0, i = start;
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
      if (c === "'" || c === '"' || c === '`') { quote = c; continue; }
      if (c === '(') { if (depth === 0) count++; depth++; }
      else if (c === ')') depth--;
      else if (c === ';' && depth === 0) break;
    }
    return { count, next: i + 1 };
  }

  function countObjects(source, type) {
    const normalized = source
      .replace(/\/\*!\d+\s*([\s\S]*?)\*\//g, '$1')
      .replace(/\bDEFINER\s*=\s*(?:`[^`]*`|'[^']*'|[^\s@]+)@(?:`[^`]*`|'[^']*'|[^\s]+)\s*/gi, '');
    const patterns = {
      VIEW: /\bCREATE\s+(?:(?:OR\s+REPLACE)\s+)?(?:ALGORITHM\s*=\s*\w+\s+)?(?:SQL\s+SECURITY\s+\w+\s+)?VIEW\s+`([^`]+)`/gi,
      TRIGGER: /\bCREATE\s+TRIGGER\s+`([^`]+)`/gi,
      PROCEDURE: /\bCREATE\s+PROCEDURE\s+`([^`]+)`/gi
    };
    return new Set([...normalized.matchAll(patterns[type])].map(match => match[1].toLowerCase())).size;
  }

  function parseDump(sql) {
    const byName = new Map();
    const ddl = /CREATE TABLE\s+`([^`]+)`\s*\(([\s\S]*?)\)\s*ENGINE\s*=/g;
    let m;
    while ((m = ddl.exec(sql))) {
      const table = { name: m[1], fields: [], fks: [], rows: 0 };
      for (const part of splitDefinitions(m[2])) {
        const column = part.match(/^`((?:``|[^`])+)`\s+([\s\S]+)$/);
        if (column) {
          const type = column[2].trim();
          const nullable = !/\bNOT NULL\b/i.test(type);
          const def = type.match(/\bDEFAULT\s+((?:_binary\s+)?(?:b)?'(?:\\.|''|[^'])*'|[^\s,]+)/i);
          table.fields.push({ name: column[1].replace(/``/g, '`'), type,
            nullable: nullable ? 'Sí' : 'No', pk: false, fk: '',
            default: def ? def[1] : (nullable ? 'NULL' : '—'),
            auto: /\bAUTO_INCREMENT\b/i.test(type), indexes: '' });
          continue;
        }
        let key = part.match(/^PRIMARY KEY\s*\(([\s\S]+?)\)/i);
        if (key) {
          for (const name of columns(key[1])) {
            const field = table.fields.find(x => x.name === name);
            if (field) { field.pk = true; field.indexes = 'PRIMARY KEY'; }
          }
          continue;
        }
        key = part.match(/^(?:UNIQUE\s+)?(?:KEY|INDEX)\s+`([^`]+)`\s*\(([\s\S]+?)\)/i);
        if (key) {
          for (const name of columns(key[2])) {
            const field = table.fields.find(x => x.name === name);
            if (field) field.indexes = [field.indexes, key[1]].filter(Boolean).join('; ');
          }
          continue;
        }
        const fk = part.match(/^CONSTRAINT\s+`([^`]+)`\s+FOREIGN KEY\s*\(([^)]+)\)\s+REFERENCES\s+`([^`]+)`\s*\(([^)]+)\)([\s\S]*)$/i);
        if (fk) {
          const from = columns(fk[2]), to = columns(fk[4]), rules = fk[5];
          table.fks.push({ name: fk[1], from: table.name, to: fk[3], fromCols: from, toCols: to,
            deleteRule: (rules.match(/ON DELETE\s+(CASCADE|SET NULL|RESTRICT|NO ACTION|SET DEFAULT)/i) || [])[1] || 'NO ACTION',
            updateRule: (rules.match(/ON UPDATE\s+(CASCADE|SET NULL|RESTRICT|NO ACTION|SET DEFAULT)/i) || [])[1] || 'NO ACTION' });
        }
      }
      byName.set(table.name, table);
    }

    const inserts = /^INSERT INTO `([^`]+)`[\s\S]*?\bVALUES\b/gm;
    while ((m = inserts.exec(sql))) {
      const table = byName.get(m[1]);
      const counted = countTuples(sql, inserts.lastIndex);
      if (table) table.rows += counted.count;
      inserts.lastIndex = counted.next;
    }

    const all = [...byName.values()];
    for (const table of all) {
      table.module = (categories.find(c => c.test(table.name)) || categories[0]).name;
      for (const fk of table.fks) fk.fromCols.forEach((name, i) => {
        const field = table.fields.find(x => x.name === name);
        if (field) field.fk = fk.to + '.' + fk.toCols[i];
      });
    }
    return {
      database: (sql.match(/^USE\s+`([^`]+)`/im) || [,'desconocida'])[1],
      tables: all,
      objects: {
        views: countObjects(sql, 'VIEW'),
        triggers: countObjects(sql, 'TRIGGER'),
        procedures: countObjects(sql, 'PROCEDURE')
      }
    };
  }

  function renderList(query = '') {
    list.innerHTML = '';
    for (const table of tables) {
      if (!(table.name + ' ' + table.fields.map(x => x.name).join(' ')).toLowerCase().includes(query.toLowerCase())) continue;
      const button = document.createElement('button');
      button.className = 'table-item'; button.dataset.table = table.name;
      button.innerHTML = '<span>' + esc(table.name) + '<small>' + table.fields.length + ' campos · ' + esc(table.module) + '</small></span><span class="pill">' + table.rows.toLocaleString('es-MX') + '</span>';
      button.onclick = () => renderDetail(table);
      list.appendChild(button);
    }
  }

  function renderDiagram() {
    const groups = categories.map(category => ({ ...category, tables: tables.filter(t => t.module === category.name) })).filter(g => g.tables.length);
    const boxW = 205, boxH = 78, colGap = 54, rowGap = 32, left = 45, top = 54;
    const positions = new Map();
    groups.forEach((group, col) => group.tables.forEach((table, row) => positions.set(table.name, {
      x: left + col * (boxW + colGap), y: top + row * (boxH + rowGap)
    })));
    const width = left * 2 + groups.length * boxW + Math.max(0, groups.length - 1) * colGap;
    const rows = Math.max(1, ...groups.map(g => g.tables.length));
    const height = top * 2 + rows * boxH + (rows - 1) * rowGap;
    const edges = [];
    for (const table of tables) for (const fk of table.fks) {
      const a = positions.get(fk.from), b = positions.get(fk.to);
      if (!a || !b) continue;
      if (fk.from === fk.to) {
        const x = a.x + boxW, y = a.y + 37;
        edges.push('<path class="edge" d="M ' + x + ' ' + y + ' C ' + (x + 85) + ' ' + (y - 38) + ', ' + (x + 85) + ' ' + (y + 42) + ', ' + x + ' ' + (y + 48) + '" marker-end="url(#backupArrow)"><title>' + esc(fk.name) + ': autorreferencia</title></path>');
      } else {
        const ax = a.x + boxW, ay = a.y + boxH / 2, bx = b.x, by = b.y + boxH / 2, mid = (ax + bx) / 2;
        edges.push('<path class="edge" d="M ' + ax + ' ' + ay + ' C ' + mid + ' ' + ay + ', ' + mid + ' ' + by + ', ' + bx + ' ' + by + '" marker-end="url(#backupArrow)"><title>' + esc(fk.name) + ': ' + esc(fk.fromCols.join(', ')) + ' → ' + esc(fk.to) + '.' + esc(fk.toCols.join(', ')) + '</title></path>');
      }
    }
    const nodes = tables.map(table => {
      const p = positions.get(table.name), group = groups.find(g => g.name === table.module);
      return '<g class="node" tabindex="0" role="button" data-table="' + esc(table.name) + '" transform="translate(' + p.x + ' ' + p.y + ')"><rect width="' + boxW + '" height="' + boxH + '" rx="12" stroke="' + group.color + '"/><text class="node-name" x="13" y="25">' + esc(table.name) + '</text><text class="node-meta" x="13" y="48">' + table.fields.length + ' campos · ' + table.rows.toLocaleString('es-MX') + ' registros</text><text class="node-open" x="' + (boxW - 19) + '" y="68">↗</text></g>';
    }).join('');
    svg.setAttribute('width', width); svg.setAttribute('height', height); svg.setAttribute('viewBox', '0 0 ' + width + ' ' + height);
    svg.innerHTML = '<defs><marker id="backupArrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#8ba1bb"/></marker></defs>' + groups.map((g, i) => '<text x="' + (left + i * (boxW + colGap)) + '" y="26" fill="' + g.color + '" font-size="12" font-weight="800">' + esc(g.name.toUpperCase()) + '</text>').join('') + edges.join('') + nodes;
    moduleList.innerHTML = groups.map(g => '<button class="module-chip" data-module="' + esc(g.name) + '"><i style="--c:' + g.color + '"></i>' + esc(g.name) + ' <b>' + g.tables.length + '</b></button>').join('');
    svg.querySelectorAll('.node').forEach(node => {
      const open = () => {
        renderDetail(tables.find(t => t.name === node.dataset.table));
        detail.scrollIntoView({ behavior: 'smooth', block: 'start' });
      };
      node.onclick = open;
      node.onkeydown = event => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); open(); } };
    });
    moduleList.querySelectorAll('.module-chip').forEach(button => button.onclick = () => {
      const active = button.classList.contains('active');
      moduleList.querySelectorAll('.module-chip').forEach(x => x.classList.remove('active'));
      if (!active) button.classList.add('active');
      svg.querySelectorAll('.node').forEach(node => {
        const table = tables.find(t => t.name === node.dataset.table);
        node.classList.toggle('hidden', !active && table.module !== button.dataset.module);
      });
      svg.querySelectorAll('.edge').forEach(edge => edge.classList.toggle('hidden', !active));
    });
    document.querySelector('#backupDiagramSearch').value = '';
    document.querySelector('#backupDiagramSearch').oninput = event => {
      const query = event.target.value.toLowerCase();
      svg.querySelectorAll('.node').forEach(node => {
        const table = tables.find(t => t.name === node.dataset.table);
        node.classList.toggle('hidden', !(table.name + ' ' + table.fields.map(f => f.name).join(' ')).toLowerCase().includes(query));
      });
      svg.querySelectorAll('.edge').forEach(edge => edge.classList.toggle('hidden', !!query));
    };
    document.querySelector('#backupFit').onclick = () => {
      diagramScroll.scrollTo({ left: 0, top: 0, behavior: 'smooth' });
      svg.querySelectorAll('.node,.edge').forEach(node => node.classList.remove('hidden'));
      moduleList.querySelectorAll('.module-chip').forEach(button => button.classList.remove('active'));
      document.querySelector('#backupDiagramSearch').value = '';
    };
  }

  function renderDetail(table) {
    if (!table) { detail.innerHTML = '<div class="empty">Selecciona una tabla para ver sus campos y relaciones.</div>'; return; }
    const outgoing = table.fks.map(f => 'Saliente: ' + f.name + ' · ' + f.fromCols.join(', ') + ' → ' + f.to + '.' + f.toCols.join(', '));
    const incoming = tables.flatMap(t => t.fks.filter(f => f.to === table.name).map(f => 'Entrante: ' + f.name + ' · ' + f.from + '.' + f.fromCols.join(', ') + ' → ' + f.toCols.join(', ')));
    detail.innerHTML = '<div class="detail-title"><div><h2>' + esc(table.name) + '</h2><span class="muted">Módulo: ' + esc(table.module) + '</span></div><div class="pill">' + table.fields.length + ' campos · ' + table.rows.toLocaleString('es-MX') + ' registros exportados</div></div><div class="field-table-wrap"><table class="field-table"><thead><tr><th>Campo</th><th>Tipo / definición SQL</th><th>Claves</th><th>NULL</th><th>DEFAULT</th><th>Índices</th></tr></thead><tbody>' + table.fields.map(f => '<tr><td><code>' + esc(f.name) + '</code></td><td><code>' + esc(f.type) + '</code></td><td>' + (f.pk ? '<span class="key">PK</span> ' : '') + (f.fk ? '<span class="key fk">FK → ' + esc(f.fk) + '</span>' : (!f.pk ? '<span class="key none">—</span>' : '')) + '</td><td>' + esc(f.nullable) + '</td><td><code>' + esc(f.default) + '</code></td><td>' + esc(f.indexes || '—') + '</td></tr>').join('') + '</tbody></table></div><section style="margin-top:18px"><h3>Relaciones (' + (outgoing.length + incoming.length) + ')</h3>' + (outgoing.concat(incoming).map(x => '<p><code>' + esc(x) + '</code></p>').join('') || '<p class="muted">Sin relaciones FK.</p>') + '</section>';
    list.querySelectorAll('.table-item').forEach(b => b.classList.toggle('active', b.dataset.table === table.name));
    document.querySelectorAll('#backupErd .node').forEach(n => n.classList.toggle('selected', n.dataset.table === table.name));
  }

  input.addEventListener('change', async event => {
    const file = event.target.files && event.target.files[0];
    if (!file) return;
    status.textContent = 'Leyendo ' + file.name + '…';
    try {
      const parsed = parseDump(await file.text());
      if (!parsed.tables.length) throw new Error('No encontré instrucciones CREATE TABLE en el archivo.');
      tables = parsed.tables;
      const rowCount = tables.reduce((n, t) => n + t.rows, 0);
      const fieldCount = tables.reduce((n, t) => n + t.fields.length, 0);
      const fkCount = tables.reduce((n, t) => n + t.fks.length, 0);
      document.querySelector('#backupDatabase').textContent = 'Base de datos: ' + parsed.database;
      document.querySelector('#backupFileName').textContent = file.name;
      document.querySelector('#backupStatTables').textContent = tables.length.toLocaleString('es-MX');
      document.querySelector('#backupStatFields').textContent = fieldCount.toLocaleString('es-MX');
      document.querySelector('#backupStatRows').textContent = rowCount.toLocaleString('es-MX');
      document.querySelector('#backupStatUsers').textContent = (tables.find(t => t.name.toLowerCase() === 'tb_users')?.rows || 0).toLocaleString('es-MX');
      document.querySelector('#backupStatProducts').textContent = (tables.find(t => t.name.toLowerCase() === 'tb_products')?.rows || 0).toLocaleString('es-MX');
      document.querySelector('#backupStatFks').textContent = fkCount.toLocaleString('es-MX');
      document.querySelector('#backupStatViews').textContent = parsed.objects.views.toLocaleString('es-MX');
      document.querySelector('#backupStatTriggers').textContent = parsed.objects.triggers.toLocaleString('es-MX');
      document.querySelector('#backupStatProcedures').textContent = parsed.objects.procedures.toLocaleString('es-MX');
      document.querySelector('#backupTableCount').textContent = tables.length.toLocaleString('es-MX');
      renderList(document.querySelector('#backupSearch').value);
      renderDiagram();
      renderDetail(null);
      tab.textContent = 'Respaldo: ' + file.name;
      tab.hidden = false;
      tab.click();
      status.textContent = 'Respaldo cargado localmente. El archivo no se envía a ningún servidor.';
    } catch (error) {
      status.textContent = 'No se pudo leer el respaldo: ' + error.message;
    }
  });
  document.querySelector('#backupSearch').addEventListener('input', event => renderList(event.target.value));
})();
