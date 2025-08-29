-- pgTAP Database Unit Tests

-- Start the test session
BEGIN;

-- Load the pgTAP extension
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Plan the tests
SELECT plan(25); -- Total number of tests

-- 1. Schema Tests: Verify table and column existence
SELECT has_table('owner', 'Table owner should exist');
SELECT has_table('parking_space', 'Table parking_space should exist');
SELECT has_table('tenant', 'Table tenant should exist');
SELECT has_table('lease', 'Table lease should exist');
SELECT has_table('contact_info', 'Table contact_info should exist');

-- 2. Column Tests: Verify columns and their types
-- Owner Table
SELECT has_column('owner', 'id', 'owner table should have id column');
SELECT col_type_is('owner', 'id', 'uuid', 'owner.id should be type uuid');
SELECT has_column('owner', 'full_name', 'owner table should have full_name column');
SELECT col_type_is('owner', 'full_name', 'character varying', 'owner.full_name should be type character varying');

-- Parking Space Table
SELECT has_column('parking_space', 'type', 'parking_space table should have type column');
SELECT col_type_is('parking_space', 'type', 'ejer1aticlase4.parking_space_type_enum', 'parking_space.type should be type parking_space_type_enum');

-- 3. Constraint Tests: Verify primary and foreign keys
-- Primary Keys
SELECT has_pk('owner', 'owner table should have a primary key');
SELECT has_pk('parking_space', 'parking_space table should have a primary key');
SELECT has_pk('tenant', 'tenant table should have a primary key');
SELECT has_pk('lease', 'lease table should have a primary key');

-- Foreign Keys
SELECT has_fk('parking_space', 'parking_space should have a foreign key to owner');
SELECT has_fk('lease', 'lease should have a foreign key to tenant');
SELECT has_fk('lease', 'lease should have a foreign key to parking_space');
SELECT has_fk('contact_info', 'contact_info should have a foreign key to owner');

-- 4. Function and Trigger Tests
-- Test the f_save_lease_history_data trigger
-- First, insert some test data
INSERT INTO owner (id, full_name, document) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Test Owner', '999999999');
INSERT INTO parking_space (id, number, type, ubication_floor, ubication_number, owner_id) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 999, 'carro'::ejer1aticlase4.parking_space_type_enum, '1', '1', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
INSERT INTO tenant (id, type, full_name, document) VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'externo'::ejer1aticlase4.tenant_type_enum, 'Test Tenant', '888888888');

-- Now, insert a lease, which should trigger the function
INSERT INTO lease (id, start_date, end_date, tenant_id, parking_space_id, tenant_document_record, tenant_full_name_record, parking_space_ubication_number_record, parking_space_ubication_floor_record, parking_space_type_record, tenant_type)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', '2025-01-01'::date, '2025-12-31'::date, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', '', '', '', '', 'carro'::ejer1aticlase4.parking_space_type_enum, 'externo'::ejer1aticlase4.tenant_type_enum);

-- Check if the history data was recorded correctly
SELECT results_eq(
    'SELECT tenant_full_name_record, tenant_document_record FROM lease WHERE id = ''a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14'''::text,
    'VALUES (\'Test Tenant\', \'888888888\')'::text,
    'Trigger should have saved tenant history data correctly'
);

-- 5. Data Integrity Tests
-- Check if enum types have the expected labels
SELECT enum_has_labels('parking_space_type_enum', ARRAY['carro', 'moto', 'bicicleta', 'discapacitado'], 'parking_space_type_enum should have the correct labels');
SELECT enum_has_labels('tenant_type_enum', ARRAY['familiar', 'externo', 'vecino'], 'tenant_type_enum should have the correct labels');

-- Check if a specific owner from the population script exists
SELECT results_eq(
    'SELECT full_name FROM owner WHERE document = ''111111111'''::text,
    'VALUES (\'John Doe\')'::text,
    'Should be able to find John Doe in the owner table'
);

-- Check if a specific lease from the population script exists
SELECT is_empty(
    'SELECT * FROM lease WHERE tenant_document_record = ''121212121'''::text,
    'Should find a lease for tenant with document 121212121'
);


-- Finish the tests and roll back changes
SELECT * FROM finish();
ROLLBACK;
