CREATE TABLE Provincias (
    ID_provincia NUMBER(1) PRIMARY KEY,
    Nombre VARCHAR2(10) NOT NULL
);

CREATE TABLE Cantones (
    ID_Canton NUMBER(3) PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Provincias_ID_provincia NUMBER(1),
    FOREIGN KEY (Provincias_ID_provincia) REFERENCES Provincias(ID_provincia)
);

CREATE TABLE Distritos (
    ID_Distrito NUMBER(3) PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Cantones_ID_Canton NUMBER(3),
    FOREIGN KEY (Cantones_ID_Canton) REFERENCES Cantones(ID_Canton)
);

CREATE TABLE Locales (
    ID_local NUMBER(3) PRIMARY KEY,
    Codigo_local VARCHAR2(20) NOT NULL,
    Direccion VARCHAR2(60),
    Telefono NUMBER(8),
    Distritos_ID_Distrito NUMBER(3),
    FOREIGN KEY (Distritos_ID_Distrito) REFERENCES Distritos(ID_Distrito)
);

CREATE TABLE Proveedores (
    ID_proveedor NUMBER(4) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Cedula_Juridica VARCHAR2(12),
    Direccion VARCHAR2(100),
    Telefono NUMBER(8),
    email VARCHAR2(50),
    Distritos_ID_Distrito NUMBER(3),
    FOREIGN KEY (Distritos_ID_Distrito) REFERENCES Distritos(ID_Distrito)
);

CREATE TABLE Productos (
    ID_producto NUMBER(6) PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Descripcion VARCHAR2(200),
    Precio_Referencia NUMBER(7,2),
    ID_categoria NUMBER(3),
    ID_fabricante NUMBER(4),
    FOREIGN KEY (ID_categoria) REFERENCES Categorias(ID_categoria),
    FOREIGN KEY (ID_fabricante) REFERENCES Fabricante(ID_fabricante)
);

CREATE TABLE Fabricante (
    ID_fabricante NUMBER(4) PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Paises_ID_Pais CHAR(3),
    FOREIGN KEY (Paises_ID_Pais) REFERENCES Paises(ID_Pais)
);

CREATE TABLE Paises (
    ID_Pais CHAR(3) PRIMARY KEY,
    Nombre VARCHAR2(30) NOT NULL
);

CREATE TABLE Categorias (
    ID_categoria NUMBER(3) PRIMARY KEY,
    Descripcion VARCHAR2(50)
);

CREATE TABLE Unidades (
    ID_Unidad NUMBER(7) PRIMARY KEY,
    Num_serie NUMBER(8),
    Productos_ID_producto NUMBER(6),
    Locales_ID_local NUMBER(3),
    Fecha_ingreso DATE,
    Disponible CHAR(1),
    FOREIGN KEY (Productos_ID_producto) REFERENCES Productos(ID_producto),
    FOREIGN KEY (Locales_ID_local) REFERENCES Locales(ID_local)
);

CREATE TABLE Clientes (
    ID_Cliente NUMBER(6) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Apellidos VARCHAR2(50),
    Direccion VARCHAR2(100),
    Telefono NUMBER(8),
    email VARCHAR2(60),
    Fecha_Nacimiento DATE
);

CREATE TABLE Ventas (
    ID_Venta NUMBER(7) PRIMARY KEY,
    Fecha DATE,
    Factura VARCHAR2(10),
    Estado CHAR(2),
    Clientes_ID_Cliente NUMBER(6),
    FOREIGN KEY (Clientes_ID_Cliente) REFERENCES Clientes(ID_Cliente)
);

CREATE TABLE Detalle_Ventas (
    Ventas_ID_Venta NUMBER(7),
    ID_Unidad NUMBER(7),
    Cantidad NUMBER(6),
    Precio_Venta NUMBER(8,2),
    PRIMARY KEY (Ventas_ID_Venta, ID_Unidad),
    FOREIGN KEY (Ventas_ID_Venta) REFERENCES Ventas(ID_Venta),
    FOREIGN KEY (ID_Unidad) REFERENCES Unidades(ID_Unidad)
);

CREATE TABLE Compras (
    ID_compra NUMBER(6) PRIMARY KEY,
    Fecha DATE,
    Documento VARCHAR2(15),
    Proveedores_ID_proveedor NUMBER(4),
    FOREIGN KEY (Proveedores_ID_proveedor) REFERENCES Proveedores(ID_proveedor)
);

CREATE TABLE Detalle_Compras (
    Compras_ID_compra NUMBER(6),
    Productos_ID_producto NUMBER(6),
    Cantidad NUMBER(6),
    Costo NUMBER(7,2),
    PRIMARY KEY (Compras_ID_compra, Productos_ID_producto),
    FOREIGN KEY (Compras_ID_compra) REFERENCES Compras(ID_compra),
    FOREIGN KEY (Productos_ID_producto) REFERENCES Productos(ID_producto)
);

