create function f_save_lease_history_data() returns trigger
    language plpgsql
as
$$
BEGIN
    SELECT full_name, document
    INTO NEW.tenant_full_name_record, NEW.tenant_document_record
    FROM "ejer1aticlase4".tenant
    WHERE tenant.id = NEW.tenant_id;

    SELECT number, ubication_number, ubication_floor, type
    INTO NEW.parking_space_number_record, NEW.parking_space_ubication_number_record, NEW.parking_space_ubication_floor_record, NEW.parking_space_type_record
    FROM "ejer1aticlase4".parking_space
    WHERE parking_space.id = NEW.parking_space_id;

    RETURN NEW;
END;
$$;

alter function f_save_lease_history_data() owner to postgres;