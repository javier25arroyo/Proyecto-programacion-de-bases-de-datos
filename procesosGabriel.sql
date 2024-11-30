--Seleccionar todos los proveedores en orden de su ID 

SELECT * FROM Proveedores ORDER BY ID_proveedor;

--Crear N compras para cada proveedor.  N= último dígito de su cédula jurídica 
--3 La fecha de la compra será a partir del '15/01/2023' + 7*ID_Proveedor 

CREATE SEQUENCE Compras_SEQ
START WITH 1  
INCREMENT BY 1;

CREATE SEQUENCE Unidades_SEQ
START WITH 1  
INCREMENT BY 1;

----------------------------------------------------
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

select * from compras
----------------------------------------------------
--Cada COMPRA tendrá M DETALLES_COMPRA. Según sea el último dígito de la fecha de compra.  MOD(to_char(fecha,'dd'),3)+3
--Seleccionar aleatoriamente los M PRODUCTOS para cada detalle de compra
--Asignar la cantidad aleatoriamente entre 3 y 10 
--asignar COSTO = PRECIO_REFERENCIA *0.8 
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

INSERT INTO Detalle_Compras (Compras_ID_compra, Productos_ID_producto, Cantidad, Costo) VALUES (1, 1, 5, 1200);
SELECT * FROM detalle_compras;

----------------------------------------------------
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
SELECT * FROM unidades;


---------------------------------------------------Datos para RegistrarVenta
INSERT INTO Clientes (ID_Cliente, Nombre, Apellidos, Direccion, Telefono, Email, Fecha_Nacimiento)
VALUES (101, 'Juan', 'Pérez', 'Dirección 1', 88888888, 'juan.perez@example.com', TO_DATE('1990-01-01', 'YYYY-MM-DD'));

INSERT INTO Locales (ID_local, Codigo_Local, Direccion, Telefono)
VALUES (301, 'LOC-A', 'Dirección del Local A', 12345678);

INSERT INTO Productos (ID_Producto, Nombre, Descripcion, Precio_Referencia)
VALUES (201, 'Producto A', 'Descripción del Producto A', 100.00);

INSERT INTO Unidades (ID_Unidad, Num_serie, Productos_ID_Producto, Locales_ID_Local, Fecha_ingreso, Disponible)
VALUES (401, 98765432, 201, 301, SYSDATE, 'Y');

SELECT * FROM Clientes WHERE ID_Cliente = 101;
SELECT * FROM Productos WHERE ID_Producto = 201;
SELECT * FROM Unidades WHERE Productos_ID_Producto = 201 AND Locales_ID_Local = 301 AND Disponible = 'Y';
SELECT * FROM Locales WHERE ID_Local = 301;


----------------------------------------------------
--RegistrarVenta
CREATE OR REPLACE PROCEDURE RegistrarVenta(
    p_id_cliente NUMBER,
    p_id_producto NUMBER,
    p_id_local NUMBER,
    p_cantidad NUMBER
) AS
    v_id_venta NUMBER;
    v_id_unidad NUMBER;
BEGIN
    SELECT Ventas_SEQ.NEXTVAL INTO v_id_venta FROM dual;

    INSERT INTO Ventas (ID_Venta, Fecha, Factura, Estado, Clientes_ID_Cliente)
    VALUES (v_id_venta, SYSDATE, 'FAC_' || v_id_venta, 'AC', p_id_cliente);

    SELECT ID_Unidad INTO v_id_unidad
    FROM Unidades
    WHERE Productos_ID_producto = p_id_producto
      AND Locales_ID_local = p_id_local
      AND Disponible = 'Y'
      AND ROWNUM = 1;

    INSERT INTO Detalle_ventas (Ventas_ID_Venta, Cantidad, Precio_Venta, Unidades_ID_Unidad)
    VALUES (v_id_venta, p_cantidad, (SELECT Precio_Referencia FROM Productos WHERE ID_producto = p_id_producto), v_id_unidad);

    UPDATE Unidades
    SET Disponible = 'N'
    WHERE ID_Unidad = v_id_unidad;

    COMMIT;
END;
/
select * from Unidades
----------------------------------------------------Resultados
BEGIN
    RegistrarVenta(101, 201, 301, 1);
END;

SELECT * FROM Ventas WHERE Clientes_ID_Cliente = 101;

SELECT * FROM Detalle_ventas WHERE Ventas_ID_Venta = (SELECT MAX(ID_Venta) FROM Ventas);

SELECT * FROM Unidades WHERE Productos_ID_Producto = 201 AND Locales_ID_Local = 301;

---------------------------------------------------Datos para RegistrarCompra

INSERT INTO Distritos (ID_Distrito, Nombre)
VALUES (10001, 'Distrito 1');

INSERT INTO Distritos (ID_Distrito, Nombre)
VALUES (10002, 'Distrito 2');


INSERT INTO Proveedores (ID_Proveedor, Nombre, Cedula_Juridica, Direccion, Telefono, Distritos_ID_Distrito)
VALUES (301, 'Proveedor B', '987654321', 'Dirección del Proveedor B', 88885555, 10001);

INSERT INTO Productos (ID_Producto, Nombre, Descripcion, Precio_Referencia)
VALUES (402, 'Producto C', 'Descripción del Producto C', 175.00);

INSERT INTO Locales (ID_Local, Codigo_Local, Direccion, Telefono, Distritos_ID_Distrito)
VALUES (401, 'Local B', 'Dirección del Local B', 22223333, 10002);



----------------------------------------------------

--RegistrarCompra
CREATE OR REPLACE PROCEDURE RegistrarCompra(
    p_id_proveedor NUMBER,
    p_id_producto NUMBER,
    p_cantidad NUMBER
) AS
    v_id_compra NUMBER;
    v_id_unidad NUMBER;
    v_id_local NUMBER;
    i NUMBER := 0;
BEGIN
    SELECT Compras_SEQ.NEXTVAL INTO v_id_compra FROM dual;

    INSERT INTO Compras (ID_compra, Fecha, Documento, Proveedores_ID_proveedor)
    VALUES (v_id_compra, SYSDATE, 'DOC_' || v_id_compra, p_id_proveedor);

    WHILE i < p_cantidad LOOP
        i := i + 1;

        SELECT ID_local INTO v_id_local
        FROM Locales
        WHERE ROWNUM = 1
        ORDER BY DBMS_RANDOM.VALUE;

        SELECT Unidades_SEQ.NEXTVAL INTO v_id_unidad FROM dual;

        INSERT INTO Unidades (ID_Unidad, Num_serie, Productos_ID_producto, Locales_ID_local, Fecha_ingreso, Disponible)
        VALUES (v_id_unidad, DBMS_RANDOM.VALUE(10000000, 99999999), p_id_producto, v_id_local, SYSDATE, 'Y');
        
        INSERT INTO Detalle_Compras (Cantidad, Compras_ID_compra, Productos_ID_producto, Costo)
        VALUES (1, v_id_compra, p_id_producto, (SELECT Precio_Referencia FROM Productos WHERE ID_producto = p_id_producto));
    END LOOP;

    COMMIT;
END;
/
----------------------------------------------------Resultados
BEGIN
    RegistrarCompra(301, 402, 1);
END;
/

SELECT * FROM Proveedores WHERE ID_Proveedor = 301;
SELECT * FROM Productos WHERE ID_Producto = 402;

SELECT * FROM Compras WHERE Proveedores_ID_Proveedor = 301;
SELECT * FROM Unidades WHERE Productos_ID_Producto = 402;
SELECT * FROM Detalle_Compras WHERE Compras_ID_Compra = (SELECT MAX(ID_Compra) FROM Compras);
