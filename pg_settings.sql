SELECT now()::date AS date,
       current_database() AS database_name,
       name AS setting,
       CASE 
           WHEN coalesce(setting, '') = '-1' THEN setting::text
           WHEN coalesce(unit, '') = '8kB' THEN ((setting::int) * 8 / 1024)::text || replace(replace(coalesce(unit, ''), '8kB', 'MB'), 'kB', 'MB')
           WHEN coalesce(unit, '') = 'kB' THEN ((setting::int) / 1024)::text || replace(replace(coalesce(unit, ''), '8kB', 'MB'), 'kB', 'MB')
           ELSE setting::text || coalesce(unit, '')::text
       END AS formatted_value
       , value, unit, reset_value
FROM pg_catalog.pg_settings
WHERE name IN ('autovacuum',
               'autovacuum_analyze_scale_factor',
               'autovacuum_analyze_threshold',
               'autovacuum_max_workers',
               'autovacuum_naptime',
               'autovacuum_vacuum_cost_delay',
               'autovacuum_vacuum_cost_limit',
               'autovacuum_vacuum_scale_factor',
               'autovacuum_vacuum_threshold',
               'autovacuum_work_mem',
               'default_statistics_target',
               'maintenance_work_mem',
               'max_parallel_maintenance_workers',
               'track_counts',
               'vacuum_cost_delay',
               'vacuum_cost_limit',
               'checkpoint_completion_target',
               'checkpoint_timeout',
               'effective_cache_size',
               'effective_io_concurrency',
               'max_connections',
               'max_parallel_workers',
               'max_parallel_workers_per_gather',
               'max_wal_size',
               'max_worker_processes',
               'min_wal_size',
               'random_page_cost',
               'shared_buffers',
               'wal_buffers',
               'work_mem',
               'log_autovacuum_min_duration',
               'log_checkpoints',
               'log_connections',
               'log_disconnections',
               'log_hostname',
               'log_line_prefix',
               'log_lock_waits',
               'log_min_duration_statement',
               'log_statement',
               'log_temp_files',
               'logging_collector',
               'password_encryption',
               'ssl',
               'pg_stat_statements.max',
	           'pg_stat_statements.save',
	           'pg_stat_statements.track',
	           'pg_stat_statements.track_utility')
ORDER BY setting_name;

