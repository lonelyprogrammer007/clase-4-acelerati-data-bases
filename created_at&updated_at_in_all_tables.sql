BEGIN; -- Inicia la transacción

-- Crea el esquema si no existe
CREATE SCHEMA IF NOT EXISTS ejer1aticlase4;

-- Asigna permisos totales sobre este esquema al usuario
GRANT ALL ON SCHEMA ejer1aticlase4 TO acelerati;

-- Establece el orden de búsqueda de esquemas para la sesión actual.
-- Esto hace que no tengas que escribir 'ejer1aticlase4.' en cada objeto.
SET search_path TO ejer1aticlase4, public;

-- =====================================================================
-- Script para añadir campos de auditoría (created_at, updated_at)
-- a todas las tablas de un esquema específico en PostgreSQL.
-- =====================================================================

-- PASO 1: Crear la función reutilizable para el trigger de actualización.
-- Esta función se ejecutará cada vez que una fila sea actualizada.
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    -- NEW es una variable especial en los triggers que contiene la nueva
    -- versión de la fila que está siendo modificada.
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================

-- PASO 2: Bloque anónimo para iterar sobre las tablas y aplicar los cambios.
DO $$
DECLARE
    -- !! IMPORTANTE: Cambia 'tu_esquema' por el nombre de tu esquema.
    nombre_esquema TEXT := 'ejer1aticlase4';
    nombre_tabla   RECORD;
BEGIN
    -- Este bucle FOR itera sobre cada tabla encontrada en el esquema especificado.
    -- Se excluyen las vistas (is_insertable_into = 'YES').
    FOR nombre_tabla IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = nombre_esquema AND is_insertable_into = 'YES'
    LOOP
        -- Imprime un mensaje para saber qué tabla se está procesando.
        RAISE NOTICE 'Configurando tabla: %.%', nombre_esquema, nombre_tabla.table_name;

        -- Añade la columna 'created_at' si no existe.
        -- Se establece con un valor por defecto para que las filas existentes
        -- y las nuevas inserciones obtengan la fecha y hora actual.
        EXECUTE format(
            'ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()',
            nombre_esquema, nombre_tabla.table_name
        );

        -- Añade la columna 'updated_at' si no existe.
        -- También se le pone un valor por defecto para las filas existentes.
        EXECUTE format(
            'ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()',
            nombre_esquema, nombre_tabla.table_name
        );

        -- Crea el trigger para actualizar 'updated_at' en cada UPDATE.
        -- Primero se elimina por si ya existía, para hacer el script re-ejecutable.
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trigger_actualizar_fecha_modificacion ON %I.%I',
            nombre_esquema, nombre_tabla.table_name
        );
        EXECUTE format(
            'CREATE TRIGGER trigger_actualizar_fecha_modificacion
             BEFORE UPDATE ON %I.%I
             FOR EACH ROW
             EXECUTE FUNCTION actualizar_fecha_modificacion()',
            nombre_esquema, nombre_tabla.table_name
        );

    END LOOP;
    RAISE NOTICE '¡Proceso completado para el esquema %!', nombre_esquema;
END $$;

COMMIT; -- Confirma la transacción SOLO si todo fue exitoso