SELECT
    c.ID_CLIENTE,
    c.NOMBRE,
    c.APELLIDOS,
    c.FECHA_NACIMIENTO,
    FLOOR(MONTHS_BETWEEN(SYSDATE, c.FECHA_NACIMIENTO) / 12) AS EDAD, -- Calcula la edad en años del cliente
    NVL(SUM(dv.CANTIDAD * dv.PRECIO_VENTA), 0) AS TOTAL_PAGADO -- Calcula el total pagado por el cliente en ventas, usa 0 si no hay registros de ventas
FROM
    CLIENTES c
LEFT JOIN
    VENTAS v ON c.ID_CLIENTE = v.CLIENTES_ID_CLIENTE
LEFT JOIN
    DETALLE_VENTAS dv ON v.ID_VENTA = dv.VENTAS_ID_VENTA
GROUP BY
    c.ID_CLIENTE, c.NOMBRE, c.APELLIDOS, c.FECHA_NACIMIENTO
ORDER BY
    EDAD DESC,
    TOTAL_PAGADO ASC
FETCH FIRST 3 ROWS ONLY;
----------------------------------------------------------------------------------------------------------
--Modificar la Tabla COMPRAS para Agregar la Columna
--CLIENTES_ID_CLIENTE Este paso asegura que cada compra pueda
--vincularse a un cliente específico mediante una clave foránea
ALTER TABLE COMPRAS
ADD CLIENTES_ID_CLIENTE NUMBER; -- Agrega la columna CLIENTES_ID_CLIENTE de tipo NUMBER

----------------------------------------------------------------------------------------------------------
--Definimos la clave foránea para que CLIENTES_ID_CLIENTE en COMPRAS
--esté siempre relacionado con un cliente existente en la tabla CLIENTES.

ALTER TABLE COMPRAS
ADD CONSTRAINT fk_compras_clientes
FOREIGN KEY (CLIENTES_ID_CLIENTE) REFERENCES CLIENTES(ID_CLIENTE);

----------------------------------------------------------------------------------------------------------

CREATE SEQUENCE VENTAS_SEQ
START WITH 1       -- Inicia en 1
INCREMENT BY 1;    -- Incrementa en 1 cada vez

----------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE crear_ventas_para_clientes AS
    v_fecha_venta DATE;
    v_fecha_limite DATE := TRUNC(SYSDATE, 'MM'); -- Primer día del mes actual
BEGIN
    -- Cursor para iterar por cada cliente
    FOR cliente IN (SELECT ID_CLIENTE FROM CLIENTES) LOOP

        -- Obtener la última fecha de compra de proveedores para el cliente actual y sumar 10 días
        SELECT MAX(c.FECHA + 10)
        INTO v_fecha_venta
        FROM COMPRAS c
        WHERE c.CLIENTES_ID_CLIENTE = cliente.ID_CLIENTE; -- Se usa CLIENTES_ID_CLIENTE en COMPRAS

        -- Si no existe ninguna compra, saltamos este cliente
        IF v_fecha_venta IS NULL THEN
            CONTINUE;
        END IF;

        -- Verificamos que la fecha de venta no sea posterior al primer día del mes actual
        IF v_fecha_venta > v_fecha_limite THEN
            v_fecha_venta := v_fecha_limite;
        END IF;

        -- Insertar una nueva fila en la tabla VENTAS para el cliente actual
        INSERT INTO VENTAS (ID_VENTA, CLIENTES_ID_CLIENTE, FECHA)
        VALUES (VENTAS_SEQ.NEXTVAL, cliente.ID_CLIENTE, v_fecha_venta);

    END LOOP;

    -- Confirmar los cambios en la base de datos
    COMMIT;
END crear_ventas_para_clientes;
----------------------------------------------------------------------------------------------------------

BEGIN
  crear_ventas_para_clientes;
END;
/

----------------------------------------------------------------------------------------------------------

SELECT ID_VENTA, CLIENTES_ID_CLIENTE, FECHA
FROM VENTAS
ORDER BY FECHA DESC;
----------------------------------------------------------------------------------------------------------
SELECT *
FROM LOCALES
ORDER BY DBMS_RANDOM.VALUE
FETCH FIRST 1 ROWS ONLY;
----------------------------------------------------------------------------------------------------------
SELECT *
FROM LOCALES
ORDER BY DBMS_RANDOM.VALUE
FETCH FIRST 1 ROWS ONLY;

----------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
BEGIN
    -- Mostrar la fecha del sistema y el usuario conectado
    DBMS_OUTPUT.PUT_LINE('Fecha del sistema: ' || TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Usuario conectado: ' || USER);

    -- Variable para almacenar el valor total del inventario
    DECLARE
        v_total_valor_inventario NUMBER;
    BEGIN
        -- Calcular el valor total del inventario disponible
        SELECT SUM(DISPONIBLE)
        INTO v_total_valor_inventario
        FROM UNIDADES;

        -- Mostrar el resultado
        DBMS_OUTPUT.PUT_LINE('Valor total del inventario disponible: ' || NVL(v_total_valor_inventario, 0));
    END;
END;
/

----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION total_productos_vendidos(fecha_inicio DATE, fecha_fin DATE)
RETURN NUMBER
IS
    total_vendidos NUMBER;
BEGIN
    -- Calcular la suma de productos vendidos en el rango de fechas
    SELECT SUM(dv.CANTIDAD)
    INTO total_vendidos
    FROM DETALLE_VENTAS dv
    JOIN VENTAS v ON dv.VENTAS_ID_VENTA = v.ID_VENTA
    WHERE v.FECHA BETWEEN fecha_inicio AND fecha_fin;

    RETURN NVL(total_vendidos, 0);
END;
/

----------------------------------------------------------------------------------------------------------

DECLARE
    total_ultimo_mes         NUMBER;
    total_penultimo_mes      NUMBER;
    total_ultimos_12_meses   NUMBER;
    total_historico          NUMBER;

    -- Fechas dinámicas
    fecha_inicio_ultimo_mes      DATE := TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM');
    fecha_fin_ultimo_mes         DATE := TRUNC(SYSDATE, 'MM') - 1;
    fecha_inicio_penultimo_mes   DATE := TRUNC(ADD_MONTHS(SYSDATE, -2), 'MM');
    fecha_fin_penultimo_mes      DATE := fecha_inicio_ultimo_mes - 1;
    fecha_inicio_ultimos_12_meses DATE := ADD_MONTHS(SYSDATE, -12);
    fecha_fin_ultimos_12_meses   DATE := SYSDATE;
    fecha_inicio_historico       DATE;
    fecha_fin_historico          DATE := TRUNC(SYSDATE, 'MM') - 1;
BEGIN
    -- Calcular la fecha de la primera venta
    SELECT MIN(v.FECHA)
    INTO fecha_inicio_historico
    FROM VENTAS v;

    -- Último mes
    total_ultimo_mes := total_productos_vendidos(fecha_inicio_ultimo_mes, fecha_fin_ultimo_mes);

    -- Penúltimo mes
    total_penultimo_mes := total_productos_vendidos(fecha_inicio_penultimo_mes, fecha_fin_penultimo_mes);

    -- Últimos 12 meses
    total_ultimos_12_meses := total_productos_vendidos(fecha_inicio_ultimos_12_meses, fecha_fin_ultimos_12_meses);

    -- Desde la primera venta hasta el final del mes anterior
    total_historico := total_productos_vendidos(fecha_inicio_historico, fecha_fin_historico);

    -- Mostrar resultados
    DBMS_OUTPUT.PUT_LINE('Reporte de Totales de Productos Vendidos:');
    DBMS_OUTPUT.PUT_LINE('Último mes: ' || total_ultimo_mes);
    DBMS_OUTPUT.PUT_LINE('Penúltimo mes: ' || total_penultimo_mes);
    DBMS_OUTPUT.PUT_LINE('Últimos 12 meses: ' || total_ultimos_12_meses);
    DBMS_OUTPUT.PUT_LINE('Desde la primera venta hasta el final del mes anterior: ' || total_historico);
END;
/
----------------------------------------------------------------------------------------------------------

SELECT
    cat.DESCRIPCION AS CATEGORIA,
    p.DESCRIPCION AS PRODUCTO,
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 1 THEN dv.CANTIDAD ELSE 0 END) AS "#1",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 2 THEN dv.CANTIDAD ELSE 0 END) AS "#2",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 3 THEN dv.CANTIDAD ELSE 0 END) AS "#3",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 4 THEN dv.CANTIDAD ELSE 0 END) AS "#4",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 5 THEN dv.CANTIDAD ELSE 0 END) AS "#5",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 6 THEN dv.CANTIDAD ELSE 0 END) AS "#6",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 7 THEN dv.CANTIDAD ELSE 0 END) AS "#7",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 8 THEN dv.CANTIDAD ELSE 0 END) AS "#8",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 9 THEN dv.CANTIDAD ELSE 0 END) AS "#9",
    SUM(CASE WHEN MOD(v.ID_VENTA, 10) + 1 = 10 THEN dv.CANTIDAD ELSE 0 END) AS "#10",
    SUM(dv.CANTIDAD) AS TOTAL
FROM
    DETALLE_VENTAS dv
JOIN
    PRODUCTOS p ON dv.ID_PRODUCTO = p.ID_PRODUCTO
JOIN
    CATEGORIAS cat ON p.CATEGORIAS_ID_CATEGORIA = cat.ID_CATEGORIA
JOIN
    VENTAS v ON dv.VENTAS_ID_VENTA = v.ID_VENTA
GROUP BY
    cat.DESCRIPCION, p.DESCRIPCION
ORDER BY
    cat.DESCRIPCION, p.DESCRIPCION;
