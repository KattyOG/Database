-- first task

drop table if exists workers;
create table workers (
	id int not null primary key,
	fio varchar,
	birthday date,
	department varchar
);
insert into workers(id, fio, birthday, department)
values (1, 'Ivanov Ivan Ivanovich', '25-09-1990', 'IT');
insert into workers(id, fio, birthday, department)
values (2, 'Petrov Petr Petrovich', '12-11-1987', 'Accounting department');

drop table if exists time_track;
create table time_track(
	id_workers int references workers(id) not null,
	t_date date,
	day varchar,
	t_time time,
	t_type int
);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '9:00', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '9:20', 2);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '9:25', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(2, '14-12-2018', 'Saturday', '9:05', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(2, '17-12-2018', 'Saturday', '9:20', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '17-12-2018', 'Saturday', '9:10', 1);

-- Написать функцию, возвращающую количество опоздавших сотрудников. Дата опоздания в качестве параметра.
create or replace function late_in_date(с_date date) returns table(count int) as $$
    select count(*) 
    from(
        select id
        from workers join time_track on workers.id = time_track.id_workers
        where time_track.t_date = с_date and t_type = 1
        group by id
        having min(time_track.t_time) > '9:00'
    ) as count;
$$ language sql;

--count 1
select * from late_in_date('14-12-2018');
-- count 2
select * from late_in_date('17-12-2018'); 


-- отделы в которых нет сотрудников моложе 25
with res as (
    select id, fio, date_part('year', age(current_date, birthday)) as age, department
    from workers
)
select department
from workers
where department not in (select department
from res where age < 25);


-- раньше всех сегодня
with res as(
    select id_workers from time_track
    where t_date = current_date and t_type = 1
)
select id_workers, t_time
from time_track
where t_time = (select min(t_time) from time_track);


with res as(
select min(t_time) from (
    select * from time_track
    where t_date = current_date and t_type = 1
)ff
)
select id_workers, t_time
from time_track
where t_time = (select * from res);

-- опоздали больше 5 раз
select id from 
(       
    select id, count(id) from 
        (
            select id, t_time
            from workers join time_track on workers.id = time_track.id_workers
            where t_type = 1
            group by id, t_time
            having min(time_track.t_time) > '9:00'
        ) as t 
        group by id
) as t2
where count >= 5;


select first_visit.id_workers, count(*)
from
(
    select distinct time_track.id_workers,
             min(time_track.t_time) over (partition by time_track.id_workers, time_track.t_date) as min_time,
             time_track.t_date
    from time_track
) as first_visit
where first_visit.min_time > '9:00'
group by first_visit.id_workers
having count(*) >= 2;

select first_visit.id_employee, count()
from
(
    select distinct record.id_employee,
             min(record.rtime) over (partition by record.id_employee, record.rdate) as min_time,
             record.rdate
    from record
) as first_visit
where first_visit.min_time > '9:00'
group by first_visit.id_employee
having count() >= 5;






-- second task
select *, date_part('week', t_date::date) from time_track;


with res as (
select id_workers, date_part('week', min(t_date::date)::date)
    from (
        select * from time_track where t_type = 1 and t_time > '9:00'
    )f group by (id_workers, t_date)
)
select e.time_track from (
    select * from (
        select id_workers, date_part, count(*) as cnt 
        from res group by (id_workers, date_part)
    )ff where cnt > 3
)res join workers e on res.id_workers = e.id;

select count(*)
from(
    select id
    from workers join time_track on workers.id = time_track.id_workers
    where t_type = 1
    group by id,t_time
    having t_time > '9:00'
) as count;

-- Возвращает id опоздавших сегодня сотрудников из IT
create or replace function lateIT() returns table
(
	id int
)
as
$$
	select distinct id
	from workers join time_track on workers.id = time_track.id_workers
	where time_track = 'ИТ' and time_track.t_date = current_date
	group by id
	having min(time_track.t_time) > '9:00'; 
$$ language sql;
-- Возвращает возраст человека по дате рождения на сегодня 
create or replace function getage(bd_ date) returns double precision as
$$
	select extract (year from current_date) - extract (year from bd_) 
$$ language sql;

-- Возваращает средний возраст опоздавших сегодня сотрудников из IT
drop function if exists avgagelate();
create or replace function avgagelate() returns double precision as
$$
	select avg(getage(birthday))
	from lateIT() as l join workers on l.id = workers.id;
$$ language sql;

select avgagelate();