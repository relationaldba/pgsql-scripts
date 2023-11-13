--PostgreSQL flexible server 14.8 / 8CPU 64GB
- Get the LIST OF indexes
    AND their status:
    SELECT
        nsp.nspname AS schemaname,
        cr.relname AS tablename,
        ci.relname AS indexname,
        i.indisunique AS is_unique,
        i.indisprimary AS is_primary,
        i.indisclustered AS is_clustered,
        i.indisvalid AS is_valid,
        i.indisready AS is_ready,
        i.indislive AS is_live
    FROM
        pg_index AS i
        JOIN pg_class AS ci ON i.indexrelid = ci.oid
            AND ci.relkind = 'i'
        JOIN pg_class AS cr ON i.indrelid = cr.oid
            AND cr.relkind = 'r'
        JOIN pg_namespace AS nsp ON cr.relnamespace = nsp.oid
            AND nsp.nspname NOT LIKE 'pg_%';

- Get the common settings
    AND identify IF anything jumps out at you
        SELECT
            now()::date AS date,
            current_database() AS database_name,
            name AS setting_name,
            CASE WHEN coalesce(setting, '') = '-1' THEN
                setting::text
            WHEN coalesce(unit, '') = '8kB' THEN
                ((setting::int) * 8 / 1024)::text || replace(replace(coalesce(unit, ''), '8kB', 'MB'), 'kB', 'MB')
            WHEN coalesce(unit, '') = 'kB' THEN
                ((setting::int) / 1024)::text || replace(replace(coalesce(unit, ''), '8kB', 'MB'), 'kB', 'MB')
            ELSE
                setting::text || coalesce(unit, '')::text
            END AS setting_value,
            setting,
            unit
        FROM
            pg_catalog.pg_settings
        WHERE
            name IN ('autovacuum', 'autovacuum_analyze_scale_factor', 'autovacuum_analyze_threshold', 'autovacuum_max_workers', 'autovacuum_naptime', 'autovacuum_vacuum_cost_delay', 'autovacuum_vacuum_cost_limit', 'autovacuum_vacuum_scale_factor', 'autovacuum_vacuum_threshold', 'autovacuum_work_mem', 'default_statistics_target', 'maintenance_work_mem', 'max_parallel_maintenance_workers', 'track_counts', 'vacuum_cost_delay', 'vacuum_cost_limit', 'checkpoint_completion_target', 'checkpoint_timeout', 'effective_cache_size', 'effective_io_concurrency', 'max_connections', 'max_parallel_workers', 'max_parallel_workers_per_gather', 'max_wal_size', 'max_worker_processes', 'min_wal_size', 'random_page_cost', 'shared_buffers', 'wal_buffers', 'work_mem', 'log_autovacuum_min_duration', 'log_checkpoints', 'log_connections', 'log_disconnections', 'log_hostname', 'log_line_prefix', 'log_lock_waits', 'log_min_duration_statement', 'log_statement', 'log_temp_files', 'logging_collector', 'password_encryption', 'ssl', 'pg_stat_statements.max', 'pg_stat_statements.save', 'pg_stat_statements.track', 'pg_stat_statements.track_utility')
        ORDER BY
            setting_name;

- Get TABLE size FOR ALL Smile CDR TABLES
SELECT
    now()::date AS date,
    current_database() AS database_name,
    schemaname::text || '.'::text || relname::text AS tablename,
    n_live_tup,
    n_dead_tup,
(n_dead_tup * 100 /(n_live_tup + n_dead_tup + 1.00))::decimal(18, 2) AS pct_dead,
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

