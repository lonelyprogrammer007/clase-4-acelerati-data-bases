BEGIN; -- Inicia la transacción
/*
 * SCRIPT PARA PRUEBA MANUAL DE CAMPOS DE AUDITORÍA
 * Ejecutar este bloque completo en DataGrip.
 * Propósito: Verificar si el trigger 'trigger_actualizar_fecha_modificacion'
 * actualiza correctamente el campo 'updated_at' al ser mayor que 'created_at'.
 */
DO $$
DECLARE
    -- Variables para almacenar los valores y el ID
    new_owner_id                  UUID;
    created_ts                    TIMESTAMPTZ;
    updated_ts_after_insert       TIMESTAMPTZ;
    updated_ts_after_update       TIMESTAMPTZ;
BEGIN
    -- Establece el search_path para esta sesión, igual que en las pruebas.
    SET search_path TO ejer1aticlase4, public;

    RAISE NOTICE '--- INICIO DE LA PRUEBA MANUAL ---';

    -- 1. INSERTAR un nuevo registro.
    -- Usamos RETURNING para capturar los valores iniciales inmediatamente.
    INSERT INTO owner (full_name, document)
    VALUES ('Manual Test Owner', '123456789-TEST')
    RETURNING id, created_at, updated_at INTO new_owner_id, created_ts, updated_ts_after_insert;

    RAISE NOTICE 'Registro insertado con ID: %', new_owner_id;
    RAISE NOTICE 'Después del INSERT --> created_at: %, updated_at: %', created_ts, updated_ts_after_insert;
    RAISE NOTICE '¿Son iguales? --> %', created_ts = updated_ts_after_insert;

    -- 2. ESPERAR un tiempo para asegurar una diferencia de tiempo real.
    RAISE NOTICE 'Esperando 1 segundo...';
    PERFORM pg_sleep(1);

    -- 3. ACTUALIZAR el registro. Esto debería disparar el trigger.
    -- Usamos RETURNING de nuevo para capturar el valor de 'updated_at' modificado por el trigger.
    UPDATE owner
    SET full_name = 'Manual Test Owner UPDATED'
    WHERE id = new_owner_id
    RETURNING updated_at INTO updated_ts_after_update;

    RAISE NOTICE 'Después del UPDATE --> updated_at: %', updated_ts_after_update;

    -- 4. VERIFICACIÓN FINAL Y LIMPIEZA
    RAISE NOTICE '--- VERIFICACIÓN ---';
    RAISE NOTICE 'created_at: %', created_ts;
    RAISE NOTICE 'updated_at final: %', updated_ts_after_update;

    -- La condición que falla en tu prueba pgTAP
    IF updated_ts_after_update > created_ts THEN
        RAISE NOTICE 'RESULTADO: ✅ ÉXITO. El updated_at es mayor que el created_at.';
    ELSE
        RAISE NOTICE 'RESULTADO: ❌ FALLO. El updated_at NO es mayor que el created_at.';
    END IF;

    -- 5. Limpiar el registro de prueba para que el script sea re-ejecutable.
    DELETE FROM owner WHERE id = new_owner_id;
    RAISE NOTICE 'Registro de prueba con ID % eliminado.', new_owner_id;
    RAISE NOTICE '--- FIN DE LA PRUEBA ---';

END $$;

ROLLBACK; -- Deshace todos los cambios hechos en la transacción