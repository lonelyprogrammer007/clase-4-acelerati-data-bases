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
-- v3: Usa clock_timestamp() para mayor precisión en la auditoría.
-- =====================================================================

-- PASO 1: Crear la función reutilizable para el trigger de actualización.
-- USA CLOCK_TIMESTAMP() en lugar de NOW() para reflejar la hora real de la
-- modificación, no la hora de inicio de la transacción.
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = clock_timestamp();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PASO 2: Bloque anónimo para iterar sobre las tablas y aplicar los cambios.
DO $$
DECLARE
    -- !! IMPORTANTE: Cambia 'tu_esquema' por el nombre de tu esquema.
    nombre_esquema TEXT := 'ejer1aticlase4';
    nombre_tabla   RECORD;
BEGIN
    FOR nombre_tabla IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = nombre_esquema AND is_insertable_into = 'YES'
    LOOP
        RAISE NOTICE 'Configurando tabla: %.%', nombre_esquema, nombre_tabla.table_name;

        -- Se cambia el DEFAULT a clock_timestamp() para consistencia.
        EXECUTE format(
            'ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()',
            nombre_esquema, nombre_tabla.table_name
        );
        EXECUTE format(
            'ALTER TABLE %I.%I ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()',
            nombre_esquema, nombre_tabla.table_name
        );

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

COMMIT; -- Confirma la transacción
