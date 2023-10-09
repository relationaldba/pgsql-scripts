SELECT
    *
FROM
    pg_class
WHERE
    relkind = 'r'
    AND relispartition = FALSE
    AND relnamespace IN (
        SELECT
            oid
        FROM
            pg_namespace
        WHERE
            nspname NOT IN ('pg_toast', 'pg_catalog', 'information_schema'))
ORDER BY
    1;

