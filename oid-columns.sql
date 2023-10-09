SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    'SELECT ''' || column_name || '.' || table_name || ''' AS table, ' || column_name || ' AS oid FROM ' || table_schema || '.' || table_name || ' WHERE ' || column_name || ' IS NOT NULL UNION ALL'
FROM
    information_schema.columns
WHERE
    data_type = 'oid'
    AND table_schema = 'public'
    AND table_name NOT LIKE 'pg_%';

SELECT
    co.table_catalog AS database_name,
    co.table_schema || '.' || co.table_name AS table_name,
    co.column_name AS column_name,
    co.data_type AS data_type,
    cl.reltuples::int AS est_rows
FROM
    information_schema.columns AS co
    INNER JOIN pg_class AS cl ON co.table_name = cl.relname
WHERE
    co.data_type = 'oid'
    AND co.table_schema = 'public'
    AND co.table_name NOT LIKE 'pg_%'
ORDER BY
    est_rows DESC;

