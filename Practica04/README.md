# Práctica 04: simulación de compra

## Caso de prueba 1

Los scripts de `scripts/caso_prueba_1` preparan y ejecutan un flujo de compra con datos ficticios sobre el respaldo de `db_test_corregida`:

1. La conexión `app_web` o `app_movil` activa `user_not_registered` y registra al comprador con `sp_register_new_user`.
2. La aplicación autentica al comprador y cambia la conexión a `common_user`.
3. Crea un domicilio, sus componentes y el método de débito simulado.
4. Agrega cinco productos disponibles al carrito, con cantidades de 1 a 5.
5. Convierte el carrito en una orden con su detalle.
6. Registra el pago y ejecuta la autorización y captura con `sp_authorize_payment`.
7. Después de confirmar el pago, la aplicación activa `buyer`; los procedimientos atienden la orden y descuentan ambos inventarios.
8. El procedimiento simula la entrega y la relaciona con el domicilio.

## Preparación

1. Restaura `backups/respaldo_09112026.sql` en una instancia local de MySQL 8.0. No ejecutes la prueba sobre la base de trabajo.
2. Como DBA, asegúrate de que existan las cuentas MySQL `app_web` y `app_movil`, y ejecuta `scripts/caso_prueba_1/00_permisos_app.sql`. El script crea los roles de la práctica y los asigna a ambas cuentas; no establece ni cambia sus contraseñas.
3. Como DBA, ejecuta `scripts/caso_prueba_1/01_preparar_catalogo.sql`. Añade las relaciones entre pagos y métodos, y entre envíos y domicilios; registra el tipo ficticio de tarjeta, prepara ofertas e instala los procedimientos de atención y entrega. Se ejecuta una vez por restauración limpia.
4. En Workbench, abre una conexión con `app_web` o `app_movil` y ejecuta `scripts/caso_prueba_1/02_ejecutar_caso.sql` completo en esa misma pestaña/conexión. El script activa `user_not_registered`, luego `common_user` y, tras autorizar el pago, `buyer`.
5. Revisa los resultados finales: el estado de orden debe ser `Delivered`, el pago `Paid`, y deben aparecer eventos `Authorized` y `Captured`.

El nuevo comprador es un registro de `tb_users`, no una cuenta MySQL independiente. La sesión sigue conectada como `app_web` o `app_movil`; la aplicación autentica al comprador y controla cuándo cambia el rol de esa conexión. El cambio de rol de SQL es una demostración académica: en producción, el usuario final no debe poder ejecutar libremente `SET ROLE` y el backend debe controlar los permisos y el estado de la compra.

## Límites de la simulación

- El pago es local y ficticio. Solo se conserva un token de prueba y los últimos cuatro dígitos; el número completo de tarjeta no se almacena ni se transmite.
- `sp_authorize_payment` inserta eventos `Authorized` y `Captured` y deja la orden pagada. No consulta un banco ni un procesador real.
- `sp_deliver_order` genera inmediatamente un envío como entregado. No existe transportista ni entrega física.
- `sp_register_new_user` guarda contraseñas con MD5 en este respaldo; usa únicamente las credenciales de prueba del script, nunca una contraseña real.
- El respaldo contiene definiciones con `DEFINER=root@localhost`. Al restaurarlo en otra instancia, asegúrate de que sus rutinas y triggers puedan crearse correctamente antes de ejecutar la prueba.

## Archivos de la práctica

- `backups/respaldo_09112026.sql`: exportación más reciente de `db_test_corregida`, con la sincronización de usuarios y personas.
- `backups/respaldo_10.sql`: respaldo previo usado para preparar la simulación.
- `scripts/caso_prueba_1/01_preparar_catalogo.sql`: cambios de esquema y catálogo de prueba.
- `scripts/caso_prueba_1/00_permisos_app.sql`: roles y privilegios mínimos para las cuentas de aplicación existentes.
- `scripts/caso_prueba_1/02_ejecutar_caso.sql`: recorrido completo de compra.
- `scripts/caso_prueba_1/03_completar_personas_faltantes.sql`: procedimiento para crear las filas de `tb_people` faltantes para usuarios existentes.
- `scripts/remote_users_priviliges_creation.sql`: script anterior de roles para `db_test`; no es necesario para este caso y no debe ejecutarse sin adaptar sus privilegios y base de datos.
- `queries/consultas_de_verificacion.sql`: consultas heredadas de la práctica 03.
