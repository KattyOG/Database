--2 вариант
create database RK2;

create table kind_job(
    id int not null PRIMARY KEY,
    name VARCHAR(30),
    labor_costs int,
    need_cars VARCHAR(30)
);

create table performer(
    id int not null PRIMARY KEY,
    fio VARCHAR(30),
    bithday_year int,
    experience int,
    number VARCHAR(20)
);

create table client(
    id int not null PRIMARY KEY,
    fio VARCHAR(30),
    bithday_year int,
    experience int,
    number VARCHAR(20)
);


create table kind_job_and_client(
    kind_job_id int,
    client_id int
);

create table kind_job_and_performer(
    kind_job_id int,
    performer_id int
);

create table client_and_performer(
    client_id int,
    performer_id int
);

insert into performer(id, fio, bithday_year, experience, number)
values  (1, 'Leonelya Messi', 2000, 9, '89875632985'),
        (2, 'Ivan Popov', 1998, 4, '89076543278'),
        (3, 'Cristianu Ronaldo', 2001, 9, '89670564368'),
        (4, 'Nil Brown', 2000, 6, '89658045326'),
        (5, 'Bob Gray', 2008, 5, '89654689599');

insert into kind_job(id, name, labor_costs, need_cars)
values  (1, 'Zemleroystvo', 4000, 'Tachka'),
        (2, 'Footbolerstvo', 10000, 'The ball'),
        (3, 'Offisnoe', 8000, 'Office'),
        (4, 'Data saintistst', 100000, 'Computer'),
        (5, 'Nichegonedelenie', 1000, 'Vkusnyahki');

insert into client(id, fio, bithday_year, experience, number)
values  (1, 'Client Bestovich', 2010, 9, '89765414598'),
        (2, 'Ai Arnoldovich', 2008, 8, '89675489769'),
        (3, 'Pol Polov', 2006, 6, '89765468578'),
        (4, 'Zakaz Zakazevich', 2007, 5, '89651234256'),
        (5, 'Heh Hehov', 2008, 8, '89680985689');


insert into client_and_performer(client_id, performer_id) values
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

insert into kind_job_and_client(kind_job_id, client_id) values
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

insert into kind_job_and_performer(kind_job_id, performer_id) values
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);


-- выводит данные из таблицы performer где bithday_year больше 2000
select * 
from performer
where bithday_year > 2000;

-- выводит выводит данные из таблицы performer вместе с среднем значением по experience (несгруппированые строки)
select id, fio,
avg(experience) over (partition by bithday_year) as avg_experience
from performer;

-- выбирает данные из my_table, где выбирает данные из performer 
где bithday_year больше года из подзапроса 
где, подзапрос выводит максимальный bithday_year 
среди client где client.experience = performer.experience

select * from
(
    select * from performer
    where performer.bithday_year >
    (
        select max(bithday_year)
        from client
        where client.experience = performer.experience
    )
)my_table;



create or replace procedure output_names_procedure(temp text) as
$$
    declare
    temp2 record;
    pos int;
    begin
        for temp2 in select routine_name as name, 
        routine_definition as txt, 
        routine_type 
        from information_schema.routines 
        where routine_type = 'PROCEDURE' and specific_schema='public'
        loop
            pos := position(temp in temp2.txt);
            if pos != 0 then raise info 'name - %', temp2.name;
            end if;
        end loop;
    end;
$$ language plpgsql;


create or replace procedure temp_proc() AS
$$
select * from performer;
$$ language sql;

call output_names_procedure('select');





insert into stand(id, name, field, description)
values  (1, 'River', 'nature', 'air'),
        (2, 'Mount', 'nature', 'air'),
        (3, 'Animals', 'bio', 'cute'),
        (4, 'Birds', 'bio', 'cute'),
        (5, 'Forest', 'nature', 'relax');


insert into visitor(id, fio, address, phone)
values  (1, 'Ivanov Ivan', '', '89875632985'),
        (2, 'Fedor Brown', '', '89076543278'),
        (3, 'Oleg Fedorov', '', '89670564368'),
        (4, 'Bob Mishin', '', '89658045326'),
        (5, 'Vova Will', '', '89654689599');


insert into excursion(id, name, description, open_date, close_date)
values  (1, 'Boston', 'fun', '2020-09-18', '2021-09-18'),
        (2, 'Moskva', 'boring', '2000-02-08', '2002-09-01'),
        (3, 'Red Square', 'beautiful', '2010-12-31', '2015-11-03'),
        (4, 'Voronezh', 'fun', '2020-01-16', '2023-05-13'),
        (5, 'Tver', 'bad', '2020-09-18', '2026-05-11');


insert into stand_ex(id, stand_id, ex_id)
values      (1, 1, 1),
            (2, 2, 2),
            (3, 3, 3),
            (4, 4, 4),
            (5, 5, 5);


insert into stand_ex(id, ex_id, vis_id)
values      (1, 1, 1),
            (2, 2, 2),
            (3, 3, 3),
            (4, 4, 4),
            (5, 5, 5);



-- опеределяет вид по определенной породе
select animal_name,
    case race
        when 'ovcharka' then 'dog'
        when 'blue' then 'cat' 
        else 'unknown'
    end as temp
from animal;
    

-- выводит выводит adress, fio из таблицы host вместе с среднем значением по номеру телефона сгруппированых по адресу, но сами строки не слипляются в одну 
select adress, fio,
avg(tel_number) over (partition by adress) as avg_tel_number
from host;


-- выводит выводит adress из таблицы host вместе с среднем значением по номеру телефона большим 2500 сгруппированых по адресу
select adress, avg(tel_number) as "tel_number avg"
from host
GROUP BY adress
having avg(tel_number) > 2500;


create table ex_v(
id int,
ex_id int,
vis_id int,
foreign key(vis_id) references visitor(id),
foreign key(ex_id) references excursion(id)
);

create table host_animal(
id int,
host_id int,
animal_id int, 
foreign key(animal_id) references animal(id),
foreign key(host_id) references host(id)
);