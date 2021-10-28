CREATE DATABASE university;

create table prepods(
    id int not null PRIMARY KEY,
    fio VARCHAR(30),
    power int,
    teacher_position VARCHAR(30),
    kafedra VARCHAR(30)
);

create table kafedra(
    id int not null PRIMARY KEY,
    name_k VARCHAR(30),
    description VARCHAR(30)
);

create table subject(
    id int not null PRIMARY KEY,
    name_sub VARCHAR(30),
    clock int check clock > 0,
    semester int,
    rating int
);

create table prepods_subjects(
    prepods_id int,
    subject_id int
);


alter table prepods
add foreign key (kafedra) REFERENCES kafedra(id);



ALTER TABLE prepods ALTER COLUMN kafedra TYPE int USING kafedra::integer;

insert into kafedra(id, name_k, description)
values 
(1, 'green', 'good day'), 
(2, 'blue', 'bad day'), 
(3, 'red', 'er'), 
(4, 'black', 'perfect'), 
(6, 'white', 'small');



insert into prepods(id, fio, power, teacher_position, kafedra)
values
(1, 'bob dilan ivaniv', 5, 'doctor', 3),
(2, 'fred brown kek', 1, 'mag', 2),
(3, 'max kryat', 2, 'genious', 1),
(4, 'dima antsiborius', 10, 'doctor', 4),
(5, 'dina bloh', 4, 'anime doctor', 6);

insert into subject(id, name_sub, clock, semester, rating)
values 
(1, 'math', 75, 5, 66),
(2, 'rus', 102, 2, 12),
(3, 'angl', 15, 3, 98),
(4, 'promgam', 93, 1, 1);


insert into prepods_subjects(prepods_id, subject_id)
values (1, 1), (2, 4), (3, 2), (4, 4), (5, 5);

insert into subject(id, name_sub, clock, semester, rating)
values 
(5, 'texnologi', 51, 1, 121);


select *
from prepods
where kafedra < ALL
(
    SELECT kafedra
    from prepods
    where teacher_position = 'doctor'
);

-- sum(kafedra)
-- avg(kafedra)
-- min(kafedra)
-- max(kafedra)
-- count(*)

select avg(avg_rat)
from(
    select name_sub, avg(rating) as avg_rat
    from subject
    group by name_sub
) dd;

select id, name_sub into temp_table2 from subject;

select name_sub,
    case 
        when semester < 3 then 'small'
        when semester = 5 then 'old' 
        else 'hh'
    end as aa
from subject;
    
select * into temp_prepods from prepods;
select * from prepods;

select * into temp_prepodsss from 
(
    select id, fio
    from prepods
)temp;
update temp_prepods
set power = 
(select avg(power)
from prepods);


insert into temp_prepods(id, fio, power, teacher_position, kafedra)
values
(4, 'dima antsiborius', 4, 'doctor', 4),
(5, 'dina bloh', 4, 'anime doctor', 6),
(6, 'dima antsiborius', 4, 'doctor', 4),
(7, 'dina bloh', 4, 'anime doctor', 6);


create or replace procedure my_proc(name VARCHAR) AS
$$
declare 
elem record;
elem2 record;
temp int;
temp2 int[];
BEGIN
for elem in EXECUTE format('select * from %I', name)
    loop
    if elem.id = any(temp2)
    then CONTINUE;
    end if;
    for elem2 in execute format('select * from %I where id <> %s', name, elem.id)
            loop
                temp = elem2.id;
                elem2.id = elem.id;
                if elem = elem2
                then execute format('delete from %I where id = %s', name, temp);
                temp2 := ARRAY_append(temp2, temp);
                end if;
            end loop;
    end loop;
end;
$$ LANGUAGE plpgsql;

call my_proc('temp_prepods');

-- получить текст процедуры
SELECT pg_get_functiondef(p.oid), p.prosrc
FROM pg_proc p
WHERE proname='my_proc'

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='temp_prepods' AND
	COLUMN_NAME NOT IN ('id')


select proname,prosrc from pg_proc where prosrc like '%search text%';


CREATE INDEX title_idx ON temp_prepods(fio);

SELECT * FROM pg_indexes WHERE tablename = 'temp_prepods';


select * from pg_proc;


create or replace function ufn_inserted_table_func() returns temp_prepods as
$$
	select *
	from temp_prepods
$$ language sql;










create or replace procedure find_func(inout amount int = 0) as $$
    declare
    elem record;
    cmd text := $cmd$ SELECT routine_name AS name, routine_definition
        FROM information_schema.routines
        WHERE routine_type = 'FUNCTION' AND specific_schema = 'public' $cmd$;
    -- cmd text := $cmd$ SELECT routine_name as name FROM information_schema.routines
    -- WHERE routine_type='FUNCTION' AND specific_schema='public'$cmd$;
    index_ int;
    begin
    amount = 0;
    for elem in execute cmd
        loop
        index_ := position('ufn' in elem.name);
        -- raise notice '% %', elem.name, index_;
            if index_ = 1 then amount := amount + 1;
            end if;
        end loop;
    end;
$$ language plpgsql; 


call find_func();








-- CREATE TABLE IF NOT EXISTS department
-- (
-- 	id SERIAL NOT NULL PRIMARY KEY,
-- 	description CHARACTER VARYING(64) NOT NULL,
-- 	phone CHARACTER VARYING(11) NOT NULL,
-- 	id_manager int not null
-- );
 
-- CREATE TABLE IF NOT EXISTS employee
-- (
-- 	id SERIAL NOT NULL PRIMARY KEY,
-- 	post CHARACTER VARYING(64) NOT NULL,
-- 	person_name CHARACTER VARYING(64) NOT NULL,
-- 	id_department int not null,
-- 	wages int not null
-- );
-- ALTER TABLE employee ADD CONSTRAINT fk_id_department
--                   FOREIGN KEY (id_department) 
--                   REFERENCES department(id);
 
-- ALTER TABLE department ADD CONSTRAINT fk_id_manager
--                   FOREIGN KEY (id_manager) 
--                   REFERENCES employee(id);


create or replace procedure copy_csv() as
$$
BEGIN
    COPY (SELECT * FROM prepods) TO 'C:\database\1.csv' CSV;
end;
$$ language plpgsql; 

call copy_csv();



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