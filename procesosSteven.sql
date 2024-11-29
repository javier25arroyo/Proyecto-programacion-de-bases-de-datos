--Seleccionar todos los proveedores en orden de su ID

SELECT * FROM Proveedores ORDER BY ID_proveedor;


******************************************************


--Crear N compras para cada proveedor.  N= último dígito de su cédula jurídica
--3 La fecha de la compra será a partir del '15/01/2023' + 7*ID_Proveedor

CREATE SEQUENCE Compras_SEQ
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE Unidades_SEQ
START WITH 1
INCREMENT BY 1;

------------------------------------------------------
INSERT INTO Compras (ID_compra, Fecha, Documento, Proveedores_ID_proveedor)
SELECT
    Compras_SEQ.NEXTVAL,
    DATE '2023-01-15' + (7 * p.ID_proveedor) AS Fecha,
    'DOC-' || Compras_SEQ.CURRVAL,
    p.ID_proveedor
FROM
    Proveedores p,
    (SELECT LEVEL AS CompraNumero FROM dual CONNECT BY LEVEL <= 10)
WHERE
    CompraNumero <= TO_NUMBER(SUBSTR(p.Cedula_Juridica, -1));

******************************************************

------------------------------------------------------
--Cada COMPRA tendrá M DETALLES_COMPRA. Según sea el último dígito de la fecha de compra. MOD(to_char(fecha,'dd'),3)+3
--Seleccionar aleatoriamente los M PRODUCTOS para cada detalle de compra
--Asignar la cantidad aleatoriamente entre 3 y 10
--Asignar COSTO = PRECIO_REFERENCIA *0.8

INSERT INTO Detalle_Compras (Compras_ID_compra, Productos_ID_producto, Cantidad, Costo)
SELECT
    c.ID_compra,
    (SELECT ID_producto FROM Productos ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY),
    FLOOR(DBMS_RANDOM.VALUE(3, 10)),
    p.Precio_Referencia * 0.8
FROM
    Compras c
JOIN
    Proveedores pr ON c.Proveedores_ID_proveedor = pr.ID_proveedor
JOIN
    Productos p ON MOD(TO_NUMBER(TO_CHAR(c.Fecha, 'DD')), 3) + 3 = 3;


******************************************************
------------------------------------------------------
--Según la CANTIDAD asignada, crear UNIDADES
--Asignar NUMERO_SERIE aleatorio
--FECHA_INGRESO = Fecha de COMPRAS
--Asignar un LOCAL aleatorio

INSERT INTO Unidades (ID_Unidad, Num_serie, Productos_ID_producto, Locales_ID_local, Fecha_ingreso, Disponible)
SELECT
    Unidades_SEQ.NEXTVAL,
    FLOOR(DBMS_RANDOM.VALUE(100000, 999999)),
    dc.Productos_ID_producto,
    (SELECT ID_local FROM Locales ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY),
    c.Fecha,
    'Y'
FROM
    Detalle_Compras dc
JOIN
    Compras c ON dc.Compras_ID_compra = c.ID_compra;
******************************************************

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
******************************************************



