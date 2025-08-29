-- auto-generated definition
create trigger trg_save_lease_data_record
    before insert or update
    on lease
    for each row
execute procedure f_save_lease_history_data();