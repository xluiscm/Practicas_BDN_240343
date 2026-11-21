#!/usr/bin/env python3
"""Crea y valida plantillas CSV para cargar 10,000 productos y usuarios en db_test.

Uso:
  python preparar_csv_productos_usuarios.py
  python preparar_csv_productos_usuarios.py --directorio "C:/Users/ti_la/Downloads"
  python preparar_csv_productos_usuarios.py --validar --directorio "C:/Users/ti_la/Downloads"

La primera ejecución crea productos.csv y usuarios.csv con encabezados solamente.
No sobrescribe archivos existentes. Completa esos CSV antes de usar --validar.
"""

from __future__ import annotations

import argparse
import csv
import sys
from decimal import Decimal, InvalidOperation
from pathlib import Path

PRODUCT_HEADERS = [
    "SKU",
    "name",
    "description",
    "current_price",
    "current_stock",
    "status",
]
USER_HEADERS = ["email", "nick", "password", "status"]
EXPECTED_ROWS = 10_000


def create_template(path: Path, headers: list[str]) -> None:
    if path.exists():
        print(f"Se conserva el archivo existente: {path}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8-sig") as stream:
        csv.writer(stream).writerow(headers)
    print(f"Plantilla creada: {path}")


def read_csv(path: Path, expected_headers: list[str]) -> list[list[str]]:
    if not path.exists():
        raise ValueError(f"No existe el archivo: {path}")
    with path.open("r", newline="", encoding="utf-8-sig") as stream:
        reader = csv.reader(stream)
        headers = next(reader, None)
        if headers != expected_headers:
            raise ValueError(
                f"{path.name}: encabezados incorrectos.\n"
                f"  Esperados: {','.join(expected_headers)}\n"
                f"  Encontrados: {','.join(headers or [])}"
            )
        rows = list(reader)
    for line_number, row in enumerate(rows, start=2):
        if len(row) != len(expected_headers):
            raise ValueError(
                f"{path.name}, fila {line_number}: se esperaban "
                f"{len(expected_headers)} campos y hay {len(row)}."
            )
    if len(rows) != EXPECTED_ROWS:
        raise ValueError(
            f"{path.name}: se esperaban {EXPECTED_ROWS:,} filas de datos; "
            f"hay {len(rows):,}."
        )
    return rows


def validate_products(path: Path) -> None:
    rows = read_csv(path, PRODUCT_HEADERS)
    seen_skus: set[str] = set()
    for line_number, row in enumerate(rows, start=2):
        sku, name, _description, price, stock, status = row
        if not sku.strip() or not name.strip():
            raise ValueError(f"{path.name}, fila {line_number}: SKU y name son obligatorios.")
        if sku in seen_skus:
            raise ValueError(f"{path.name}, fila {line_number}: SKU repetido: {sku}")
        seen_skus.add(sku)
        try:
            if Decimal(price) < 0:
                raise ValueError(f"{path.name}, fila {line_number}: current_price no puede ser negativo.")
        except InvalidOperation as exc:
            raise ValueError(f"{path.name}, fila {line_number}: current_price no es decimal.") from exc
        try:
            if int(stock) < 0:
                raise ValueError(f"{path.name}, fila {line_number}: current_stock no puede ser negativo.")
        except ValueError as exc:
            raise ValueError(f"{path.name}, fila {line_number}: current_stock debe ser entero.") from exc
        if status not in {"0", "1"}:
            raise ValueError(f"{path.name}, fila {line_number}: status debe ser 0 o 1.")
    print(f"Productos: estructura correcta; {len(rows):,} filas validadas.")


def validate_users(path: Path) -> None:
    rows = read_csv(path, USER_HEADERS)
    seen_emails: set[str] = set()
    seen_nicks: set[str] = set()
    for line_number, row in enumerate(rows, start=2):
        email, nick, password, status = row
        if not email.strip() or not nick.strip() or not password.strip():
            raise ValueError(f"{path.name}, fila {line_number}: email, nick y password son obligatorios.")
        if email.casefold() in seen_emails:
            raise ValueError(f"{path.name}, fila {line_number}: email repetido: {email}")
        if nick.casefold() in seen_nicks:
            raise ValueError(f"{path.name}, fila {line_number}: nick repetido: {nick}")
        seen_emails.add(email.casefold())
        seen_nicks.add(nick.casefold())
        if status not in {"0", "1"}:
            raise ValueError(f"{path.name}, fila {line_number}: status debe ser 0 o 1.")
    print(f"Usuarios: estructura correcta; {len(rows):,} filas validadas.")


def main() -> int:
    parser = argparse.ArgumentParser(description="Plantillas CSV para db_test")
    parser.add_argument(
        "--directorio",
        type=Path,
        default=Path.home() / "Downloads",
        help="Carpeta donde crear o validar los CSV (por defecto: Descargas del usuario).",
    )
    parser.add_argument(
        "--validar",
        action="store_true",
        help="Valida los CSV ya completados; no crea ni modifica archivos.",
    )
    args = parser.parse_args()
    products_path = args.directorio / "productos.csv"
    users_path = args.directorio / "usuarios.csv"

    try:
        if args.validar:
            validate_products(products_path)
            validate_users(users_path)
        else:
            create_template(products_path, PRODUCT_HEADERS)
            create_template(users_path, USER_HEADERS)
            print("Completa los CSV con exactamente 10,000 filas cada uno y luego ejecuta --validar.")
            print("No agregues columnas ID: MySQL las genera automáticamente.")
            print("Las contraseñas deben estar en el formato hash que espera la aplicación.")
    except (OSError, ValueError, csv.Error) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
