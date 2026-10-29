import csv
import random
from datetime import datetime, timedelta

# Configuración de rangos y catálogos basados en tu esquema
CATEGORIES = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]  # Ajusta según IDs de tbc_categories
TIPOS = ['Vestido', 'Camisa', 'Short', 'Chaqueta', 'Bolso', 'Gorra', 'Zapatos', 'Botas', 'Reloj', 'Lentes de sol', 'Sueter', 'Pantalon']
ESTILOS = ['Premium', 'Casual', 'Elegante', 'Deportivo', 'Urbano', 'Vintage', 'Formal', 'Moderno', 'Juvenil', 'Impermeable']
COLORES = ['Azul', 'Negro', 'Morado', 'Cafe', 'Gris', 'Verde', 'Amarillo', 'Rojo', 'Blanco', 'Beige']

# Cargar SKUs existentes del script SQL para evitar duplicados
skus_existentes = set()
# Agrega aquí manualmente si deseas prevenir SKUs existentes:
# skus_existentes.update(["SKU-001", "SKU-VES-00004-320", ...])

num_registros = 10000
productos = []

def fecha_aleatoria():
    start = datetime(2026, 1, 1)
    end = datetime(2026, 10, 28)
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return (start + timedelta(seconds=random_seconds)).strftime("%Y-%m-%d %H:%M:%S")

i = 1
while len(productos) < num_registros:
    tipo = random.choice(TIPOS)
    estilo = random.choice(ESTILOS)
    color = random.choice(COLORES)
    
    # Formato de SKU alineado a la estructura observada
    prefix = tipo[:3].upper()
    rand_code = random.randint(100, 999)
    sku = f"SKU-{prefix}-{i:05d}-{rand_code}"
    
    if sku in skus_existentes:
        continue
        
    skus_existentes.add(sku)
    
    nombre = f"{tipo} {estilo} {color}"
    description = f"Descripción detallada para {nombre} de alta calidad."
    category_id = random.choice(CATEGORIES)
    cost_price = round(random.uniform(10.0, 150.0), 3)
    sale_price = round(cost_price * random.uniform(1.2, 2.5), 3)
    stock = random.randint(0, 500)
    creation_date = fecha_aleatoria()
    
    # Mapeo exacto de la tabla tb_products (sin el ID auto-incremental para que MySQL lo asigne)
    productos.append([
        sku,
        nombre,
        description,
        category_id,
        cost_price,
        sale_price,
        stock,
        1,  # status (bit/boolean ACTIVE)
        creation_date,
        creation_date # last_update
    ])
    i += 1

# Guardar en archivo CSV
headers = ['sku', 'nombre', 'description', 'category_id', 'cost_price', 'sale_price', 'stock', 'status', 'creation_date', 'last_update']

with open('productos_10000.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(productos)

print(f"¡Éxito! Archivo 'productos_10000.csv' generado con {num_registros} productos únicos.")