-- Test Queries for the Database

-- Select all owners
SELECT * FROM owner;

-- Select all tenants
SELECT * FROM tenant;

-- Select all parking spaces with their owner's full name
SELECT ps.id, ps.number, ps.type, ps.ubication_floor, ps.ubication_number, o.full_name AS owner_name
FROM parking_space ps
JOIN owner o ON ps.owner_id = o.id;

-- Select all leases with tenant's and owner's information
SELECT 
    l.id AS lease_id,
    l.start_date,
    l.end_date,
    t.full_name AS tenant_name,
    t.type AS tenant_type,
    ps.number AS parking_space_number,
    ps.type AS parking_space_type,
    o.full_name AS owner_name
FROM lease l
JOIN tenant t ON l.tenant_id = t.id
JOIN parking_space ps ON l.parking_space_id = ps.id
JOIN owner o ON ps.owner_id = o.id;

-- Select contact information for a specific owner (e.g., John Doe with document '111111111')
SELECT ci.detail, ci.column_name
FROM contact_info ci
JOIN owner o ON ci.owner_id = o.id
WHERE o.document = '111111111';

-- Select all leases for a specific tenant (e.g., Alice Johnson with document '121212121')
SELECT l.id, l.start_date, l.end_date, ps.number AS parking_space_number
FROM lease l
JOIN tenant t ON l.tenant_id = t.id
JOIN parking_space ps ON l.parking_space_id = ps.id
WHERE t.document = '121212121';

-- Select all parking spaces of type 'carro'
SELECT * FROM parking_space WHERE type = 'carro'::ejer1aticlase4.parking_space_type_enum;

-- Count the number of parking spaces by type
SELECT type, COUNT(*) AS total
FROM parking_space
GROUP BY type;

-- Example of an UPDATE statement (commented out by default)
/*
UPDATE tenant
SET full_name = 'Alice Williams'
WHERE document = '121212121';
*/

-- Example of a DELETE statement (commented out by default)
/*
-- First, find the lease id for a specific tenant
-- SELECT id FROM lease WHERE tenant_id = (SELECT id FROM tenant WHERE document = '121212121');

-- Then, delete the lease with that id
-- DELETE FROM lease WHERE id = 'your_lease_id_here';
*/
