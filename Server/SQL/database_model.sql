CREATE DATABASE "HotelDB"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

CREATE TABLE roles (
    ID_rol SMALLSERIAL,
    rol VARCHAR(20) NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (ID_rol),
    CONSTRAINT uk_rol_roles UNIQUE (rol)
);

CREATE TABLE usuarios(
    -- ID_usuario SERIAL,
    DNI_usuario VARCHAR(15) NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    correo TEXT NOT NULL,
    clave TEXT NOT NULL,
    id_rol SMALLINT DEFAULT 1,
    CONSTRAINT pk_usuario PRIMARY KEY(DNI_usuario),
    CONSTRAINT uk_correo UNIQUE (correo),
    CONSTRAINT fk_usuarios_roles FOREIGN KEY (id_rol) REFERENCES roles (ID_rol) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE tipo_telefonos(
    ID_tipo_telefono SMALLSERIAL,
    descripcion VARCHAR(30) NOT NULL,
    CONSTRAINT pk_tipo_telefono PRIMARY KEY(ID_tipo_telefono)
);

CREATE TABLE telefonos (
    ID_telefono SERIAL,
    numero VARCHAR(30) NOT NULL,
    id_tipo_telefono SMALLINT DEFAULT 1,
    dni_usuario VARCHAR(15),
    CONSTRAINT pk_telefonos PRIMARY KEY (ID_telefono),
    CONSTRAINT fk_id_tipo_telefono FOREIGN KEY (id_tipo_telefono) REFERENCES tipo_telefonos(ID_tipo_telefono) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_telefono_usuario FOREIGN KEY (dni_usuario) REFERENCES usuarios (DNI_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uk_numero_telefono UNIQUE (numero)
);

CREATE TABLE tipo_actividad(
    ID_tipo_actividad SERIAL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    precio INTEGER NOT NULL,
    CONSTRAINT pk_tipo_actividad PRIMARY KEY(ID_tipo_actividad)
);

CREATE TABLE actividades (
    ID_actividad SERIAL,
    fecha TIMESTAMP DEFAULT now(),
    id_tipo_actividad SERIAL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    CONSTRAINT pk_actividades PRIMARY KEY(ID_actividad),
    CONSTRAINT fk_id_tipo_actividad FOREIGN KEY(id_tipo_actividad) REFERENCES tipo_actividad (ID_tipo_actividad) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- CREATE TABLE tipo_comida(
--     ID_tipo_comida SERIAL,
--     nombre VARCHAR(100) NOT NULL,
--     descripcion VARCHAR(200) NOT NULL,
--     precio INTEGER NOT NULL,
--     activo BOOLEAN DEFAULT TRUE NOT NULL,
--     CONSTRAINT pk_tipo_comida PRIMARY KEY (ID_tipo_comida),
--     CONSTRAINT uk_nombre_comida UNIQUE (nombre)
-- );

CREATE TABLE comidas(
    ID_comida SERIAL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    precio INTEGER NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    CONSTRAINT pk_comidas PRIMARY KEY (ID_comida),
    -- CONSTRAINT fk_id_tipo_comida FOREIGN KEY (id_tipo_comida) REFERENCES tipo_comida(ID_tipo_comida) ON DELETE RESTRICT ON UPDATE RESTRICT
     CONSTRAINT uk_nombre_comida UNIQUE (nombre)
);

CREATE TABLE tipo_habitacion(
    ID_tipo_habitacion SMALLSERIAL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR (300) NOT NULL,
    CONSTRAINT pk_tipo_habitacion PRIMARY KEY(ID_tipo_habitacion),
    CONSTRAINT uk_nombre_tipo_habitacion UNIQUE(nombre)
);

CREATE TABLE habitaciones(
    ID_codigo_habitacion VARCHAR(10) NOT NULL,
    precio INTEGER NOT NULL,
    id_tipo_habitacion SMALLSERIAL,
    activo BOOLEAN DEFAULT FALSE,
    CONSTRAINT pk_habitacion PRIMARY KEY(ID_codigo_habitacion),
    CONSTRAINT fk_id_tipo_habitacion FOREIGN KEY(id_tipo_habitacion) REFERENCES tipo_habitacion(ID_tipo_habitacion) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE alquileres (
    ID_alquiler SERIAL,
    id_codigo_habitacion VARCHAR(10) NOT NULL,
    fecha_inicio TIMESTAMP DEFAULT now() NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    CONSTRAINT pk_alquiler PRIMARY KEY(ID_alquiler, id_codigo_habitacion),
    CONSTRAINT fk_id_codigo_habitacion FOREIGN KEY (id_codigo_habitacion) REFERENCES habitaciones(ID_codigo_habitacion) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE ordenes (
    ID_orden SERIAL,
    detalle VARCHAR(300),
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_orden PRIMARY KEY(ID_orden)
);

CREATE TABLE pagos(
    ID_pago SERIAL,
    pago_total INTEGER NOT NULL,
    fehca_pago TIMESTAMP DEFAULT now() NOT NULL,
    id_orden SERIAL,
    CONSTRAINT pk_pago PRIMARY KEY(ID_pago)
);

CREATE TABLE ordenes_usuarios(
    id_orden SERIAL,
    dni_usuario VARCHAR(15),
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_ordenes_usuarios PRIMARY KEY(id_orden, dni_usuario),
    CONSTRAINT fk_dni_usuario FOREIGN KEY (dni_usuario) REFERENCES usuarios(DNI_usuario),
    CONSTRAINT fk_id_orden FOREIGN KEY (id_orden) REFERENCES ordenes(ID_orden)
);

CREATE TABLE ordenes_actividades(
    id_orden SERIAL,
    id_actividad SERIAL,
    cantidad INTEGER DEFAULT 1,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_ordenes_actividades PRIMARY KEY(ID_orden, ID_actividad),
    CONSTRAINT fk_id_orden FOREIGN KEY (id_orden) REFERENCES ordenes(ID_orden),
    CONSTRAINT fk_id_actividad FOREIGN KEY (id_actividad) REFERENCES actividades(ID_actividad),
    CONSTRAINT ck_ordedenes_actividades CHECK (cantidad >= 0)
);

CREATE TABLE ordenes_comidas(
    id_orden SERIAL,
    id_comida SERIAL,
    cantidad INTEGER DEFAULT 1 NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_ordenes_comidas PRIMARY KEY(ID_orden, ID_comida),
    CONSTRAINT fk_id_orden FOREIGN KEY (id_orden) REFERENCES ordenes(ID_orden),
    CONSTRAINT fk_id_comida FOREIGN KEY (id_comida) REFERENCES comidas(ID_comida),
    CONSTRAINT ck_ordenes_comidas CHECK (cantidad >= 0)
);

CREATE TABLE ordenes_habitaciones(
    id_orden SERIAL,
    id_codigo_habitacion VARCHAR(10),
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_ordenes_habitacion PRIMARY KEY (id_orden, id_codigo_habitacion),
    CONSTRAINT fk_id_orden FOREIGN KEY (id_orden) REFERENCES ordenes(ID_orden),
    CONSTRAINT fk_codigo_habitacion FOREIGN KEY (id_codigo_habitacion) REFERENCES habitaciones (ID_codigo_habitacion)
);

-- NOTE (CREO QUE YA NO SE NECESITA ESTA TABLA) CAMBIAR POR ORDENES_HABITACION NO SE NECESITAN ALQUILES 1 PERSONA PUEDE TENER MUCHAS HABITACIONES
-- CREATE TABLE ordenes_alquileres(
--     id_orden SERIAL,
--     id_alquiler SERIAL,
--     activo BOOLEAN DEFAULT TRUE,
--     CONSTRAINT pk_ordenes_alquileres PRIMARY KEY(ID_orden, ID_alquiler),
--     CONSTRAINT fk_id_orden FOREIGN KEY (id_orden) REFERENCES ordenes(ID_orden),
--     CONSTRAINT fk_id_alquiler FOREIGN KEY (id_alquiler) REFERENCES ordenes(ID_orden)
-- );


Select * FROM habitaciones;

INSERT INTO habitaciones(ID_codigo_habitacion, id_tipo_habitacion, precio)
    VALUES('02-01', 1, 12000 );

insert into ordenes_habitaciones(id_orden, id_codigo_habitacion) 
values(20, '02-01')

select * from ordenes_habitaciones