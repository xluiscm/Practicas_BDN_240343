$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourcePath = Join-Path $projectRoot 'backups/respaldo_5casostotalesfinal.sql'
$outputDir = Join-Path $projectRoot 'diccionario'
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
$sql = [System.IO.File]::ReadAllText($sourcePath)
$tableMatches = [regex]::Matches($sql, '(?ms)CREATE TABLE `(?<name>[^`]+)` \((?<body>.*?)\) ENGINE=[^;]+;')

$tables = [System.Collections.Generic.List[object]]::new()
$fields = [System.Collections.Generic.List[object]]::new()
$relationships = [System.Collections.Generic.List[object]]::new()

foreach ($tableMatch in $tableMatches) {
    $tableName = $tableMatch.Groups['name'].Value
    $body = $tableMatch.Groups['body'].Value
    $primaryColumns = @()
    $uniqueKeys = [System.Collections.Generic.List[object]]::new()
    $foreignColumns = [System.Collections.Generic.List[object]]::new()

    $primaryMatch = [regex]::Match($body, 'PRIMARY KEY \((?<columns>[^)]+)\)')
    if ($primaryMatch.Success) {
        $primaryColumns = @([regex]::Matches($primaryMatch.Groups['columns'].Value, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value })
        $uniqueKeys.Add($primaryColumns)
    }
    foreach ($uniqueMatch in [regex]::Matches($body, 'UNIQUE KEY `(?<name>[^`]+)` \((?<columns>[^)]+)\)')) {
        $uniqueKeys.Add(@([regex]::Matches($uniqueMatch.Groups['columns'].Value, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value }))
    }
    foreach ($foreignMatch in [regex]::Matches($body, 'CONSTRAINT `(?<name>[^`]+)` FOREIGN KEY \((?<columns>[^)]+)\) REFERENCES `(?<parent>[^`]+)` \((?<parentColumns>[^)]+)\)(?<options>[^,\r\n]*)')) {
        $localColumns = @([regex]::Matches($foreignMatch.Groups['columns'].Value, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value })
        $parentColumns = @([regex]::Matches($foreignMatch.Groups['parentColumns'].Value, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value })
        $foreignColumns.Add([pscustomobject]@{ Name=$foreignMatch.Groups['name'].Value; Local=$localColumns; Parent=$foreignMatch.Groups['parent'].Value; Remote=$parentColumns })
        $relationships.Add([pscustomobject]@{
            Child=$tableName; Columns=$localColumns; Parent=$foreignMatch.Groups['parent'].Value
            ParentColumns=$parentColumns; Name=$foreignMatch.Groups['name'].Value
            Options=$foreignMatch.Groups['options'].Value
        })
    }

    $tableFields = [System.Collections.Generic.List[object]]::new()
    foreach ($line in ($body -split "`n")) {
        $columnMatch = [regex]::Match($line, '^\s+`(?<name>[^`]+)`\s+(?<definition>.*?)(?:,)?\s*$')
        if (-not $columnMatch.Success) { continue }
        $fieldName = $columnMatch.Groups['name'].Value
        $definition = $columnMatch.Groups['definition'].Value.TrimEnd().TrimEnd(',')
        $typeMatch = [regex]::Match($definition, '^(?<type>(?:enum|set)\(.*?\)|[^\s]+)')
        $sqlType = if ($typeMatch.Success) { $typeMatch.Groups['type'].Value } else { $definition }
        $keys = [System.Collections.Generic.List[string]]::new()
        if ($primaryColumns -contains $fieldName) { $keys.Add('PK') }
        foreach ($foreign in $foreignColumns) {
            if ($foreign.Local -contains $fieldName) { $keys.Add("FK $($foreign.Name)") }
        }
        if ($uniqueColumns -contains $fieldName) { $keys.Add('UNIQUE') }
        if ($keys.Count -eq 0) { $keys.Add('—') }
        $field = [pscustomobject]@{
            tabla=$tableName; campo=$fieldName; tipo_SQL=$sqlType; clave=($keys -join '; ')
            admite_NULL=if ($definition -match '\bNOT NULL\b') { 'No' } else { 'Sí' }
            definicion_SQL=$definition
        }
        $tableFields.Add($field)
        $fields.Add($field)
    }
    $tables.Add([pscustomobject]@{ Name=$tableName; Fields=$tableFields; UniqueKeys=@($uniqueKeys) })
}

$utf8 = [System.Text.UTF8Encoding]::new($false)
$csvLines = $fields | ConvertTo-Csv -NoTypeInformation
[System.IO.File]::WriteAllLines((Join-Path $outputDir 'campos.csv'), $csvLines, $utf8)

$htmlEncode = { param([string]$value) [System.Net.WebUtility]::HtmlEncode($value) }
$dictionary = [System.Text.StringBuilder]::new()
[void]$dictionary.AppendLine('<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Diccionario de datos · db_test_corregida</title>')
[void]$dictionary.AppendLine('<style>body{font:15px system-ui;max-width:1200px;margin:2rem auto;padding:0 1rem;color:#172538;background:#f4f7fb}header,details{background:white;border:1px solid #d7e0ea;border-radius:10px;padding:1rem;margin:.7rem 0}summary{cursor:pointer;font-size:1.05rem}table{border-collapse:collapse;width:100%;margin-top:.8rem}th,td{text-align:left;vertical-align:top;border-bottom:1px solid #d7e0ea;padding:.45rem}code{overflow-wrap:anywhere}input{padding:.65rem;width:min(32rem,90%)}.muted{color:#526477}</style>')
[void]$dictionary.AppendLine("<header><h1>Diccionario de datos: db_test_corregida</h1><p>Fuente: <code>Practica04/backups/respaldo_5casostotalesfinal.sql</code> · $($tables.Count) tablas · $($fields.Count) campos</p><p><a href='campos.csv'>CSV</a> · <a href='diagrama_ere.md'>Diagrama ERE (Mermaid)</a> · <a href='relaciones.html'>Relaciones</a> · <a href='anexo_tecnico.md'>Anexo técnico</a></p><input id='q' placeholder='Buscar tabla o campo'></header>")
foreach ($table in $tables) {
    $tableHtml = & $htmlEncode $table.Name
    [void]$dictionary.AppendLine("<details data-search='$($tableHtml.ToLowerInvariant())'><summary><b>$tableHtml</b> — $($table.Fields.Count) campos</summary><table><thead><tr><th>Campo</th><th>Tipo SQL</th><th>Claves</th><th>NULL</th><th>Definición SQL</th></tr></thead><tbody>")
    foreach ($field in $table.Fields) {
        $nameHtml = & $htmlEncode $field.campo; $typeHtml = & $htmlEncode $field.tipo_SQL
        $keyHtml = & $htmlEncode $field.clave; $definitionHtml = & $htmlEncode $field.definicion_SQL
        [void]$dictionary.AppendLine("<tr data-search='$($nameHtml.ToLowerInvariant()) $($typeHtml.ToLowerInvariant()) $($keyHtml.ToLowerInvariant())'><td><code>$nameHtml</code></td><td><code>$typeHtml</code></td><td>$keyHtml</td><td>$($field.admite_NULL)</td><td><code>$definitionHtml</code></td></tr>")
    }
    [void]$dictionary.AppendLine('</tbody></table></details>')
}
[void]$dictionary.AppendLine('<script>document.querySelector("#q").addEventListener("input",e=>{const q=e.target.value.toLowerCase();document.querySelectorAll("details[data-search]").forEach(d=>{const hit=d.dataset.search.includes(q)||[...d.querySelectorAll("tr[data-search]")].some(r=>r.dataset.search.includes(q));d.hidden=!hit;d.open=!!q&&hit})})</script></html>')
[System.IO.File]::WriteAllText((Join-Path $outputDir 'diccionario.html'), $dictionary.ToString(), $utf8)

$relationHtml = [System.Text.StringBuilder]::new()
[void]$relationHtml.AppendLine('<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Relaciones · db_test_corregida</title>')
[void]$relationHtml.AppendLine('<style>:root{color-scheme:light dark}body{font:16px/1.5 system-ui;max-width:1200px;margin:2rem auto;padding:0 1rem;background:#f2f5f9;color:#172538}h1{margin-bottom:.3rem}.muted{color:#56677d}.wrap{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:.8rem}.node,.edge{background:white;border:1px solid #d7e0ea;border-radius:12px;padding:.9rem}.node{border-top:3px solid #245f8e}.edge{border-left:4px solid #6c55a3}.node b{color:#245f8e}.edge code{font-family:ui-monospace,monospace}@media(prefers-color-scheme:dark){body{background:#101821;color:#e5edf5}.node,.edge{background:#18232e;border-color:#344453}.node b{color:#74b6e9}.muted{color:#b0bfce}}</style>')
[void]$relationHtml.AppendLine("<h1>Relaciones entre tablas</h1><p class='muted'>Fuente: <code>respaldo_5casostotalesfinal.sql</code> · $($tables.Count) tablas · $($relationships.Count) claves foráneas. Las relaciones parten de la tabla que contiene la FK hacia la tabla referenciada.</p><p><a href='diccionario.html'>Diccionario</a> · <a href='diagrama_ere.html'>Diagrama ERE</a> · <a href='campos.csv'>CSV</a></p><input id='q' placeholder='Filtrar tabla o relación'><h2>Entidades</h2><section class='wrap'>")
foreach ($table in $tables) {
    $nameHtml = & $htmlEncode $table.Name
    [void]$relationHtml.AppendLine("<article class='node' data-search='$($nameHtml.ToLowerInvariant())'><b>$nameHtml</b><br>$($table.Fields.Count) campos</article>")
}
[void]$relationHtml.AppendLine('</section><h2>Relaciones (claves foráneas)</h2><section class="wrap">')
foreach ($relationship in $relationships) {
    $childHtml = & $htmlEncode $relationship.Child; $parentHtml = & $htmlEncode $relationship.Parent
    $nameHtml = & $htmlEncode $relationship.Name
    $columnHtml = & $htmlEncode ($relationship.Columns -join ', ')
    $parentColumnHtml = & $htmlEncode ($relationship.ParentColumns -join ', ')
    $search = "$childHtml $parentHtml $nameHtml $columnHtml $parentColumnHtml".ToLowerInvariant()
    [void]$relationHtml.AppendLine("<article class='edge' data-search='$search'><b>$childHtml</b> ⟶ <b>$parentHtml</b><p><code>$columnHtml</code> → <code>$parentColumnHtml</code></p><small>$nameHtml</small></article>")
}
[void]$relationHtml.AppendLine('</section><script>document.querySelector("#q").addEventListener("input",e=>document.querySelectorAll("[data-search]").forEach(x=>x.hidden=!x.dataset.search.includes(e.target.value.toLowerCase())))</script></html>')
[System.IO.File]::WriteAllText((Join-Path $outputDir 'relaciones.html'), $relationHtml.ToString(), $utf8)

$erd = [System.Text.StringBuilder]::new()
[void]$erd.AppendLine('%% ERE generado desde las claves primarias y foráneas del respaldo final de Practica04.')
[void]$erd.AppendLine('%% Los atributos se limitan a PK/FK para mantener legible el diagrama; el diccionario incluye todos los campos.')
[void]$erd.AppendLine('erDiagram')
foreach ($table in $tables) {
    $keyFields = @($table.Fields | Where-Object { $_.clave -match '(^|; )(PK|FK)' })
    if ($keyFields.Count -eq 0) { continue }
    [void]$erd.AppendLine("    $($table.Name) {")
    foreach ($field in $keyFields) {
        $baseType = if ($field.tipo_SQL -match '^(bigint|int|smallint|tinyint|mediumint)') { 'int' } elseif ($field.tipo_SQL -match '^(decimal|float|double)') { 'decimal' } elseif ($field.tipo_SQL -match '^(bit|bool|boolean)') { 'boolean' } elseif ($field.tipo_SQL -match '^(date|datetime|timestamp|time)') { 'datetime' } else { 'string' }
        $markers = @(); if ($field.clave -match '(^|; )PK') { $markers += 'PK' }; if ($field.clave -match '(^|; )FK') { $markers += 'FK' }
        [void]$erd.AppendLine("        $baseType $($field.campo) $($markers -join ',')")
    }
    [void]$erd.AppendLine('    }')
}
foreach ($relationship in $relationships) {
    $childTable = $tables | Where-Object Name -EQ $relationship.Child
    $fieldDefinitions = @($childTable.Fields | Where-Object { $relationship.Columns -contains $_.campo })
    $parentCardinality = if ($fieldDefinitions.admite_NULL -contains 'Sí') { 'o|' } else { '||' }
    $isUniqueForeignKey = $false
    foreach ($uniqueKey in $childTable.UniqueKeys) {
        if ($uniqueKey.Count -eq $relationship.Columns.Count -and @($relationship.Columns | Where-Object { $uniqueKey -notcontains $_ }).Count -eq 0) { $isUniqueForeignKey = $true }
    }
    $childCardinality = if ($isUniqueForeignKey) { 'o|' } else { 'o{' }
    $label = ($relationship.Name -replace '[^A-Za-z0-9_]', '_')
    [void]$erd.AppendLine("    $($relationship.Parent) $parentCardinality--$childCardinality $($relationship.Child) : $label")
}
$erdDocument = [System.Text.StringBuilder]::new()
[void]$erdDocument.AppendLine('# Diagrama ERE — Práctica 04')
[void]$erdDocument.AppendLine('')
[void]$erdDocument.AppendLine('Fuente: respaldo_5casostotalesfinal.sql. El diagrama muestra atributos PK/FK y las relaciones declaradas por el DDL de db_test_corregida.')
[void]$erdDocument.AppendLine('')
[void]$erdDocument.AppendLine('```mermaid')
[void]$erdDocument.Append($erd.ToString())
[void]$erdDocument.AppendLine('```')
[System.IO.File]::WriteAllText((Join-Path $outputDir 'diagrama_ere.md'), $erdDocument.ToString(), $utf8)

$diagramHtml = @"
<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Diagrama ERE · Práctica 04</title>
<style>body{font:16px/1.5 system-ui,sans-serif;margin:0;background:#0b1020;color:#eef2ff}header{padding:1rem 2rem}a{color:#c4b5fd}.diagram{overflow:auto;padding:1rem}#diagram{min-width:1200px;background:#fff;color:#172033;border-radius:12px;padding:1rem} .mermaid{display:flex;justify-content:center}</style>
<script type="module">import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';mermaid.initialize({startOnLoad:true,theme:'default',er:{diagramPadding:24}});</script></head><body>
<header><h1>Diagrama ERE — Práctica 04</h1><p>Fuente: respaldo_5casostotalesfinal.sql. Incluye atributos PK/FK y relaciones declaradas en el DDL.</p><nav><a href="diccionario.html">Diccionario</a> · <a href="relaciones.html">Relaciones</a> · <a href="https://github.com/xluiscm/Practicas_BDN_240343/blob/master/Practica04/diccionario/diagrama_ere.md">Fuente Mermaid en GitHub</a></nav></header>
<main class="diagram"><pre id="diagram" class="mermaid">
$($erd.ToString())
</pre></main></body></html>
"@
[System.IO.File]::WriteAllText((Join-Path $outputDir 'diagrama_ere.html'), $diagramHtml, $utf8)

$annex = [System.Collections.Generic.List[string]]::new()
$annex.Add('# Anexo técnico — db_test_corregida')
$annex.Add('')
$annex.Add('Fuente única: respaldo_5casostotalesfinal.sql. Se documenta el DDL; se excluyen los valores de las filas.')
$annex.Add('')
$annex.Add("Inventario: $($tables.Count) tablas, $($fields.Count) campos y $($relationships.Count) claves foráneas.")
$annex.Add('')
$annex.Add('## Tablas')
$annex.Add('')
foreach ($table in $tables) { $annex.Add("- $($table.Name): $($table.Fields.Count) campos") }
$annex.Add('')
$annex.Add('El diccionario HTML y campos.csv detallan tipos, nulabilidad, definiciones SQL y claves. El ERE Mermaid representa los atributos PK/FK y las relaciones declaradas.')
[System.IO.File]::WriteAllLines((Join-Path $outputDir 'anexo_tecnico.md'), $annex, $utf8)

# Publica las vistas HTML en GitHub Pages; el respaldo SQL y el CSV no se copian a docs/.
$pagesDir = Join-Path $projectRoot '..\docs'
$publicDir = Join-Path $pagesDir 'practica04'
New-Item -ItemType Directory -Force -Path $publicDir | Out-Null
$githubBase = 'https://github.com/xluiscm/Practicas_BDN_240343/blob/master/Practica04/diccionario/'
$publicDictionary = [System.IO.File]::ReadAllText((Join-Path $outputDir 'diccionario.html'))
$publicDictionary = $publicDictionary.Replace("href='campos.csv'", "href='${githubBase}campos.csv'")
$publicDictionary = $publicDictionary.Replace("href='diagrama_ere.md'", "href='diagrama_ere.html'")
$publicDictionary = $publicDictionary.Replace("href='anexo_tecnico.md'", "href='${githubBase}anexo_tecnico.md'")
[System.IO.File]::WriteAllText((Join-Path $publicDir 'diccionario.html'), $publicDictionary, $utf8)
$publicRelations = [System.IO.File]::ReadAllText((Join-Path $outputDir 'relaciones.html'))
$publicRelations = $publicRelations.Replace("href='campos.csv'", "href='${githubBase}campos.csv'")
[System.IO.File]::WriteAllText((Join-Path $publicDir 'relaciones.html'), $publicRelations, $utf8)
[System.IO.File]::Copy((Join-Path $outputDir 'diagrama_ere.html'), (Join-Path $publicDir 'diagrama_ere.html'), $true)

Write-Output "Generado: $($tables.Count) tablas, $($fields.Count) campos y $($relationships.Count) claves foráneas en $outputDir"
Write-Output "Publicado para GitHub Pages: $publicDir"
