SELECT
    now()::date AS date,
    current_database() AS database_name,
    schemaname::text || '.'::text || relname::text AS tablename,
    n_live_tup,
    n_dead_tup,
    (n_dead_tup * 100 / (n_live_tup + n_dead_tup + 1.00))::decimal(18, 2) AS pct_dead,
    autovacuum_count,
    date_part('day', CURRENT_TIMESTAMP - last_autovacuum) AS days_since_autovacuum,
    autoanalyze_count,
    date_part('day', CURRENT_TIMESTAMP - last_autoanalyze) AS days_since_autoanalyze,
    vacuum_count,
    date_part('day', CURRENT_TIMESTAMP - last_vacuum) AS days_since_vacuum,
    analyze_count,
    date_part('day', CURRENT_TIMESTAMP - last_analyze) AS days_since_analyze
FROM
    pg_catalog.pg_stat_all_tables
WHERE
    schemaname NOT IN ('pg_toast', 'information_schema')
ORDER BY
    n_dead_tup DESC;
