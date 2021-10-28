\i 'C:/Users/mir80/Desktop/database/CLRs.sql'

-- создать таблицу 
-- один из атрибутов пользовательский тип
-- инсертим одну строку
-- читаем всю строку
-- после читаем один атрибут из типа

-- create type my_temp_type as(
--     abv int,
--     ibu int
-- );

-- CREATE TABLE temp_t_table(
--     id int,
--     data_t my_temp_type
-- );

-- insert into temp_t_table(id, data_t) values(1, (4, 8));

-- select * from temp_t_table;

-- select (data_t).abv from temp_t_table;



-- -- CLR user-defined scalar function

-- create or replace function info(id int) returns varchar as 
-- $$
--     p_table = plpy.execute("select * from beers", 10)
--     for element in p_table:
--         if element['id'] == id:
--             return element['name'], element['abv'], element['ibu']
--     return 'None'
-- $$ language plpython3u;

-- select * from info(4);


-- -- CLR aggregate function
-- \\добавить агрегатность к функции(обертка агрегатная)
-- create or replace function how_beers_in_such_style(id_style int) returns float as 
-- $$
--     p_table = plpy.execute("select * from beers")
--     quantity = 0
--     for element in p_table:
-- 	    if element['style id'] == id_style:
-- 		    quantity += 1
--     return quantity
-- $$ language plpython3u;

-- select * from how_beers_in_such_style(50);


-- -- CLR user-defined table function

-- create or replace function what_beers_in_such_style(id_style int) returns table (id int, name text) as 
-- $$
--     p_table = plpy.execute("select * from beers")
--     result_array = []
--     for element in p_table:
-- 	    if element['style id'] == id_style:
-- 		    result_array.append(element)
--     return result_array
-- $$ language plpython3u;

-- select * from what_beers_in_such_style(51);


-- -- CLR stored procedure

-- drop table if exists temp_table;
-- select id, name, abv
-- into temp_table
-- from beers
-- limit 20;

-- create or replace procedure new_abv(id int, n_abv int) as
-- $$
--     plan = plpy.prepare("update temp_table set abv = $2 where id = $1;", ["int", "int"])
--     plpy.execute(plan, [id, n_abv])
-- $$ language plpython3u;

-- call new_abv(1,10);

-- select * from temp_table
-- order by id;


-- -- CLR trigger

-- drop table if exists temp_table;
-- select id, name, ibu
-- into temp_table
-- from beers
-- limit 20;

-- create or replace function insert_instead_update() returns trigger as 
-- $$
--     plan = plpy.prepare("insert into temp_table(id, name, ibu) values($1, $2, $3);", ["int", "varchar", "int"])
--     plpy.execute(plan, [TD['old']["id"],TD['old']["name"], TD['old']["ibu"]])
--     return None
-- $$ language  plpython3u;

-- drop trigger if exists update_trigger on temp_table cascade; 

-- create trigger update_trigger
-- after update on temp_table for each row 
-- execute function insert_instead_update();

-- SELECT * FROM temp_table;

-- UPDATE temp_table
-- SET ibu = 28
-- WHERE id = 1;

-- SELECT * FROM temp_table
-- ORDER by id;

-- -- CLR user-defined data type

-- drop table if exists temp_table;
-- select id, name, abv, ibu
-- into temp_table
-- from beers
-- limit 20;

-- create type beer_info as
-- (
--   name varchar,
--   abv int,
--   ibu int
-- );

-- create or replace function beers_info(id int) returns beer_info as 
-- $$
--     plan = plpy.prepare("select name, abv, ibu from temp_table where id = $1", ["int"])
--     p_table = plpy.execute(plan, [id])
--     return [p_table[0]['name'], p_table[0]['abv'], p_table[0]['ibu']]
-- $$ language plpython3u;

-- select * from beers_info(2);

-- select name, abv, ibu
-- from temp_table
-- where id = 2;