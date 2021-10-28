CREATE TABLE shops
(
    id serial NOT NULL PRIMARY KEY,
    name character varying(50),
    latitude real,
    longitude real,
    "owner's name" character varying(50)
);

CREATE TABLE styles
(
    id serial NOT NULL PRIMARY KEY,
    style character varying(50) NOT NULL
);

CREATE TABLE breweries
(
    id serial NOT NULL PRIMARY KEY,
    name character varying(100),
    address character varying(100),
    city character varying(50),
    state character varying(50),
    code character varying(20),
    country character varying(50),
    phone character varying(20),
    website character varying(100)
);

CREATE TABLE recipes
(
    id serial NOT NULL PRIMARY KEY,
    name character varying(100),
    "style id" serial NOT NULL,
    size real,
    og real,
    fg real,
    color real,
    "boil size" real,
    "boil time" INTEGER,
    "boil gravity" character varying(10),
    efficiency real,
    "brew method" character varying(20)
);

CREATE TABLE beers
(
    id serial NOT NULL PRIMARY KEY,
    name character varying(100),
    "style id" serial NOT NULL,
    abv INTEGER,
    ibu INTEGER
);

CREATE TABLE "beer-brewery"
(
    id serial NOT NULL PRIMARY KEY,
    beer_id serial NOT NULL,
    brewery_id serial NOT NULL
);


COPY shops FROM 'C:/Users/mir80/Desktop/shops.csv' WITH (FORMAT csv);
COPY styles FROM 'C:/Users/mir80/Desktop/styles.csv' WITH (FORMAT csv);
COPY breweries FROM 'C:/Users/mir80/Desktop/breweries.csv' WITH (FORMAT csv);
COPY recipes FROM 'C:/Users/mir80/Desktop/recipes.csv' WITH (FORMAT csv);
COPY beers FROM 'C:/Users/mir80/Desktop/beers.csv' WITH (FORMAT csv);
COPY "beer-brewery" FROM 'C:/Users/mir80/Desktop/beer-brewery.csv' WITH (FORMAT csv);
