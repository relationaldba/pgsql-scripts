SELECT
    now()::date AS date,
    current_database() AS database_name,
    name AS setting_name,
    CASE coalesce(unit, '')
    WHEN '8kB' THEN
        ((setting::int) * 8 / 1024)::text
    WHEN 'kB' THEN
        ((setting::int) / 1024)::text
    ELSE
        setting::text
    END || replace(replace(coalesce(unit, ''), '8kB', 'MB'), 'kB', 'MB') AS setting_value
FROM
    pg_catalog.pg_settings
WHERE
    name IN ('autovacuum_analyze_scale_factor', 'autovacuum_analyze_threshold', 'autovacuum_max_workers', 'autovacuum_naptime', 'autovacuum_vacuum_cost_delay', 'autovacuum_vacuum_cost_limit', 'autovacuum_vacuum_scale_factor', 'autovacuum_vacuum_threshold', 'autovacuum_work_mem', 'checkpoint_completion_target', 'checkpoint_timeout', 'default_statistics_target', 'effective_cache_size', 'effective_io_concurrency', 'log_autovacuum_min_duration', 'log_connections', 'log_hostname', 'log_line_prefix', 'log_lock_waits', 'log_min_duration_statement', 'log_statement', 'logging_collector', 'maintenance_work_mem', 'max_connections', 'max_parallel_maintenance_workers', 'max_parallel_workers', 'max_parallel_workers_per_gather', 'max_wal_size', 'max_worker_processes', 'min_wal_size', 'password_encryption', 'random_page_cost', 'shared_buffers', 'ssl', 'vacuum_cost_delay', 'vacuum_cost_limit', 'wal_buffers', 'work_mem')
ORDER BY setting_name;
