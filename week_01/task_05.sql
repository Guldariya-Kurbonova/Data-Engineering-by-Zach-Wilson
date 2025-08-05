-- Step 1: "Close out" changed rows

UPDATE actors_history_scd scd
SET end_date = TO_DATE(a.snapshot_year || '-01-01', 'YYYY-MM-DD')
FROM actors a
WHERE scd.actorid = a.actorid
  AND a.snapshot_year = (SELECT MAX(snapshot_year) FROM actors)
  AND scd.end_date IS NULL
  AND (
        scd.quality_class IS DISTINCT FROM a.quality_class
        OR scd.is_active IS DISTINCT FROM a.is_active
      );



--Step 2: Insert new rows for changed actors
INSERT INTO actors_history_scd (actorid, actor, quality_class, is_active, start_date, end_date)
SELECT
    a.actorid,
    a.actor,
    a.quality_class,
    a.is_active,
    TO_DATE(a.snapshot_year || '-01-01', 'YYYY-MM-DD') AS start_date,
    NULL AS end_date
FROM actors a
LEFT JOIN actors_history_scd scd
  ON a.actorid = scd.actorid
  AND scd.end_date IS NULL
WHERE a.snapshot_year = (SELECT MAX(snapshot_year) FROM actors)
  AND (
        scd.actorid IS NULL
        OR scd.quality_class IS DISTINCT FROM a.quality_class
        OR scd.is_active IS DISTINCT FROM a.is_active
      );






-- 1. Close out changed rows
UPDATE actors_history_scd scd
SET end_date = TO_DATE(a.snapshot_year || '-01-01', 'YYYY-MM-DD')
FROM actors a
WHERE scd.actorid = a.actorid
  AND a.snapshot_year = (SELECT MAX(snapshot_year) FROM actors)
  AND scd.end_date IS NULL
  AND (scd.quality_class IS DISTINCT FROM a.quality_class
       OR scd.is_active IS DISTINCT FROM a.is_active);

-- 2. Insert new rows for changed/new actors
INSERT INTO actors_history_scd (actorid, actor, quality_class, is_active, start_date, end_date)
SELECT
    a.actorid,
    a.actor,
    a.quality_class,
    a.is_active,
    DATE a.snapshot_year || '-01-01' AS start_date,
    NULL AS end_date
FROM actors a
LEFT JOIN actors_history_scd scd
  ON a.actorid = scd.actorid
  AND scd.end_date IS NULL
WHERE a.snapshot_year = (SELECT MAX(snapshot_year) FROM actors)
  AND (
        scd.actorid IS NULL
        OR scd.quality_class IS DISTINCT FROM a.quality_class
        OR scd.is_active IS DISTINCT FROM a.is_active
      );







