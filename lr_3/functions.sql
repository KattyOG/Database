-- scalar
-- можно реализовать через text []

-- create type rec_type2 as (
--     data rec_type
-- ); 
-- create type rec_type as (
--     id int,
--     style varchar
-- );
-- create or replace function scalar_func(u_style text) returns rec_type2 as
-- $$
-- declare 
--     r rec_type;
--     f rec_type2;
-- begin
--     select id, style
-- 	from styles
-- 	where style = u_style into r;
--     f.data := r;
--     return f;
-- end;
-- $$ 
-- language plpgsql;

-- select * from scalar_func('Altbier');

-- -- inserted table function

-- create or replace function inserted_table_func(temp int) returns beers as
-- $$
-- 	select *
-- 	from beers
-- 	where abv = temp
-- $$ language sql;

-- select * from inserted_table_func(8); 


-- -- multi-operator table function

-- create or replace function multi_table_func() returns int as
-- $$
-- declare
--     beers_t int[];
--     max_num int;
--     temp_p int;
--     elem int;
--     count int;
-- begin
--     max_num := (
--         select max(abv)
--         from beers
--     );
--     beers_t := array(
--         select id
--         from beers
--     );
--     count := 0;
--     foreach elem in array beers_t
--     loop
--         temp_p := (select abv from beers where id = elem);
--         if temp_p = max_num
--             then count := count + 1;
--         end if;
--     end loop;
--     return count;
-- end;
-- $$ language plpgsql;

-- select *
-- from multi_table_func();



-- recursive function

-- create or replace function recursion_func() returns table(id int, style text)
-- as
-- 	$$
--     with recursive rec_table as
--     (
--         select id as index, style as style_name from styles where id = 1
--         union 
--         select styles.id as index, styles.style as style_name
--         from rec_table join styles on rec_table.index + 1 = styles.id
--         where styles.id <= 10
--     )
--     select * from rec_table;
-- 	$$ language sql;

-- select *
-- from recursion_func();


create or replace function find_grants(schema_name text, table_name text) returns text
as
	$$
    declare 
        full_table_name varchar default format('%I.%I', $1, $2);
        table_grants text;
        role_name record;
    begin

        table_grants:= '';

            for role_name in
        (
        select rolname
        from pg_catalog.pg_roles pr
        ) loop

        if has_table_privilege(role_name.rolname, full_table_name, 'SELECT')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT SELECT ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        if has_table_privilege(role_name.rolname, full_table_name, 'INSERT')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT INSERT ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        if has_table_privilege(role_name.rolname, full_table_name, 'UPDATE')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT UPDATE ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        if has_table_privilege(role_name.rolname, full_table_name, 'DELETE')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT DELETE ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        if has_table_privilege(role_name.rolname, full_table_name, 'TRUNCATE')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT TRUNCATE ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        if has_table_privilege(role_name.rolname, full_table_name, 'REFERENCES')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT REFERENCES ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        if has_table_privilege(role_name.rolname, full_table_name, 'TRIGGER')
        then
        table_grants := format('%s%s%s', table_grants, E'\n', 'GRANT TRIGGER ON TABLE ' || full_table_name || ' TO ' || role_name.rolname || ';');
        end if;

        end loop;
        RETURN format(E'%s',table_grants);
    end;
	$$ language plpgsql;


     select * from find_grants('public', 'beer_app_beer');



--создает нового пользователя и дает роль зарегестрированного
create or replace function add_user() returns trigger as
$$
   begin
    execute FORMAT('CREATE ROLE %I LOGIN PASSWORD ''%I''', lower(new.username), lower(new.username));
    execute format('grant Registered to %I', lower(new.username));
    RETURN new;
   end;
$$ language plpgsql;

create trigger add_grants
after insert on auth_user for each row
execute function add_user();


--тригер при назначении админом джанги кого-то модератором
--дает ему роль модератора

create or replace function add_mod() returns trigger as
$$
    declare
    u_name text;
   begin
    execute 'select lower(username) from auth_user where id = old.user_id' into u_name;
    execute format('grant Moderator to %I', u_name);
    RETURN new;
   end;
$$ language plpgsql;

create trigger add_mod_role
after update of group_id on auth_user_groups 
for each row
execute function add_mod();


-- Посмотреть права роли

select * from information_schema.table_privileges where grantee = 'registered';

-- посмотреть все роли которые есть

select distinct(grantee) from information_schema.table_privileges;

-- -- тригерр при изменении аватарок пользователей для сохранения старых
-- create table image_logs(user_id int, image varchar(100));

-- create or replace function save_old_image() returns trigger as
-- $$
--    begin
--         insert into image_logs(user_id, image) values (old.user_id, old.image);
--       RETURN old;
--    end;
-- $$ language plpgsql;

-- create trigger add_image
-- after update of image on beer_app_profile 
-- for each row
-- execute function save_old_image();

-- -- тригерр для логирования нового добавленного пива
-- CREATE TABLE beer_logs
-- (
--     id int,
--     beer_name varchar(100),
--     style int,
--     abv INTEGER,
--     ibu INTEGER,
--     image varchar(100)
-- );

-- create or replace function new_beer() returns trigger as
-- $$
--    begin
--         insert into beer_logs(id, beer_name, style, abv, ibu, image) values (new.id, new.name, new.style_id_id, new.abv, new.ibu, new.image);
--       RETURN new;
--    end;
-- $$ language plpgsql;

-- create trigger add_beer
-- after INSERT on beer_app_beer
-- for each row
-- execute function new_beer();


create or replace procedure find_producer(product int) as
$$
   begin
    select inn, name from producer where product_id = product;
   end;
$$ language plpgsql;


with prod_c as (
    select id, count(*) as count_product 
    from store
    group by id )
select id, max(count_product)
from prod_c


with sell as (
    select date, sum(quantity * price) as total_price_sell, 
    from selling
    group by date),
with buy as (
    select date, sum(quantity * price) as total_price_buy, 
    from buying
    group by date)
select date, total_price_sell - total_price_buy as income
from sell join buy on sell.date = buy.date
order by date


подсчитать сколько просто тратится денег на зарплаты сотрудников на каждом складе

select storage.id, sum(salary) as total_salary
from storage join employee on storage.employee_id = employee.id
group by storage.id
order by total_salary

