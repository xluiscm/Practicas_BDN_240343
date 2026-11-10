# Práctica 04: simulación de compra

## Estructura

```text
Practica04/
├── backups/
│   ├── respaldo_compra.sql                 # respaldo actualizado con la compra de prueba
│   ├── respaldo_09112026.sql               # respaldo anterior
│   ├── respaldo_10.sql                     # respaldo base anterior
│   └── Dump20261028.sql                    # exportación histórica
├── queries/
│   └── consultas_de_verificacion.sql        # consultas heredadas de la práctica 03
├── scripts/
│   ├── caso_prueba_1/
│   │   ├── 01_preparar_catalogo.sql         # prepara esquema, ofertas y procedimientos
│   │   └── 02_ejecutar_caso.sql              # ejecuta una compra completa
│   └── remote_users_priviliges_creation.sql # cuentas, roles y permisos
├── guia_simulacion_workbench.txt
└── README.md
```

`respaldo_compra.sql` es el respaldo más reciente y contiene la compra de prueba con la orden `2`. Los respaldos anteriores se conservan como referencia histórica.

## Caso de prueba 1

La simulación utiliza datos ficticios y recorre este flujo:

1. `app_web` o `app_movil` activa `user_not_registered` y registra un comprador mediante `sp_register_new_user`.
2. La aplicación autentica al comprador y activa `common_user`.
3. Se registra un domicilio, sus componentes y un método de débito simulado.
4. Se crea un carrito con cinco productos disponibles y cantidades de 1 a 5.
5. El carrito se convierte en una orden con su detalle.
6. Se registra el pago y `sp_authorize_payment` crea los eventos `Authorized` y `Captured`.
7. La aplicación activa `buyer`; los procedimientos atienden la orden y descuentan inventario.
8. Se crea un envío simulado asociado al domicilio.

## Ejecución

1. Restaura `backups/respaldo_compra.sql` en una instancia de prueba MySQL 9.5. El respaldo incluye datos y definiciones de la base `db_test_corregida`; no ejecutes la prueba sobre la base de trabajo.
2. Como DBA, ejecuta `scripts/caso_prueba_1/01_preparar_catalogo.sql` una vez por cada restauración limpia.
3. Como DBA, ejecuta `scripts/remote_users_priviliges_creation.sql` para crear las cuentas que falten y configurar roles y permisos. `CREATE USER IF NOT EXISTS` conserva las contraseñas de cuentas existentes.
4. Conéctate como `app_web` o `app_movil` y ejecuta `scripts/caso_prueba_1/02_ejecutar_caso.sql` completo en una sola sesión.
5. Verifica que la orden quede `Delivered`, el pago `Paid`, y existan los eventos `Authorized` y `Captured`.

El comprador creado es una fila en `tb_users`, no una cuenta MySQL. La sesión permanece conectada como `app_web` o `app_movil`; la aplicación cambia sus roles durante el flujo.

## Límites de la simulación

- El pago y la entrega son ficticios; no se contacta un banco ni un transportista real.
- El número de tarjeta de prueba no se almacena completo. La tabla dependiente conserva un token y los últimos cuatro dígitos.
- El respaldo contiene objetos con `DEFINER=root@localhost`; al restaurarlo en otra instancia, verifica que los triggers y rutinas se creen correctamente.
- `queries/consultas_de_verificacion.sql` corresponde a verificaciones heredadas de la práctica 03; no es parte de la ejecución del Caso de prueba 1.
