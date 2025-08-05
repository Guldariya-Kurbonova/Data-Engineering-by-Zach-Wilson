ALTER TABLE actors ADD COLUMN snapshot_year INTEGER;
ALTER TABLE actors DROP CONSTRAINT actors_pkey;
ALTER TABLE actors ADD PRIMARY KEY (actorid, snapshot_year);


BEGIN;
INSERT INTO actors (actorid, actor, films, quality_class, is_active, snapshot_year)
SELECT
    af.actorid,
    af.actor,
    ARRAY_AGG(ROW(film, votes, rating, filmid)::film_struct ORDER BY year DESC, film) AS films,
    (
        CASE
            WHEN AVG(CASE WHEN year = yrs.snapshot_year THEN rating END) > 8 THEN 'star'
            WHEN AVG(CASE WHEN year = yrs.snapshot_year THEN rating END) > 7 THEN 'good'
            WHEN AVG(CASE WHEN year = yrs.snapshot_year THEN rating END) > 6 THEN 'average'
            ELSE 'bad'
        END
    )::quality_class_enum AS quality_class,
    BOOL_OR(year = yrs.snapshot_year) AS is_active,
    yrs.snapshot_year
FROM
    (SELECT DISTINCT year AS snapshot_year FROM actor_films) yrs
JOIN
    actor_films af ON af.year <= yrs.snapshot_year
GROUP BY
    af.actorid, af.actor, yrs.snapshot_year;

commit;



