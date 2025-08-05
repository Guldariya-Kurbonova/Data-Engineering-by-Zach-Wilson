INSERT INTO actors_history_scd (actorid, actor, quality_class, is_active, start_date, end_date)
WITH actor_snapshots AS (
    SELECT
        actorid,
        actor,
        quality_class,
        is_active,
        snapshot_year,
        -- LAG: compare to previous snapshot for this actor
        LAG(quality_class) OVER (PARTITION BY actorid ORDER BY snapshot_year) AS prev_quality_class,
        LAG(is_active) OVER (PARTITION BY actorid ORDER BY snapshot_year) AS prev_is_active
    FROM actors
),
change_flags AS (
    SELECT *,
        -- Start new group if quality_class or is_active changes, or it's the first year for actor
        CASE
            WHEN prev_quality_class IS DISTINCT FROM quality_class
              OR prev_is_active IS DISTINCT FROM is_active
              OR prev_quality_class IS NULL
              OR prev_is_active IS NULL
            THEN 1 ELSE 0
        END AS is_new_group
    FROM actor_snapshots
),
grouped_periods AS (
    SELECT *,
        SUM(is_new_group) OVER (PARTITION BY actorid ORDER BY snapshot_year) AS group_num
    FROM change_flags
),
group_agg AS (
    SELECT
        actorid,
        MIN(actor) AS actor,
        quality_class,
        is_active,
        MIN(snapshot_year) AS start_year,
        MAX(snapshot_year) AS end_year,
        group_num
    FROM grouped_periods
    GROUP BY actorid, quality_class, is_active, group_num
),
with_dates AS (
    SELECT
        actorid,
        actor,
        quality_class,
        is_active,
        MAKE_DATE(start_year, 1, 1) AS start_date,
        -- For end_date, look at the MIN(start_date) of the next group for this actor
        LEAD(MAKE_DATE(start_year, 1, 1)) OVER (PARTITION BY actorid ORDER BY start_year) AS next_start_date
    FROM group_agg
)
SELECT
    actorid,
    actor,
    quality_class,
    is_active,
    start_date,
    next_start_date AS end_date
FROM with_dates;


