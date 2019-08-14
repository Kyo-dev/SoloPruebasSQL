--TODO USUARIOS
--NOTE INSERT PERSONAS CON UN TELEFONO
--al crear un usuario necesita como minimo un telefono
--el telefono tiene una coleccion que se debe porder modificar a la hora de insertar
CREATE OR REPLACE FUNCTION fn_crear_usuario(_dni VARCHAR(15), _nombre VARCHAR(20), _apelledo VARCHAR(20), _correo VARCHAR(20), _clave VARCHAR(20), _numero VARCHAR(20), _id_tipo_telefono integer)
RETURNS VOID AS
$BODY$
BEGIN

    INSERT INTO usuarios(DNI_usuario, nombre, apellido, correo, clave)
    VALUES(_dni, _nombre, _apelledo, _correo, _clave);

    INSERT INTO telefonos(numero, DNI_usuario)
    VALUES (_numero, _dni);

    UPDATE telefonos
    SET id_tipo_telefono = _id_tipo_telefono
    WHERE numero = _numero;

END;
$BODY$
LANGUAGE 'plpgsql';

SELECT fn_crear_usuario('309', 'Charlotte', 'Fuentes', 'char@gmail.com', '123', '8989',3)

--TODO ORDENES
--NOTE CREAR UNA ORDEN
--Debe asignarse a un usuario
--El usuario no puede tener una orden activa
CREATE OR REPLACE FUNCTION fn_crear_orden(_detalle VARCHAR(300), _dni_usuario VARCHAR(15))
RETURNS VOID AS
$BODY$
    DECLARE
        _id_orden integer;
BEGIN
    IF NOT EXISTS (SELECT activo 
                  FROM ordenes_usuarios
                  WHERE dni_usuario = _dni_usuario 
                  AND activo = true)                                                        
    THEN
        INSERT INTO ordenes (detalle)
        VALUES (_detalle);
        
        _id_orden = MAX (ID_orden) FROM ordenes;
        
        INSERT INTO ordenes_usuarios (ID_orden, dni_usuario)
        VALUES(_id_orden, _dni_usuario);

    END IF;

END;
$BODY$
LANGUAGE'plpgsql';

Select * from ordenes_usuarios

SELECT fn_crear_orden('Cliente individual', '309');

--NOTE  INGRESAR ACTIVIDADES EN LA ORDEN
--debe existir la orden
CREATE OR REPLACE FUNCTION fn_orden_actividad( _id_orden integer, _id_actividad integer, _cantidad integer)
RETURNS VOID AS
$BODY$
    -- DECLARE
    --     _id_orden integer;
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true) 
AND 
    (SELECT activo
     FROM actividades
     WHERE ID_actividad = _id_actividad 
     AND activo = true))
        THEN
            -- _id_orden = id_orden FROM ordenes_usuarios WHERE activo = true and dni_usuario = _dni_usuario;
            INSERT INTO ordenes_actividades(id_orden, id_actividad, cantidad)
            VALUES (_id_orden, _id_actividad, _cantidad);
END IF;

END;
$BODY$
LANGUAGE 'plpgsql';

SELECT fn_orden_actividad(1, 1, 2)

--NOTE HABITACION
--debe existir la orden
--debe existir la habitacion y no estar ocupada (activo = true)
CREATE OR REPLACE FUNCTION fn_orden_habitacion(_id_orden integer, _id_codigo_habitacion varchar(10))
RETURNS VOID AS
$BODY$
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true) 
AND 
    (SELECT activo
     FROM habitaciones
     WHERE ID_codigo_habitacion = _id_codigo_habitacion
     AND activo = true))
        THEN
            INSERT INTO ordenes_habitaciones (id_orden, id_codigo_habitacion)
            VALUES(_id_orden, _id_codigo_habitacion);

            UPDATE habitaciones
            SET activo = false
            WHERE id_codigo_habitacion = _id_codigo_habitacion;
END IF; 
END;
$BODY$
LANGUAGE 'plpgsql';

SELECT fn_orden_habitacion(1, '02-01')

--NOTE ELIMINAR UNA HABITACION DE LA ORDEN


--NOTE INGRESAR COMIDAS A LA ORDEN
--debe existir la orden 
--si ya existe la comida se debe actualizar la cantidad

CREATE OR REPLACE FUNCTION fn_orden_comida(_id_orden integer, _id_comida integer, _cantidad integer)
RETURNS VOID AS
$BODY$
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true)
AND
    (SELECT activo
    FROM comidas
    WHERE id_comida = _id_comida
    AND activo = true))
        THEN 
            INSERT INTO ordenes_comidas(id_orden, id_comida, cantidad)
            VALUES(_id_orden, _id_comida, _cantidad);
END IF; 
END;
$BODY$
LANGUAGE 'plpgsql';

SELECT fn_orden_comida (1, 1, 2)

CREATE OR REPLACE FUNCTION fn_aumentar_cantidad_orden_comida(_id_orden integer, _id_comida integer, _cantidad integer)
RETURNS VOID AS
$BODY$
    DECLARE
        _cantidad_actual integer;
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true)
AND
    (SELECT activo
    FROM comidas
    WHERE id_comida = _id_comida
    AND activo = true))
        THEN 
            _cantidad_actual = cantidad FROM ordenes_comidas 
                                        WHERE id_orden = _id_orden 
                                        AND id_comida = _id_comida 
                                        AND activo = true;

            UPDATE ordenes_comidas
            SET cantidad = (_cantidad_actual + _cantidad)
            WHERE id_orden = _id_orden
            AND id_comida = _id_comida
            AND activo = true;
END IF; 
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION fn_disminuir_cantidad_orden_comida(_id_orden integer, _id_comida integer, _cantidad integer)
RETURNS VOID AS
$BODY$
    DECLARE
        _cantidad_actual integer;
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true)
AND
    (SELECT activo
    FROM comidas
    WHERE id_comida = _id_comida
    AND activo = true))
        THEN 
            _cantidad_actual = cantidad FROM ordenes_comidas 
                                        WHERE id_orden = _id_orden 
                                        AND id_comida = _id_comida 
                                        AND activo = true;

            UPDATE ordenes_comidas
            SET cantidad = (_cantidad_actual - _cantidad)
            WHERE id_orden = _id_orden
            AND id_comida = _id_comida
            AND activo = true;
END IF; 
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION fn_aumentar_cantidad_orden_actividad(_id_orden integer, _id_comida integer, _cantidad integer)
RETURNS VOID AS
$BODY$
    DECLARE
        _cantidad_actual integer;
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true)
AND
    (SELECT activo
    FROM comidas
    WHERE id_comida = _id_comida
    AND activo = true))
        THEN 
            _cantidad_actual = cantidad FROM ordenes_actividades 
                                        WHERE id_orden = _id_orden 
                                        AND id_actividad = _id_actividad 
                                        AND activo = true;
            UPDATE ordenes_comidas
            SET cantidad = (_cantidad_actual + _cantidad)
            WHERE id_orden = _id_orden
            AND id_comida = _id_comida
            AND activo = true;
END IF; 
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION fn_disminuir_cantidad_orden_actividad(_id_orden integer, _id_actividad integer, _cantidad integer)
RETURNS VOID AS
$BODY$
    DECLARE
        _cantidad_actual integer;
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true)
AND
    (SELECT activo
    FROM actividades
    WHERE id_actividad = _id_actividad
    AND activo = true))
        THEN 
        _cantidad_actual = cantidad FROM ordenes_actividades 
                                    WHERE id_orden = _id_orden 
                                    AND id_actividad = _id_actividad 
                                    AND activo = true;

            UPDATE ordenes_actividades
            SET cantidad = (_cantidad_actual - _cantidad)
            WHERE id_orden = _id_orden
            AND id_actividad = _id_actividad
            AND activo = true;
END IF; 
END;
$BODY$
LANGUAGE 'plpgsql';


--NOTE ELIMINAR ACTIVIDAD DE LA ORDEN
--no debe haber pasado la fecha
CREATE OR REPLACE FUNCTION fn_eliminar_actividad_orden (_id_orden integer, _id_actividad integer)
RETURNS VOID AS
$BODY$
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE id_orden = _id_orden
    AND activo = true)
AND
    (SELECT activo
    FROM actividades
    WHERE id_actividad = _id_actividad
    AND activo = true))
THEN
     UPDATE ordenes_actividades
            SET cantidad = 0
            WHERE id_orden = _id_orden
            AND id_actividad = _id_actividad
            AND activo = true;

END IF;
END;
$BODY$
LANGUAGE 'plpgsql';


--TODO PAGO DE LA ORDEN
--suma de los totales de comida, habitacion y actividad vinculada a la orden del usuario

CREATE OR REPLACE FUNCTION fn_pago_orden(_dni_usuario VARCHAR(15))
RETURNS integer AS
$BODY$
    DECLARE
        _pago_actividades INTEGER;
        _pago_comidas INTEGER;
        _pago_habitaciones INTEGER;
        _pago_total integer;
BEGIN
IF((SELECT activo
    FROM ordenes_usuarios
    WHERE activo = true)
AND
    (SELECT activo
    FROM usuarios
    WHERE dni_usuario = _dni_usuario
    AND activo = true))
THEN
    _pago_total = 0;
    _pago_comidas = SUM(a.cantidad * d.precio) FROM ordenes_comidas a JOIN comidas d ON a.id_comida = d.id_comida;
    _pago_actividades = SUM(a.cantidad * b.precio) FROM ordenes_actividades a JOIN actividades b ON b.id_actividad = a.id_actividad;
    _pago_habitaciones = SUM
    _pago_total = _pago_comidas + _pago_actividades;
    RETURN _pago_total;

END IF;
END;
$BODY$
LANGUAGE 'plpgsql';

SELECT fn_pago_orden('309')

select _pago_comida

SELECT * FROM usuarios



















