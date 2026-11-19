# Práctica 04: simulación de compra

## Estructura

```text
Practica04/
├── backups/
│   ├── respaldo_5casostotalesfinal.sql     # respaldo más reciente, con los cinco casos
│   ├── respaldo_5casostotales.sql          # respaldo anterior
│   ├── respaldo_5casos.sql                 # respaldo anterior
│   ├── respaldo_compra.sql                 # respaldo de compra anterior
│   └── ...                                 # respaldos históricos
├── queries/
│   ├── visualizar_casos_prueba_1_a_5.sql  # consultas para revisar los cinco casos
│   └── consultas_de_verificacion.sql       # consultas heredadas de la práctica 03
├── diccionario/
│   ├── diccionario.html                    # explorador interactivo y diagrama ER
│   ├── backup-picker.js                    # lector local de respaldos SQL
│   ├── relaciones.html                     # entidades y claves foráneas
│   ├── diagrama_ere.md                     # diagrama ERE en Mermaid
│   ├── campos.csv                          # inventario tabular de campos
│   └── anexo_tecnico.md                    # fuente y resumen del esquema
├── scripts/
│   ├── caso_prueba_1/
│   │   ├── 01_preparar_catalogo.sql         # prepara esquema, ofertas y procedimientos
│   │   └── 02_ejecutar_caso.sql              # ejecuta una compra completa
│   ├── caso_prueba_2/
│   │   └── 02_compra_reclamacion_reenvio.sql # seis pagos, reclamación y reenvío
│   ├── caso_prueba_3/
│   │   └── 03_compra_cancelacion_reembolso.sql
│   ├── caso_prueba_4/
│   │   └── 04_compra_recoleccion_punto.sql
│   ├── caso_prueba_5/
│   │   └── 05_compra_fallida_inventario_cupon.sql
│   ├── generar_diccionario_interactivo.js   # generador con el diseño de Práctica 03
│   ├── generar_diccionario.ps1             # compatibilidad con el comando PowerShell
│   └── remote_users_priviliges_creation.sql # cuentas, roles y permisos
├── prompt/
│   └── diccionario.txt                     # instrucciones de generación y revisión
├── guia_simulacion_workbench.txt
└── README.md
```

`respaldo_5casostotalesfinal.sql` es el respaldo más reciente. El volcado terminó el 18 de noviembre de 2026 a las 23:31:17 e incluye evidencia de los cinco casos. En el Caso 4, la compra de recolección es la orden `10`; en el Caso 5, la ejecución corregida es la orden `12`. La orden `11` conserva un intento previo que se recuperó tras una ejecución interrumpida.

## Diccionario de datos y diagrama ERE

La documentación se genera desde el DDL de `backups/respaldo_5casostotalesfinal.sql` y cubre 27 tablas, 225 campos y 33 claves foráneas. El [diccionario interactivo en GitHub Pages](https://xluiscm.github.io/Practicas_BDN_240343/practica04/diccionario.html) usa el mismo explorador y diagrama ER navegable que Práctica 03; también permite cargar un respaldo SQL localmente para analizar su esquema en el navegador. Consulta además las [relaciones entre tablas](https://xluiscm.github.io/Practicas_BDN_240343/practica04/relaciones.html) y el [diagrama ERE](https://xluiscm.github.io/Practicas_BDN_240343/practica04/diagrama_ere.html). Para regenerar desde la raíz del repositorio ejecuta `node Practica04/scripts/generar_diccionario_interactivo.js`; el generador actualiza `Practica04/diccionario/` y las vistas publicadas en `docs/practica04/`. Las instrucciones están en `prompt/diccionario.txt`.

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

1. Para consultar los cinco casos ya registrados, restaura `backups/respaldo_5casostotalesfinal.sql` en una instancia de prueba MySQL 9.5. El respaldo incluye datos y definiciones de `db_test_corregida`; no lo restaures sobre la base de trabajo.
2. Ejecuta `queries/visualizar_casos_prueba_1_a_5.sql` en MySQL Workbench para revisar la evidencia de cada caso.
3. Para repetir los escenarios, restaura una copia de prueba y ejecuta la preparación y los scripts correspondientes.
4. Como DBA, ejecuta `scripts/caso_prueba_1/01_preparar_catalogo.sql` una vez por cada restauración limpia.
5. Como DBA, ejecuta `scripts/remote_users_priviliges_creation.sql` para crear las cuentas que falten y configurar roles y permisos. `CREATE USER IF NOT EXISTS` conserva las contraseñas de cuentas existentes.
6. Ejecuta el Caso 1 como `app_web` o `app_movil` en una sesión; ejecuta los Casos 2 a 5 como DBA. Los scripts de los Casos 3 a 5 incluyen recuperación de algunos intentos interrumpidos.

El comprador creado es una fila en `tb_users`, no una cuenta MySQL. La sesión permanece conectada como `app_web` o `app_movil`; la aplicación cambia sus roles durante el flujo.

## Casos de prueba 2 al 5

Ejecuta estos casos como DBA en una restauración de prueba, después de ejecutar `caso_prueba_1/01_preparar_catalogo.sql`. Cada script prioriza un usuario activo con `nick LIKE 'user_test_%'` que todavía no tenga carrito; si no encuentra uno, selecciona otro usuario activo sin carrito. Los scripts imprimen los identificadores y el resultado del flujo.

## Caso de prueba 2

El script `scripts/caso_prueba_2/02_compra_reclamacion_reenvio.sql` simula la compra, el último pago rechazado y el reenvío de un producto dañado:

1. Selecciona diez productos distintos y agrega cantidades de 1 a 5 en un carrito.
2. Crea la orden y registra un domicilio alternativo de trabajo.
3. Registra una tarjeta de crédito simulada vinculada al perfil del usuario.
4. Registra cinco pagos autorizados y capturados mediante `sp_authorize_payment`; registra el sexto pago como fallido por límite de crédito.
5. Atiende y entrega la orden.
6. Registra la reclamación de una unidad dañada y el envío de una unidad de reposición.

## Caso de prueba 3

El script `scripts/caso_prueba_3/03_compra_cancelacion_reembolso.sql` simula una compra con cancelación y reembolso parciales:

1. Selecciona tres productos de la misma categoría con cantidades de 1 a 3.
2. Crea el carrito y la orden; registra el domicilio alternativo `Casa Papas`.
3. Registra el método Spin simulado vinculado al perfil y un único pago en efectivo por el total.
4. Autoriza el pago y atiende la orden.
5. Cancela un producto, ajusta el total y el inventario, y registra el reembolso parcial.
6. Entrega los productos restantes.

## Caso de prueba 4

El script `scripts/caso_prueba_4/04_compra_recoleccion_punto.sql` simula una compra para recoger en un punto después de un intento fallido de entrega:

1. Selecciona tres productos para un mismo pedido de vendedor, con cantidades de 1 a 3.
2. Crea el carrito y la orden; registra el domicilio habitual `Casa`.
3. Registra una cuenta SPEI simulada vinculada al perfil y un único pago en efectivo por el total.
4. Autoriza el pago, atiende la orden y crea el envío.
5. Registra el intento fallido en el domicilio y actualiza el seguimiento para indicar que el cliente recogió el pedido en el punto de recolección.

## Caso de prueba 5

El script `scripts/caso_prueba_5/05_compra_fallida_inventario_cupon.sql` simula la cancelación de una orden porque se agota el inventario:

1. Crea un carrito y una orden con un producto y una unidad; registra el domicilio habitual `Casa`.
2. Registra un cupón de regalo simulado vinculado al perfil del usuario.
3. Autoriza el pago del cupón y agota la oferta antes de atender la orden.
4. Ejecuta `sp_pr04_attend_order`, captura el rechazo por inventario insuficiente y cancela la orden.
5. Anula el pago y reactiva el método del cupón para que pueda reasignarse.

Las cuentas Spin y SPEI, la tarjeta y el cupón son ficticios; no se almacena una cuenta ni una tarjeta real de 16 dígitos. En el Caso 3 y el Caso 4, el método se registra en el perfil mientras que el pago de la orden se registra como `Cash`, tal como indican sus respectivas descripciones.

`01_preparar_catalogo.sql` verifica si ya existen las columnas y llaves de pago/domicilio antes de agregarlas. No crea tablas: usa las tablas existentes de métodos de pago, pedidos, cancelaciones, reembolsos y envíos. Registra los tipos de métodos simulados en el catálogo actual. El Caso 4 guarda el retiro en los campos de seguimiento del envío; el Caso 5 usa un procedimiento auxiliar que elimina al terminar para capturar el error de inventario sin interrumpir el script.

## Límites de la simulación

- El pago y la entrega son ficticios; no se contacta un banco ni un transportista real.
- El número de tarjeta de prueba no se almacena completo. La tabla dependiente conserva un token y los últimos cuatro dígitos.
- El respaldo contiene objetos con `DEFINER=root@localhost`; al restaurarlo en otra instancia, verifica que los triggers y rutinas se creen correctamente.
- `queries/consultas_de_verificacion.sql` corresponde a verificaciones heredadas de la práctica 03. Para los cinco casos de esta práctica, utiliza `queries/visualizar_casos_prueba_1_a_5.sql`.
