drop table if exists workers cascade;
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
values(1, '14-12-2018', 'Saturday', '10:40', 2);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '10:45', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '15:40', 2);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '16:05', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '17:05', 2);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '14-12-2018', 'Saturday', '17:25', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(2, '14-12-2018', 'Saturday', '9:05', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(2, '17-12-2018', 'Saturday', '9:20', 1);
insert into time_track(id_workers, t_date, day, t_time, t_type)
values(1, '17-12-2018', 'Saturday', '9:10', 1);


-- количество сотрудников в возрасте от 18 до 40 выходивших более 3 раз
select count(*) from(
	select id_workers, count(t_type) as tp from(
		select * from time_track join(
				select id from workers
				where date_part('year', age(current_date, birthday)) between 18 and 40)tt on time_track.id_workers = tt.id
		where t_type = 2)temp group by id_workers, t_date)tmp where tp > 3;

