DO $$
DECLARE rel varchar(500);
BEGIN
    DROP TABLE IF EXISTS temp_pgstattuple;
    CREATE TABLE IF NOT EXISTS temp_pgstattuple AS
    SELECT current_database()::varchar(50) AS database_name, 'pg_catalog.pg_proc'::varchar(500) AS table_name, *
    FROM pgstattuple ('pg_catalog.pg_proc');
    DELETE FROM temp_pgstattuple;

    FOR rel IN
    SELECT '"' || pn.nspname || '"."' || pc.relname || '"' AS relname
    FROM pg_catalog.pg_class pc
    INNER JOIN pg_catalog.pg_namespace pn ON pc.relnamespace = pn.oid
        AND pn.nspname NOT IN ('pg_toast', 'information_schema')
        AND pc.relkind = 'r'
        AND pc.relpersistence = 'p'
        LIMIT 3
        LOOP
            INSERT INTO temp_pgstattuple
            SELECT
                current_database(),
                rel,
                *
            FROM
                pgstattuple (rel);
        END LOOP;
END $$;


SELECT now()::date AS date, database_name, pg_size_pretty(SUM(free_space)) AS total_table_bloat
FROM temp_pgstattuple
GROUP BY database_name;

SELECT
    now()::date AS date,
    database_name,
    replace(table_name, '"', '') AS table_name,
    table_len AS table_size_bytes,
    pg_size_pretty(table_len) AS table_size,
    tuple_count,
    tuple_len AS tuple_size_bytes,
    pg_size_pretty(tuple_len) AS tuple_size,
    tuple_percent,
    dead_tuple_count,
    dead_tuple_len AS dead_tuple_size_bytes,
    pg_size_pretty(dead_tuple_len) AS dead_tuple_size,
    dead_tuple_percent,
    free_space,
    free_percent
FROM
    temp_pgstattuple
ORDER BY
    table_name;
