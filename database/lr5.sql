--\i 'C:/database/lr5.sql'

-- -- tables to json

create or replace procedure copy_to_json(path text = 'C:\database') as $$
declare
    row record;
    temp text;
begin
    for row in select tablename from pg_tables where schemaname = 'public'
    loop
        temp := path || '\' || row.tablename || '.json';
        execute format('copy(select row_to_json(%I) from %1$I) to %L ENCODING ''UTF8''', row.tablename, temp);
    end loop;
end;
$$ language plpgsql;

call copy_to_json();


-- -- save json to table

create or replace procedure save_json_to_table(old_table_name text, new_table_name text, path text) as $$
declare
    row record;
begin
    execute format('create temp table if not exists temp_json_table(json_rows json)');
    execute format('copy temp_json_table from %L', path);
    execute format('drop table if exists %I' , new_table_name);
    execute format('create table %I(like %I including all)', new_table_name, old_table_name);
    execute format('with json_select as (select array_to_json((select array(select json_rows from temp_json_table))))'
    'insert into %I select * from json_populate_recordset(null::%1$I, (select * from json_select))',new_table_name);
    execute format('drop table temp_json_table');
end;
$$ language plpgsql;

call save_json_to_table('styles', 'temp_s', 'C:\\database\\styles.json');
select * from temp_s;


-- -- insert json to table

drop view if exists temp_receipes_plus_beers;
create view temp_receipes_plus_beers as
select beers.id, recipes.og, recipes.fg, recipes.color, recipes."boil time" from beers join recipes
on beers.id = recipes.id order by id limit 100;

create or replace function create_json(temp_id int) returns json as $$
declare
    row record;
    temp json;
begin
   for row in select og, fg, color, "boil time" from temp_receipes_plus_beers where id = temp_id
   loop
        temp := json_build_object('og', row.og, 'fg', row.fg, 'color', row.color, 'boil time', row."boil time");
   end loop;
   return temp;
end;
$$ language plpgsql;

create or replace procedure create_table_json() as $$
begin
    drop table if exists receipes_plus_beers;
    create table if not exists receipes_plus_beers(
        vk_id int primary key not null,
        name varchar,
        "abv id" int not NULL,
        recipes json
    );
    insert into receipes_plus_beers select id, name, "abv id", create_json(id) from beers order by id limit 100;
end;
$$ language plpgsql;


call create_table_json();
select * from receipes_plus_beers;


-- -- extract json fragment from json document

create or replace procedure extract_json_fragment(path text = 'C:/database/styles.json', lim int = 5) as $$
declare
    row record;
begin
    execute format('create temp table if not exists js(info json)');
    execute format('copy js from %L', path);
    for row in select * from js limit lim 
    loop
        raise info '%', row.info;
    end loop;
    execute format('drop table js');
end;
$$ language plpgsql;

call extract_json_fragment();

-- -- extract values of specific nodes

create or replace procedure extract_specific_nodes(path text = 'C:/database/beers.json', t_abv text = 10) as $$
declare
    row record;
begin
    execute format('create temp table if not exists js(info json)');
    execute format('copy js from %L', path);
    for row in select  * from js 
    loop
        if row.info::json->>'abv' = t_abv then
            raise info '% %', row.info::json->'name', row.info::json->'abv';
            end if;
    end loop;
    execute format('drop table js');
end;
$$ language plpgsql;

call extract_specific_nodes();


-- -- check if a node or attribute exists
create or replace procedure attr_exists(path text = 'C:/database/beers.json', field_name text = 'ibu') as $$
declare
    row json;
    flag bool;
begin
    execute format('create temp table if not exists js(info json)');
    execute format('copy js from %L', path);
    select info from js limit 1 into row;
    flag := row::jsonb ? field_name;
    if flag then
        raise info 'exist';
    else
        raise info 'not exist';
        end if;
    execute format('drop table js');
end;
$$ language plpgsql;

call  attr_exists();


-- -- change json document

create or replace procedure change_json(path text = 'C:/database/beers.json') as $$
declare
    row record;
    res jsonb;
    arr json[];
    elem json;
begin
    execute format('create temp table if not exists js(info json)');
    execute format('copy js from %L', path);
    for row in select info from js 
    loop
        if row.info::json->>'style id' = '42' then
            res := jsonb_set(row.info::jsonb, '{style id}', '"Classic Style Smoked Beer"');
            arr = array_append(arr, res::json);
        else
            arr = array_append(arr, row.info::json);
        end if;
    end loop;
    execute format('delete from js');
    foreach elem in array arr 
    loop
        execute format ('insert into js values (%L)', elem);
    end loop;
    execute format('copy (select info from js) to %L ENCODING ''UTF8''', path);
    execute format('drop table js');
end;
$$ language plpgsql;

call change_json();


-- -- split json into multiple lines by nodes

create type sj as (
    id int,
    name character varying(100),
    style int,
    abv int,
    ibu int
);

create or replace function split_json() returns setof sj as $$
declare
    row record;
    elem json;
    el json;
    path text = 'C:/database/tree.json';
begin
    execute format('create temp table if not exists js(info json)');
    execute format('copy js from %L', path);
    for row in select * from js 
    loop
        elem := (row.info::json->>'beers')::json;
        return query execute format('select * from json_populate_recordset(null::sj, %L)', elem);
    end loop;
    execute format('drop table js');
end;
$$ language plpgsql;

select * from split_json();