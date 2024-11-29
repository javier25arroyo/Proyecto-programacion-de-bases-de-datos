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

