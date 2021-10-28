alter table recipes
add foreign key ("style id") REFERENCES styles(id);

alter table "beer-brewery"
add constraint fk foreign key (brewery_id) references breweries(id);

alter table "beer-brewery"
add constraint fk2 foreign key (beer_id) references beers(id);

alter table beers
add foreign key ("style id") REFERENCES styles(id);

ALTER TABLE beers 
ADD CONSTRAINT above_zero 
CHECK (
	abv >= 0
);

INSERT INTO beers(id, name, "style id", abv, ibu)
VALUES (9000, 'Winter Warmer' , 42, 10, 80);