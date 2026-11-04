from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "Practica03" / "backups" / "respaldo_04112026.sql"
TARGET = ROOT / "Practica03" / "backups" / "27102026.sql"
OUTPUT = ROOT / "Practica03" / "backups" / "27102026_datos_04112026.sql"

DATA_TABLES = (
    "tb_products",
    "tb_users",
    "tbc_categories",
    "tbd_products_categories",
)
SOURCE_ONLY_DATA_TABLES = (
    "tbc_app_roles",
    "tbc_gen_email_domains",
    "tbc_gen_family_names",
    "tbc_gen_given_names",
    "tbc_gen_phone_area_codes",
)
INSERT_RE = re.compile(rb"^INSERT INTO `([^`]+)` VALUES")


def insert_lines(path: Path) -> dict[bytes, list[bytes]]:
    result: dict[bytes, list[bytes]] = {}
    for line in path.read_bytes().splitlines(keepends=True):
        match = INSERT_RE.match(line)
        if match:
            result.setdefault(match.group(1), []).append(line)
    return result


source_inserts = insert_lines(SOURCE)
target_lines = TARGET.read_bytes().splitlines(keepends=True)

for table in (b"tb_logs", *(name.encode() for name in DATA_TABLES)):
    if table not in source_inserts:
        raise RuntimeError(f"La tabla origen no tiene INSERT: {table.decode()}")
for table in SOURCE_ONLY_DATA_TABLES:
    if table.encode() not in source_inserts:
        raise RuntimeError(f"La tabla auxiliar origen no tiene INSERT: {table}")

source_lines = SOURCE.read_bytes().splitlines(keepends=True)


def create_table_ddl(table: str) -> bytes:
    marker = f"CREATE TABLE `{table}` (".encode()
    start = next((i for i, line in enumerate(source_lines) if line.strip() == marker), None)
    if start is None:
        raise RuntimeError(f"No se encontro CREATE TABLE para {table}")
    end = next(
        (i for i in range(start, len(source_lines)) if source_lines[i].startswith(b") ENGINE=")),
        None,
    )
    if end is None:
        raise RuntimeError(f"No se encontro el final de CREATE TABLE para {table}")
    return b"".join(source_lines[start : end + 1])

log_stage = b"""\n-- Se conservan ambos campos de operacion del respaldo origen en columnas compatibles.\nALTER TABLE `tb_logs`\n  MODIFY COLUMN `description` text NULL,\n  ADD COLUMN `source_table_operation` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,\n  ADD COLUMN `operation_description` text NULL;\nCREATE TEMPORARY TABLE `tmp_pr04_source_logs` (\n  `ID` int NOT NULL,\n  `table_name` varchar(100) NOT NULL,\n  `operation` enum('Create','Read','Update','Delete') NOT NULL,\n  `db_user` varchar(80) NOT NULL,\n  `description` text,\n  `operation_date` datetime NOT NULL,\n  `operation_status` bit(1) DEFAULT b'1',\n  `table_operation` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,\n  `operation_description` text\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;\n"""
for line in source_inserts[b"tb_logs"]:
    log_stage += line.replace(b"INSERT INTO `tb_logs`", b"INSERT INTO `tmp_pr04_source_logs`", 1)
log_stage += b"""INSERT INTO `tb_logs`\n  (`ID`, `table_name`, `table_operation`, `db_user`, `description`, `operation_date`, `operation_status`, `source_table_operation`, `operation_description`)\nSELECT `ID`, `table_name`, `operation`, `db_user`, `description`,\n       `operation_date`, `operation_status`, `table_operation`, `operation_description`\nFROM `tmp_pr04_source_logs`;\nDROP TEMPORARY TABLE `tmp_pr04_source_logs`;\n"""

output_lines: list[bytes] = []
intro = (
    b"-- Datos transferidos desde respaldo_04112026.sql; estructura conservada de 27102026.sql.\n"
    b"-- IDs, usuarios y valores de fecha/hora se conservan. En tb_logs solo se adapta el formato de columnas.\n"
    b"-- Se agregan las tablas auxiliares de origen que no existen en el esquema destino.\n"
)
replaced: set[bytes] = set()
logs_unlocked = False
log_inserts_seen = False

for line in target_lines:
    match = INSERT_RE.match(line)
    if match:
        table = match.group(1)
        if table == b"tb_logs":
            log_inserts_seen = True
            continue
        if table in (name.encode() for name in DATA_TABLES):
            if table not in replaced:
                output_lines.extend(source_inserts[table])
                replaced.add(table)
            continue
    output_lines.append(line)
    if log_inserts_seen and not logs_unlocked and line.strip() == b"UNLOCK TABLES;":
        output_lines.append(log_stage)
        logs_unlocked = True

if replaced != {name.encode() for name in DATA_TABLES}:
    missing = {name.decode() for name in DATA_TABLES} - {name.decode() for name in replaced}
    raise RuntimeError(f"No se encontraron bloques destino para: {', '.join(sorted(missing))}")
if not logs_unlocked:
    raise RuntimeError("No se encontro el final de la seccion de datos de tb_logs")

output_lines.insert(0, intro)
output_lines.append(b"\n-- Tablas auxiliares con datos del respaldo origen que no existen en el destino.\n")
for table in SOURCE_ONLY_DATA_TABLES:
    output_lines.append(create_table_ddl(table))
    output_lines.append(b"\n")
    output_lines.extend(source_inserts[table.encode()])
OUTPUT.write_bytes(b"".join(output_lines))
print(f"Archivo generado: {OUTPUT}")
print(f"Sentencias tb_logs de origen: {len(source_inserts[b'tb_logs'])}")
for table in DATA_TABLES:
    print(f"Sentencias {table} de origen: {len(source_inserts[table.encode()])}")
for table in SOURCE_ONLY_DATA_TABLES:
    print(f"Tabla auxiliar agregada: {table} ({len(source_inserts[table.encode()])} INSERT)")
