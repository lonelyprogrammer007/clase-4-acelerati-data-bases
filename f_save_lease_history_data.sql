CREATE OR REPLACE FUNCTION f_save_lease_history_data() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
-- Esta función asume que el esquema correcto (ej. 'acelerati') está
-- en el search_path de la sesión, lo cual es una buena práctica.
BEGIN
    -- Busca los datos del inquilino y los guarda en las columnas de registro.
    -- CORRECCIÓN: Se añade "t.type" al SELECT y "NEW.tenant_type_record" al INTO.
    SELECT t.full_name, t.document, t.type
    INTO NEW.tenant_full_name_record, NEW.tenant_document_record, NEW.tenant_type_record
    FROM tenant t
    WHERE t.id = NEW.tenant_id;

    -- Busca los datos del espacio de parqueo y los guarda en las columnas de registro.
    -- CORRECCIÓN: Se añade "ps.type" al SELECT y "NEW.parking_space_type_record" al INTO.
    SELECT ps.number, ps.ubication_number, ps.ubication_floor, ps.type
    INTO NEW.parking_space_number_record, NEW.parking_space_ubication_number_record, NEW.parking_space_ubication_floor_record, NEW.parking_space_type_record
    FROM parking_space ps
    WHERE ps.id = NEW.parking_space_id;

    RETURN NEW;
END;
$$;
