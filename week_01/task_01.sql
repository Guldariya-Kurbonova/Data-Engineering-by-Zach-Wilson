
-- 1. Composite type for the films array
CREATE TYPE film_struct AS (
    film TEXT,
    votes INTEGER,
    rating NUMERIC(3,1),
    filmid TEXT
);

-- 2. Enum for the quality class
CREATE TYPE quality_class_enum AS ENUM ('star', 'good', 'average', 'bad');

-- 3. The actors table
CREATE TABLE actors (
    actorid TEXT PRIMARY KEY,
    actor TEXT NOT NULL,
    films film_struct[] NOT NULL,
    quality_class quality_class_enum NOT NULL,
    is_active BOOLEAN NOT NULL
);
