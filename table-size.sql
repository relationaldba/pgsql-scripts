--Table Size and Row counts of all tables except pg_toast and information_schema
SELECT
    now()::date AS date,
    current_database() AS database_name,
    pn.nspname || '.' || pc.relname AS table_name,
    (pg_total_relation_size('"' || pn.nspname || '"."' || pc.relname || '"') / 1024.0 / 1024.0)::decimal(18, 2) AS size_mb,
    reltuples::bigint AS row_count
FROM
    pg_catalog.pg_class pc
    INNER JOIN pg_catalog.pg_namespace pn ON pc.relnamespace = pn.oid
        AND pn.nspname NOT IN ('pg_toast', 'information_schema')
        AND pc.relkind = 'r'
ORDER BY
        row_count DESC;


--Relation size vs Total relation size
SELECT '"'||schemaname||'"."'||tablename||'"' AS tablename,
       pg_size_pretty(pg_relation_size('"'||schemaname||'"."'||tablename||'"')) AS rowsize,
       pg_size_pretty(pg_total_relation_size('"'||schemaname||'"."'||tablename||'"')) AS tablesize_total
FROM pg_tables
ORDER BY pg_total_relation_size('"'||schemaname||'"."'||tablename||'"') DESC;

