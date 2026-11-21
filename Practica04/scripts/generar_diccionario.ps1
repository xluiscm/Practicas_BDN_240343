$ErrorActionPreference = 'Stop'

# Compatibilidad para quienes ya utilizaban el comando PowerShell.
# El generador Node.js mantiene el mismo explorador y diagrama de Práctica 03.
$generator = Join-Path $PSScriptRoot 'generar_diccionario_interactivo.js'
& node $generator @args
if ($LASTEXITCODE -ne 0) { throw "Falló generar_diccionario_interactivo.js (código $LASTEXITCODE)." }
