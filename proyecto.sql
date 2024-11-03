CREATE TABLE Provincias (
    ID_provincia NUMBER(1) PRIMARY KEY,
    Nombre VARCHAR2(10)
);

CREATE TABLE Cantones (
    Id_Canton NUMBER(3) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Provincias_ID_provincia NUMBER(1),
    CONSTRAINT Cantones_Provincias_FK FOREIGN KEY (Provincias_ID_provincia) REFERENCES Provincias(ID_provincia)
);

CREATE TABLE Distritos (
    ID_Distrito NUMBER(3) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Cantones_Id_Canton NUMBER(3),
    CONSTRAINT Distritos_Cantones_FK FOREIGN KEY (Cantones_Id_Canton) REFERENCES Cantones(Id_Canton)
);

CREATE TABLE Locales (
    ID_local NUMBER(3) PRIMARY KEY,
    Codigo_local VARCHAR2(20),
    Direccion VARCHAR2(60),
    Telefono NUMBER(8),
    Distritos_ID_Distrito NUMBER(3),
    CONSTRAINT Locales_Distritos_FK FOREIGN KEY (Distritos_ID_Distrito) REFERENCES Distritos(ID_Distrito)
);

CREATE TABLE Proveedores (
    ID_proveedor NUMBER(4) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Cedula_Juridica VARCHAR2(12),
    Direccion VARCHAR2(100),
    Telefono NUMBER,
    Email VARCHAR2(60),
    Distritos_ID_Distrito NUMBER(3),
    CONSTRAINT Proveedores_Distritos_FK FOREIGN KEY (Distritos_ID_Distrito) REFERENCES Distritos(ID_Distrito)
);

CREATE TABLE Paises (
    ID_Pais CHAR(3) PRIMARY KEY,
    Nombre VARCHAR2(30)
);

CREATE TABLE Categorias (
    ID_categoria NUMBER(3) PRIMARY KEY,
    Descripcion VARCHAR2(20)
);

CREATE TABLE Clientes (
    ID_Cliente NUMBER(6) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Apellidos VARCHAR2(60),
    Direccion VARCHAR2(100),
    Telefono NUMBER(8),
    Email VARCHAR2(60),
    Fecha_Nacimiento DATE
);

CREATE TABLE Ventas (
    ID_Venta NUMBER(7) PRIMARY KEY,
    Fecha DATE,
    Factura VARCHAR2(10),
    Estado CHAR(2),
    Clientes_ID_Cliente NUMBER(6),
    CONSTRAINT Ventas_Clientes_FK FOREIGN KEY (Clientes_ID_Cliente) REFERENCES Clientes(ID_Cliente)
);

CREATE TABLE Compras (
    ID_compra NUMBER(6) PRIMARY KEY,
    Fecha DATE,
    Documento VARCHAR2(15),
    Proveedores_ID_proveedor NUMBER(4),
    CONSTRAINT Compras_Proveedores_FK FOREIGN KEY (Proveedores_ID_proveedor) REFERENCES Proveedores(ID_proveedor)
);

CREATE TABLE Fabricante (
    ID_fabricante NUMBER(4) PRIMARY KEY,
    Nombre VARCHAR2(40),
    Paises_ID_Pais CHAR(3),
    CONSTRAINT Fabricante_Paises_FK FOREIGN KEY (Paises_ID_Pais) REFERENCES Paises(ID_Pais)
);

CREATE TABLE Productos (
    ID_producto NUMBER(6) PRIMARY KEY,
    Nombre VARCHAR2(20),
    Descripcion VARCHAR2(500),
    Precio_Referencia NUMBER(7),
    Categorias_ID_categoria NUMBER(3),
    Fabricante_ID_fabricante NUMBER(4),
    CONSTRAINT Productos_Categorias_FK FOREIGN KEY (Categorias_ID_categoria) REFERENCES Categorias(ID_categoria),
    CONSTRAINT Productos_Fabricante_FK FOREIGN KEY (Fabricante_ID_fabricante) REFERENCES Fabricante(ID_fabricante)
);

CREATE TABLE Unidades (
    ID_Unidad NUMBER(7) PRIMARY KEY,
    Num_serie NUMBER(8),
    Productos_ID_producto NUMBER(6),
    Locales_ID_local NUMBER(3),
    Fecha_ingreso DATE,
    Disponible CHAR(1),
    CONSTRAINT Unidades_Productos_FK FOREIGN KEY (Productos_ID_producto) REFERENCES Productos(ID_producto),
    CONSTRAINT Unidades_Locales_FK FOREIGN KEY (Locales_ID_local) REFERENCES Locales(ID_local)
);

CREATE TABLE Detalle_ventas (
    Ventas_ID_Venta NUMBER(7),
    Cantidad NUMBER(3),
    Precio_Venta NUMBER(7),
    Unidades_ID_Unidad NUMBER(7),
    PRIMARY KEY (Ventas_ID_Venta, Unidades_ID_Unidad),
    CONSTRAINT Detalle_ventas_Ventas_FK FOREIGN KEY (Ventas_ID_Venta) REFERENCES Ventas(ID_Venta)
);

CREATE TABLE Detalle_Compras (
    Cantidad NUMBER(4),
    Compras_ID_compra NUMBER(6),
    Productos_ID_producto NUMBER(6),
    Costo NUMBER(7),
    PRIMARY KEY (Compras_ID_compra, Productos_ID_producto),
    CONSTRAINT Detalle_Compras_Compras_FK FOREIGN KEY (Compras_ID_compra) REFERENCES Compras(ID_compra),
    CONSTRAINT Detalle_Compras_Productos_FK FOREIGN KEY (Productos_ID_producto) REFERENCES Productos(ID_producto)
);
