create or replace procedure dump_func() as $$
    declare
        temp_ text;
        db text;
        table_ record;
        file_name text;
    begin
        for table_ in select tablename from pg_catalog.pg_tables where schemaname='public'
        loop
            db := (select current_database());
            temp_ := current_date::text;
            file_name := 'C:\database\' || db || '_' || table_.tablename || '_' || temp_ || '.csv';
            execute format('copy (select * from %I) to %L CSV', table_.tablename, file_name);
        end loop;
    end;
$$ language plpgsql;

call dump_func();