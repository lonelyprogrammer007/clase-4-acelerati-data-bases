TRUNCATE TABLE owner, parking_space, tenant, lease, contact_info RESTART IDENTITY CASCADE;

-- Inserting Owners
INSERT INTO owner (full_name, document) VALUES
('John Doe', '111111111'),
('Jane Smith', '222222222'),
('Peter Jones', '333333333'),
('Mary Williams', '444444444'),
('David Brown', '555555555'),
('Susan Davis', '666666666'),
('Michael Miller', '777777777'),
('Karen Wilson', '888888888'),
('James Moore', '999999999'),
('Patricia Taylor', '101010101');

-- Inserting Parking Spaces
INSERT INTO parking_space (number, type, ubication_floor, ubication_number, owner_id)
SELECT 1, 'carro'::ejer1aticlase4.parking_space_type_enum, '1', '101', id FROM owner WHERE document = '111111111' UNION ALL
SELECT 2, 'moto'::ejer1aticlase4.parking_space_type_enum, '1', '102', id FROM owner WHERE document = '222222222' UNION ALL
SELECT 3, 'bicicleta'::ejer1aticlase4.parking_space_type_enum, '1', '103', id FROM owner WHERE document = '333333333' UNION ALL
SELECT 4, 'discapacitado'::ejer1aticlase4.parking_space_type_enum, '2', '201', id FROM owner WHERE document = '444444444' UNION ALL
SELECT 5, 'carro'::ejer1aticlase4.parking_space_type_enum, '2', '202', id FROM owner WHERE document = '555555555' UNION ALL
SELECT 6, 'moto'::ejer1aticlase4.parking_space_type_enum, '2', '203', id FROM owner WHERE document = '666666666' UNION ALL
SELECT 7, 'carro'::ejer1aticlase4.parking_space_type_enum, '3', '301', id FROM owner WHERE document = '777777777' UNION ALL
SELECT 8, 'moto'::ejer1aticlase4.parking_space_type_enum, '3', '302', id FROM owner WHERE document = '888888888' UNION ALL
SELECT 9, 'carro'::ejer1aticlase4.parking_space_type_enum, '3', '303', id FROM owner WHERE document = '999999999' UNION ALL
SELECT 10, 'moto'::ejer1aticlase4.parking_space_type_enum, '4', '401', id FROM owner WHERE document = '101010101';

-- Inserting Tenants
INSERT INTO tenant (type, full_name, document) VALUES
('familiar'::ejer1aticlase4.tenant_type_enum, 'Alice Johnson', '121212121'),
('externo'::ejer1aticlase4.tenant_type_enum, 'Bob Anderson', '131313131'),
('vecino'::ejer1aticlase4.tenant_type_enum, 'Charles Thomas', '141414141'),
('familiar'::ejer1aticlase4.tenant_type_enum, 'Diana Jackson', '151515151'),
('externo'::ejer1aticlase4.tenant_type_enum, 'Edward White', '161616161'),
('vecino'::ejer1aticlase4.tenant_type_enum, 'Frances Harris', '171717171'),
('familiar'::ejer1aticlase4.tenant_type_enum, 'George Martin', '181818181'),
('externo'::ejer1aticlase4.tenant_type_enum, 'Helen Thompson', '191919191'),
('vecino'::ejer1aticlase4.tenant_type_enum, 'Ivy Garcia', '202020202'),
('familiar'::ejer1aticlase4.tenant_type_enum, 'Jack Martinez', '212121212');

-- Inserting Contact Info
INSERT INTO contact_info (detail, column_name, owner_id)
SELECT '555-0101', 1, id FROM owner WHERE document = '111111111' UNION ALL
SELECT '555-0102', 2, id FROM owner WHERE document = '111111111' UNION ALL
SELECT '555-0201', 1, id FROM owner WHERE document = '222222222' UNION ALL
SELECT '555-0202', 2, id FROM owner WHERE document = '222222222' UNION ALL
SELECT '555-0301', 1, id FROM owner WHERE document = '333333333' UNION ALL
SELECT '555-0302', 2, id FROM owner WHERE document = '333333333' UNION ALL
SELECT '555-0401', 1, id FROM owner WHERE document = '444444444' UNION ALL
SELECT '555-0402', 2, id FROM owner WHERE document = '444444444' UNION ALL
SELECT '555-0501', 1, id FROM owner WHERE document = '555555555' UNION ALL
SELECT '555-0502', 2, id FROM owner WHERE document = '555555555' UNION ALL
SELECT '555-0601', 1, id FROM owner WHERE document = '666666666' UNION ALL
SELECT '555-0602', 2, id FROM owner WHERE document = '666666666' UNION ALL
SELECT '555-0701', 1, id FROM owner WHERE document = '777777777' UNION ALL
SELECT '555-0702', 2, id FROM owner WHERE document = '777777777' UNION ALL
SELECT '555-0801', 1, id FROM owner WHERE document = '888888888' UNION ALL
SELECT '555-0802', 2, id FROM owner WHERE document = '888888888' UNION ALL
SELECT '555-0901', 1, id FROM owner WHERE document = '999999999' UNION ALL
SELECT '555-0902', 2, id FROM owner WHERE document = '999999999' UNION ALL
SELECT '555-1001', 1, id FROM owner WHERE document = '101010101' UNION ALL
SELECT '555-1002', 2, id FROM owner WHERE document = '101010101';

-- Inserting Leases
INSERT INTO lease (start_date, end_date, tenant_id, parking_space_id, tenant_document_record, tenant_full_name_record, parking_space_ubication_number_record, parking_space_ubication_floor_record, parking_space_type_record, tenant_type)
SELECT '2024-01-15'::date, '2025-01-14'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 1 WHERE t.document = '121212121' UNION ALL
SELECT '2024-02-01'::date, '2025-01-31'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 2 WHERE t.document = '131313131' UNION ALL
SELECT '2024-03-10'::date, '2025-03-09'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 3 WHERE t.document = '141414141' UNION ALL
SELECT '2024-04-05'::date, '2025-04-04'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 4 WHERE t.document = '151515151' UNION ALL
SELECT '2024-05-20'::date, '2025-05-19'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 5 WHERE t.document = '161616161' UNION ALL
SELECT '2024-06-11'::date, '2025-06-10'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 6 WHERE t.document = '171717171' UNION ALL
SELECT '2024-07-22'::date, '2025-07-21'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 7 WHERE t.document = '181818181' UNION ALL
SELECT '2024-08-30'::date, '2025-08-29'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 8 WHERE t.document = '191919191' UNION ALL
SELECT '2024-09-18'::date, '2025-09-17'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 9 WHERE t.document = '202020202' UNION ALL
SELECT '2024-10-25'::date, '2025-10-24'::date, t.id, ps.id, t.document, t.full_name, ps.ubication_number, ps.ubication_floor, ps.type, t.type FROM tenant t JOIN parking_space ps ON ps.number = 10 WHERE t.document = '212121212';