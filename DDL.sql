BEGIN; -- Inicia la transacción

-- Crea el esquema si no existe
CREATE SCHEMA IF NOT EXISTS ejer1aticlase4;

-- Asigna permisos totales sobre este esquema al usuario
GRANT ALL ON SCHEMA ejer1aticlase4 TO acelerati;

-- Establece el orden de búsqueda de esquemas para la sesión actual.
-- Esto hace que no tengas que escribir 'ejer1aticlase4.' en cada objeto.
SET search_path TO ejer1aticlase4, public;

-- ===== A PARTIR DE AQUÍ VA TU CÓDIGO EXISTENTE =====

create type parking_space_type_enum as enum ('carro', 'moto', 'bicicleta', 'discapacitado');

create type tenant_type_enum as enum ('familiar', 'externo', 'vecino');

create table owner
(
    id        uuid default gen_random_uuid() not null
        constraint owner_pk
            primary key,
    full_name varchar                        not null,
    document  varchar                        not null
        constraint owner_unique_document
            unique
);

create table parking_space
(
    id               uuid                                   default gen_random_uuid()                               not null
        constraint parking_space_pk
            primary key,
    number           integer                                                                                        not null
        constraint parking_space_unique_number
            unique,
    type             parking_space_type_enum default 'carro'::parking_space_type_enum not null,
    ubication_floor  varchar                                default '-1'::character varying                         not null,
    ubication_number varchar                                default '-1'::character varying                         not null,
    owner_id         uuid                                                                                           not null
        constraint parking_space_owner_id_fk
            references owner
            on delete set null,
    constraint parking_space_unique_ubication
        unique (ubication_floor, ubication_number)
);

comment on table parking_space is 'espacios de parqueo del edificio';

comment on column parking_space.number is 'numero unico que identifica el lugar';

comment on column parking_space.type is 'carro o moto';

comment on constraint parking_space_unique_ubication on parking_space is 'no pueden existir en el mismo piso dos ubicaciones repetidas';

create table tenant
(
    id        uuid                            default gen_random_uuid()                          not null
        constraint tenant_pk
            primary key,
    type      tenant_type_enum default 'externo'::tenant_type_enum not null,
    full_name varchar                         default 'N/A'::character varying                   not null,
    document  varchar                         default '1'::character varying                     not null
        constraint tenant_unique_document
            unique
);

comment on table tenant is 'para guardar el arrendatario';

create table lease
(
    id                                    uuid default gen_random_uuid()         not null
        constraint lease_pk
            primary key,
    start_date                            date default now()                     not null,
    end_date                              date default now()                     not null,
    tenant_id                             uuid                                   not null
        constraint lease_tenant_id_fk
            references tenant
            on delete set null,
    parking_space_id                      uuid                                   not null
        constraint lease_parking_space_id_fk
            references parking_space
            on delete set null,
    tenant_document_record                varchar                                not null,
    tenant_full_name_record               varchar                                not null,
    parking_space_ubication_number_record varchar                                not null,
    parking_space_ubication_floor_record  varchar                                not null,
    parking_space_type_record             parking_space_type_enum not null,
    tenant_type                           tenant_type_enum        not null
);

comment on table lease is 'permite almacenar lo arrendaientos e la bd';

create table contact_info
(
    id          uuid default gen_random_uuid() not null
        constraint contact_info_pk
            primary key,
    detail      varchar                        not null,
    owner_id    uuid                           not null
        constraint contact_info_owner_id_fk
            references owner
            on delete cascade
);

create function f_save_lease_history_data() returns trigger
    language plpgsql
as
$$
BEGIN
    SELECT full_name, document
    INTO NEW.tenant_full_name_record, NEW.tenant_document_record
    FROM "ejer1aticlase4".tenant
    WHERE tenant.id = NEW.tenant_id;

    SELECT number, ubication_number, ubication_floor
    INTO NEW.parking_space_number_record, NEW.parking_space_ubication_number_record, NEW.parking_space_ubication_floor_record
    FROM "ejer1aticlase4".parking_space
    WHERE parking_space.id = NEW.parking_space_id;

    RETURN NEW;
END;
$$;

-- auto-generated definition
create trigger trg_save_lease_data_record
    before insert or update
    on lease
    for each row
execute procedure f_save_lease_history_data();

COMMIT; -- Confirma la transacción SOLO si todo fue exitoso

