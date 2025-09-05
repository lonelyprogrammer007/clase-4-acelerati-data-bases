-- Establece el search_path por si acaso
SET search_path TO ejer1aticlase4, public;

-- Reemplaza la función existente por esta versión con diagnósticos
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    -- Mensaje de diagnóstico para saber que el trigger se disparó
    RAISE NOTICE '[TRIGGER]: El trigger de auditoría se ha disparado.';
    RAISE NOTICE '[TRIGGER]: OLD.updated_at: %, NEW.updated_at antes del cambio: %', OLD.updated_at, NEW.updated_at;

    -- Guarda de seguridad: Solo actualiza la fecha si los valores de la fila
    -- son realmente diferentes. Previene bucles de actualización infinitos.
    IF row(NEW.*) IS NOT DISTINCT FROM row(OLD.*) THEN
        RAISE NOTICE '[TRIGGER]: No hay cambios en la fila. Saliendo.';
        -- Devuelve OLD para indicarle a PostgreSQL que cancele la operación de UPDATE si no hay cambios.
        RETURN OLD;
    END IF;

    -- La asignación clave
    NEW.updated_at = clock_timestamp();

    RAISE NOTICE '[TRIGGER]: NEW.updated_at después del cambio: %', NEW.updated_at;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;