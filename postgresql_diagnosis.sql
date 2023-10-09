-----------------------------------------------------------
-- 01 Review database size
SELECT
    now()::date AS date,
    datname AS database_name,
    pg_size_pretty(pg_database_size(pg_database.datname)) AS database_size
FROM
    pg_catalog.pg_database
WHERE
    datdba > 10;

-----------------------------------------------------------
-- 02 Review Size of tables
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

-----------------------------------------------------------
-- 03 Review important PostgreSQL settings

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
    name IN ('autovacuum_analyze_scale_factor', 'autovacuum_analyze_threshold', 'autovacuum_max_workers', 'autovacuum_naptime', 'autovacuum_vacuum_cost_delay', 'autovacuum_vacuum_cost_limit', 'autovacuum_vacuum_scale_factor', 'autovacuum_vacuum_threshold', 'autovacuum_work_mem', 'checkpoint_completion_target', 'checkpoint_timeout', 'default_statistics_target', 'effective_cache_size', 'effective_io_concurrency', 'log_autovacuum_min_duration', 'log_connections', 'log_hostname', 'log_line_prefix', 'log_lock_waits', 'log_min_duration_statement', 'log_statement', 'logging_collector', 'maintenance_work_mem', 'max_connections', 'max_parallel_maintenance_workers', 'max_parallel_workers', 'max_parallel_workers_per_gather', 'max_wal_size', 'max_worker_processes', 'min_wal_size', 'password_encryption', 'random_page_cost', 'shared_buffers', 'ssl', 'track_io_timing ', 'vacuum_cost_delay', 'vacuum_cost_limit', 'wal_buffers', 'work_mem')
ORDER BY setting_name;

-----------------------------------------------------------
-- 04 Dead tuples and autovacuum count
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
    date_part('day', CURRENT_TIMESTAMP - last_autoanalyze) AS days_since_autoanalyze
FROM
    pg_catalog.pg_stat_all_tables
WHERE
    schemaname NOT IN ('pg_toast', 'information_schema')
ORDER BY
    n_dead_tup DESC;

-----------------------------------------------------------
-- 05.A Most scanned tables
SELECT relname, seq_scan, seq_tup_read
FROM pg_catalog.pg_stat_user_tables
ORDER BY seq_scan DESC
LIMIT 50;

-- 05.B Most Scanned indexes
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_catalog.pg_stat_user_indexes
ORDER BY idx_scan DESC
LIMIT 50;

-----------------------------------------------------------
-- 06 Statement statistics
SELECT dat.datname AS database,
    rol.rolname AS user,
    pss.query,
    to_char(calls, 'fm999G999G999G999G999') AS exec_count,
    rows,
    round(mean_time::numeric, 2) AS avg_time_ms,
    round(total_time::numeric, 2) AS total_time_ms,
    round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS pct_cpu,
    shared_blks_hit,
    shared_blks_read,
    shared_blks_dirtied,
    shared_blks_written
    blk_read_time,
    blk_write_time
FROM pg_stat_statements AS pss 
    JOIN pg_catalog.pg_roles AS rol ON pss.userid = rol.oid
    JOIN pg_catalog.pg_database AS dat ON pss.dbid = dat.oid
WHERE 1 = 1
AND dat.datname NOT IN ('postgres', 'template0', 'template1', 'azure_sys', 'azure_maintenance')
AND rol.rolname NOT IN ('azure_superuser', 'azure_backup', 'azure_replication_user')
-- ORDER BY pct_cpu DESC;
ORDER BY blk_read_time DESC;
-- ORDER BY calls DESC;
-- ORDER BY avg_time_ms DESC;
-- ORDER BY shared_blks_read DESC;
-- ORDER BY rows DESC;

-----------------------------------------------------------
-- 07 Monitor queries
select pid,
       usename,
       pg_blocking_pids(pid) as blocked_by,
       age(clock_timestamp(), query_start) AS query_age,
       age(clock_timestamp(), backend_start) AS backend_age,
       query,
       datname,
       application_name,
       client_addr,
       wait_event_type,
       wait_event,
       state
from pg_stat_activity
where 1 = 1
AND state <> 'idle'
--and cardinality(pg_blocking_pids(pid)) > 0  /*uncomment to see blocked queries*/
--and pid IN ()
order by backend_age asc;

-----------------------------------------------------------