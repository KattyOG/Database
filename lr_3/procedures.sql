-- stored procedure without parameters

drop table if exists new_table;

select id, name, abv, ibu
into new_table
from beers
where abv > 6
limit 20;

create or replace procedure new_ibu() as
$$
	update new_table
	set ibu = 2
	where name like '%Ale%'
$$ language sql;

call new_ibu();

select *
from new_table;


-- recursive stored procedure

drop table if exists new_table;

select id, name, abv, ibu
into new_table
from beers
limit 20;

create or replace procedure new_ibu_between_id(begin_id int, end_id int, new_ibu int) as
$$
begin
    if (begin_id <= end_id)
    then
        update new_table
        set ibu = new_ibu
        where id = begin_id;
        call new_ibu_between_id(begin_id + 1, end_id, new_ibu);
    end if;
end;
$$ language plpgsql;

call new_ibu_between_id(3, 6, 6);

select *
from new_table
order by id;


-- stored procedure with cursor

drop table if exists new_table;

select *
into new_table
from beers
limit 20;

create or replace procedure abv_delete_str(temp_abv int) as
$$
    declare my_cursor cursor 
    for select * 
    from new_table;
    temp record;
    begin
        open my_cursor;
        loop
            fetch my_cursor into temp;
            exit when not found;
            delete from new_table
            where abv = temp_abv;
        end loop;
        close my_cursor;
    end;
$$ language plpgsql;

call abv_delete_str(2);

select *
from new_table
order by id;


-- stored procedure for accessing metadata

drop table if exists data_table;

CREATE TABLE data_table
(
    name character varying(100),
    size int
);

create or replace procedure table_info() as
$$
    insert into data_table(name, size) select table_name, size from
    (select table_name,
    pg_relation_size(cast(table_name as varchar)) as size 
    from information_schema.tables
    WHERE table_schema='public') as tmp
$$ language sql;

call table_info();

select * from data_table;