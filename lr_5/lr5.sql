--\i 'C:/Users/mir80/Desktop/database/lr_5/lr5.sql'
-- tables to json
create or replace procedure copy_json(path text = 'C:\Users\mir80\Desktop\database\lr_5') as $$
declare
    row record;
    tmp_ text;
begin
    for row in select tablename from pg_tables where schemaname = 'public'
    loop
    tmp_ := path || '\' || row.tablename || '.json';
    execute format('copy (select row_to_json(%I) from %1$I) to %L', row.tablename, tmp_);
    end loop;
end;
$$ language plpgsql;

call copy_json();