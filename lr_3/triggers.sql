--  trigger after

drop table if exists new_table;

select id, abv
into new_table
from beers
limit 20;

create or replace function insert_func() returns trigger as
$$
   begin
      insert into new_table(id, abv) values (23, old.abv);
      RETURN new;
   end;
$$ language plpgsql;

create trigger instead_update_insert
after update on new_table for each row
execute function insert_func();

select * from new_table;
update new_table
set abv = 9
where id = 22;

select * from new_table;
order by id;


--  trigger instead of

drop view if exists new_view;
drop table if exists ff;

create table ff(id int, num int);
INSERT into ff(id, num) values (1, 2);
INSERT into ff(id, num) values (2, 3);
INSERT into ff(id, num) values (3, 4);

create view new_view as
select *
from ff;

create or replace function insert_instead_update() returns trigger as
$$
    begin
        insert into new_view(id, num) values (old.id * 4, new.num);
        RETURN new;
    end;
$$ language plpgsql;

create trigger update_trigger
instead of update on new_view for each row 
execute function insert_instead_update();

select * from new_view;
update new_view
set num = 9
where id = 1;

select * from new_view;


-- bad

-- drop view if exists new_view;

-- create view new_view as
-- select *
-- from beers
-- order by id
-- limit 10;

-- create or replace function update_instead_del() returns trigger as
-- $$
    -- begin
    --     update new_view
    --     set abv = 8
    --     where id = old.id;
    --     return new;
    -- end;
-- $$ language plpgsql;

-- create or replace function update_func() returns trigger as
-- $$
    -- begin
    -- 	return old;
    -- end;
-- $$ language plpgsql;

-- create trigger update_trigger
-- instead of delete on new_view for each row 
-- execute function update_instead_del();

-- create trigger update_trigger
-- instead of update on new_view for each row 
-- execute function update_func();

-- delete
-- from new_view
-- where id = 1;

-- select *
-- from new_view;