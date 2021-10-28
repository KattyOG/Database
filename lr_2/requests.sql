--compare
select *
from beers
where abv = 2
limit 10

-- between
select *
from beers
where abv BETWEEN 2 and 7
limit 10

--like
select *
from beers
where name like '%Ale%'
limit 10


--in
select *
from beers
where beers."style id" in
	(
		select id
		from styles
		where style like '%Stout%'
	)
limit 10


--exists
select name, ibu, abv
from beers as b
where exists
	(
		select *
		from beers
		where ibu = 20 and abv = 6 and name = b.name
	)
limit 10


--kvant 
-- "style id" = 51, abv = 1
select *
from beers
where abv < all
(
	select abv
	from beers
	where "style id" = 51
)
limit 10

--aggregate
select *
from(
	select "style id", avg(abv) as avg_abv
    from beers
    GROUP BY "style id"
)as beer 
limit 10


-- scalar
select name, abv,
(
    select avg("boil time")
    from recipes 
    where recipes."style id" = beers."style id"
) as avg_time
from beers
where abv = 0
limit 10


-- simple case
select name, 
	case "style id"
		when 116 then 'Old Ale'
		when 76 then 'Fruit Cider'
		when 13 then 'American Strong Ale'
		else 'Unknown'
	end as ibu_scale
from beers
limit 10


-- find case
select name, 
	case
		when ibu < 25 then 'not bitter'
		when ibu > 25 and ibu < 55 then 'medium bitterness'
		when ibu > 55 then 'bitter'
		else 'Unknown'
	end as ibu_scale
from beers
limit 10


-- temp table
select name, abv
into not_null_abv
from beers
where abv > 0 
limit 10

select *
from not_null_abv

drop table not_null_abv;


-- korrel
SELECT id, "style id", ibu
from beers as b_outer
where ibu >
(
    SELECT avg(ibu)
    from beers as b_inner
    WHERE b_inner."style id" = b_outer."style id"
)
limit 10


-- nesting level three
select *
from beers
where ibu =
(
	select min(ibu)
	from beers
	where "style id" =
	(
		select max("style id")
		from beers
		where abv =
		(
			select abv
			from beers
			where name = 'Winter Warmer'
		)
	)
)
limit 10

-- group without having
select name, avg(abv) as "abv avg", avg(ibu) as "ibu avg"
from beers
where "style id" = 42
group by name
limit 10


-- group with having
select name, avg(abv) as "abv avg"
from beers
GROUP BY name
having avg(abv) >
(
    SELECT avg(abv) as avg_abv
    FROM beers
)
limit 10


-- insert one row
INSERT into beers(id, name, "style id", abv, ibu)
VALUES(5915, 'Corona Extra' , 28, 6, 80);


-- insert result set
insert into beers(id, name, "style id", abv, ibu)
select MAX(breweries.id) * 5, 'Pink rabbit', 42, 4, 31
from breweries
where breweries.state = 'Ontario'


-- simple update
update beers
set id = 5917
where name = 'Pink rabbit'


-- scalar update
update beers
set abv = 
(
	select avg(abv)
	from beers
	where ibu < 60
)
where name = 'Pink rabbit'


-- simple delete
delete from beers
where name = 'Pink rabbit'


-- big delete 
delete from beers
where id in
(
    select MAX(breweries.id) * 5
    from breweries
    where breweries.state = 'Ontario'
)

-- cte
with cte as
(
	select abv, count(*) as abv_of_each_num
	from beers
	group by abv
	limit 10
)
select abv, abv_of_each_num from cte


-- recursion

with recursive rec_table as
(
	select id as index, style as style_name from styles where id = 1
	union 
	select styles.id as index, styles.style as style_name
	from rec_table join styles on rec_table.index + 1 = styles.id
	where styles.id <= 10
)
select * from rec_table;

-- window
select id, name, "style id", ibu,
max(ibu) over (partition by "style id") as max_ibu,
min(ibu) over (partition by "style id") as min_ibu
from beers
limit 40

-- row_num
DROP TABLE students;

CREATE TABLE students
(
	id int,
    name character varying(100),
    surname character varying(100)
);

INSERT INTO students 
VALUES (1, 'bob', 'brown');
INSERT INTO students 
VALUES (2, 'bob', 'brown');
INSERT INTO students 
VALUES (3, 'alan', 'jones');
INSERT INTO students 
VALUES (4, 'alan', 'jones');

SELECT name, surname
from students;

DELETE
FROM students
where id in (
	select id from(
		SELECT *, ROW_NUMBER() OVER(PARTITION BY name) AS num
		FROM students
	) AS std
	WHERE std.num = 2 and std.id not in (
	select id from students where num = 1
	)
)
;

SELECT name, surname
from students;



-- -- versioning tables
DROP TABLE first;
DROP TABLE second;

CREATE TABLE first(
	id INTEGER,
	var1 CHAR,
	from_dttm DATE,
	to_dttm DATE
);

CREATE TABLE second(
	id INTEGER,
	var2 CHAR,
	from_dttm DATE,
	to_dttm DATE
);

INSERT INTO first (id, var1, from_dttm, to_dttm) VALUES(1, 'A', '2018-09-01', '2018-09-15');
INSERT INTO first (id, var1, from_dttm, to_dttm) VALUES(1, 'B', '2018-09-16', '5999-12-31');
INSERT INTO second (id, var2, from_dttm, to_dttm) VALUES(1, 'A', '2018-09-01', '2018-09-14');
INSERT INTO second (id, var2, from_dttm, to_dttm) VALUES(1, 'B', '2018-09-15', '5999-12-31');

select * from 
(
    select first.id as id, first.var1 as var1, second.var2 as var2,
        case when first.from_dttm > second.from_dttm then first.from_dttm
            else second.from_dttm 
        end as from_dttm,
        case when first.to_dttm < second.to_dttm then first.to_dttm
            else second.to_dttm
        end as to_dttm
    from first left join second on first.id = second.id
) as res
where to_dttm >= from_dttm