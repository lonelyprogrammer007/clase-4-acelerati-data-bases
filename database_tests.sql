-- =============================================================================
-- PRUEBAS UNITARIAS DE LA BASE DE DATOS CON pgTAP
-- =============================================================================
--
-- QUÉ ES ESTO?
-- Este script utiliza la extensión de PostgreSQL llamada pgTAP para ejecutar
-- pruebas unitarias sobre nuestra base de datos. Las pruebas verifican que la
-- estructura (tablas, columnas, etc.) y la lógica (triggers, funciones)
-- funcionen como se espera.
--
-- CÓMO FUNCIONA?
-- 1. BEGIN: Todo se envuelve en una transacción.
-- 2. SETUP: Se define el esquema 'acelerati' y se activa la extensión pgTAP.
-- 3. PLAN: Se declara cuántas pruebas se van a ejecutar.
-- 4. TESTS: Se ejecutan las pruebas usando funciones de pgTAP (has_table, ok, etc).
-- 5. FINISH & ROLLBACK: Al final, `finish()` verifica el plan y `ROLLBACK`
--    deshace TODOS los cambios (inserts, updates) que las pruebas hicieron.
--    Esto deja la base de datos en su estado original, ¡es como si nada hubiera pasado!
--
-- CÓMO EJECUTARLO?
-- Desde una terminal, usando psql:
-- psql -U acelerati -d tu_base_de_datos -f database_tests.sql
--
-- =============================================================================

-- Inicia la transacción que será deshecha al final.
BEGIN;

-- --- CONFIGURACIÓN ---
-- Define el esquema a utilizar para que no tengamos que escribirlo repetidamente.
\set schema_name 'ejer1aticlase4'

-- Activa la extensión pgTAP. Si no existe, la crea.
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Establece el `search_path` para que PostgreSQL busque objetos en nuestro
-- esquema por defecto. Esto nos permite escribir `owner` en lugar de `acelerati.owner`.
SET search_path TO :schema_name, public;


-- --- PLAN DE PRUEBAS ---
-- Declara el número total de pruebas que se ejecutarán.
-- Es crucial que este número sea exacto.
-- Total: 25 pruebas (22 originales + 1 de auditoría + 1 corregida)
SELECT plan(25);


-- --- SECCIÓN 1: PRUEBAS DE ESTRUCTURA (EXISTENCIA DE OBJETOS) ---
-- Estas pruebas validan que las tablas y columnas principales existan.

SELECT has_table('owner', 'La tabla owner debe existir');
SELECT has_table('parking_space', 'La tabla parking_space debe existir');
SELECT has_table('tenant', 'La tabla tenant debe existir');
SELECT has_table('lease', 'La tabla lease debe existir');
SELECT has_table('contact_info', 'La tabla contact_info debe existir');

-- Verificamos columnas y sus tipos.
SELECT has_column('owner', 'id', 'La tabla owner debe tener una columna id');
SELECT col_type_is('owner', 'id', 'uuid', 'La columna owner.id debe ser de tipo uuid');
SELECT has_column('owner', 'full_name', 'La tabla owner debe tener una columna full_name');
SELECT col_type_is('owner', 'full_name', 'character varying', 'La columna owner.full_name debe ser de tipo character varying');

-- Gracias a `search_path`, ya no necesitamos el nombre del esquema en el tipo enum.
SELECT has_column('parking_space', 'type', 'La tabla parking_space debe tener una columna type');
SELECT col_type_is('parking_space', 'type', 'parking_space_type_enum', 'La columna parking_space.type debe ser del enum parking_space_type_enum');


-- --- SECCIÓN 2: PRUEBAS DE RESTRICCIONES (CONSTRAINTS) ---
-- Verifican que las llaves primarias y foráneas estén definidas correctamente.

-- Llaves Primarias (PK)
SELECT has_pk('owner', 'La tabla owner debe tener una llave primaria');
SELECT has_pk('parking_space', 'La tabla parking_space debe tener una llave primaria');
SELECT has_pk('tenant', 'La tabla tenant debe tener una llave primaria');
SELECT has_pk('lease', 'La tabla lease debe tener una llave primaria');

-- Llaves Foráneas (FK)
SELECT has_fk('parking_space', 'parking_space debe tener una FK hacia owner');
SELECT has_fk('lease', 'lease debe tener una FK hacia tenant');
SELECT has_fk('lease', 'lease debe tener una FK hacia parking_space');
SELECT has_fk('contact_info', 'contact_info debe tener una FK hacia owner');


-- --- SECCIÓN 3: PRUEBAS DE LÓGICA DE NEGOCIO (TRIGGERS) ---

-- Prueba para el trigger `trg_save_lease_data_record`
-- Se insertan datos de prueba para simular la creación de un contrato.
INSERT INTO owner (id, full_name, document) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Test Owner', '999999999');
INSERT INTO parking_space (id, number, type, ubication_floor, ubication_number, owner_id) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 999, 'carro', '1', '1', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
INSERT INTO tenant (id, type, full_name, document) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'externo', 'Test Tenant', '888888888');

-- Se crea el contrato, lo que debería disparar el trigger.
INSERT INTO lease (id, start_date, end_date, tenant_id, parking_space_id)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', '2025-01-01', '2025-12-31', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12');

-- `results_eq` compara el resultado de una consulta con un resultado esperado.
-- Aquí verificamos si el trigger copió correctamente los datos históricos.
SELECT results_eq(
    'SELECT tenant_full_name_record, tenant_document_record FROM lease WHERE id = ''a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14''',
    'VALUES (''Test Tenant'', ''888888888'')',
    'El trigger debe guardar los datos históricos del inquilino en la tabla lease'
);

-- *** NUEVA PRUEBA DE AUDITORÍA ***
-- Prueba para el trigger `trigger_actualizar_fecha_modificacion`
-- 1. Actualizamos el propietario que acabamos de insertar.
UPDATE owner SET full_name = 'Test Owner Updated' WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
-- 2. `ok` verifica si una condición es verdadera.
--    Aquí comprobamos que `updated_at` es posterior a `created_at` después del UPDATE.
SELECT ok(
    updated_at > created_at,
    'El campo updated_at debe ser mayor que created_at después de una actualización'
) FROM owner WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';


-- --- SECCIÓN 4: PRUEBAS DE INTEGRIDAD DE DATOS ---

-- Verifican que los datos iniciales o los tipos (enums) sean correctos.
SELECT enum_has_labels('parking_space_type_enum', ARRAY['carro', 'moto', 'bicicleta', 'discapacitado'], 'El enum parking_space_type_enum debe tener las etiquetas correctas');
SELECT enum_has_labels('tenant_type_enum', ARRAY['familiar', 'externo', 'vecino'], 'El enum tenant_type_enum debe tener las etiquetas correctas');

-- Verificamos que los datos del script `populate_database.sql` existan.
SELECT results_eq(
    'SELECT full_name FROM owner WHERE document = ''111111111''',
    'VALUES (''John Doe'')',
    'Debe ser posible encontrar a John Doe en la tabla owner'
);

-- **PRUEBA CORREGIDA**
-- `isnt_empty` verifica que una consulta DEVUELVE resultados (lo contrario de `is_empty`).
-- Aquí verificamos que sí existe un contrato para el inquilino con documento '121212121'.
SELECT isnt_empty(
    'SELECT 1 FROM lease WHERE tenant_document_record = ''121212121''',
    'Debe existir un contrato para el inquilino con documento 121212121'
);


-- --- FINALIZACIÓN ---
-- `finish()` revisa si todas las pruebas del plan se ejecutaron.
SELECT * FROM finish();

-- `ROLLBACK` deshace todos los cambios hechos durante la prueba.
ROLLBACK;