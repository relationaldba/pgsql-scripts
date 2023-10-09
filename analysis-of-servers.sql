--Database Settings
SELECT
    name,
    CASE COALESCE(unit, '')
    WHEN '8kB' THEN
        ((setting::int) * 8 / 1024)::text
    WHEN 'kB' THEN
        ((setting::int) / 1024)::text
    ELSE
        setting::text
    END || REPLACE(REPLACE(COALESCE(unit, ''), '8kB', 'MB'), 'kB', 'MB') AS setting
    --, REPLACE(REPLACE(COALESCE(unit, ''), '8kB', 'MB'), 'kB', 'MB')
FROM
    pg_settings
WHERE
    name IN ('autovacuum_analyze_scale_factor', 'autovacuum_analyze_threshold', 'autovacuum_max_workers', 'autovacuum_naptime', 'autovacuum_vacuum_cost_delay', 'autovacuum_vacuum_cost_limit', 'autovacuum_vacuum_scale_factor', 'autovacuum_vacuum_threshold', 'autovacuum_work_mem', 'checkpoint_completion_target', 'checkpoint_timeout', 'default_statistics_target', 'effective_cache_size', 'effective_io_concurrency', 'log_autovacuum_min_duration', 'log_connections', 'log_hostname', 'log_line_prefix', 'log_lock_waits', 'log_min_duration_statement', 'log_statement', 'logging_collector', 'maintenance_work_mem', 'max_connections', 'max_parallel_maintenance_workers', 'max_parallel_workers', 'max_parallel_workers_per_gather', 'max_wal_size', 'max_worker_processes', 'min_wal_size', 'password_encryption', 'random_page_cost', 'shared_buffers', 'ssl', 'vacuum_cost_delay', 'vacuum_cost_limit', 'wal_buffers', 'work_mem');

--Database Size
SELECT
    datname,
    pg_database_size(pg_database.datname)
FROM
    pg_catalog.pg_database
WHERE
    datdba > 10;

--Table Size
SELECT
    pn.nspname || '.' || pc.relname,
(pg_total_relation_size('"' || pn.nspname || '"."' || pc.relname || '"') / 1024.0 / 1024.0)::decimal(18, 2) AS size_mb,
    reltuples::bigint
FROM
    pg_catalog.pg_class pc
    INNER JOIN pg_catalog.pg_namespace pn ON pc.relnamespace = pn.oid
        AND pn.nspname NOT IN ('pg_toast', 'information_schema')
        AND pc.relkind = 'r'
    ORDER BY
        2 DESC;

--Tables Missing Primary keys 1
SELECT
    c.table_schema,
    c.table_name,
    c.table_type
FROM
    information_schema.tables c
WHERE
    c.table_type = 'BASE TABLE'
    AND c.table_schema NOT IN ('information_schema', 'pg_catalog')
    AND NOT EXISTS (
        SELECT
            cu.table_name
        FROM
            information_schema.key_column_usage cu
        WHERE
            cu.table_schema = c.table_schema
            AND cu.table_name = c.table_name)
ORDER BY
    c.table_schema,
    c.table_name;

--Tables Missing Primary keys and Unique keys 2
SELECT
    c.table_schema,
    c.table_name,
    c.table_type
FROM
    information_schema.tables c
WHERE
    c.table_schema NOT IN ('information_schema', 'pg_catalog')
    AND c.table_type = 'BASE TABLE'
    AND NOT EXISTS (
        SELECT
            i.tablename
        FROM
            pg_catalog.pg_indexes i
        WHERE
            i.schemaname = c.table_schema
            AND i.tablename = c.table_name
            AND indexdef LIKE '%UNIQUE%')
    AND NOT EXISTS (
        SELECT
            cu.table_name
        FROM
            information_schema.key_column_usage cu
        WHERE
            cu.table_schema = c.table_schema
            AND cu.table_name = c.table_name)
ORDER BY
    c.table_schema,
    c.table_name;

--Missing Indexes - 1
SELECT
    relname AS TableName,
    seq_scan - idx_scan AS TotalSeqScan,
    CASE WHEN seq_scan - idx_scan > 0 THEN
        'Missing Index Found'
    ELSE
        'Missing Index Not Found'
    END AS MissingIndex,
    pg_size_pretty(pg_relation_size('"public"."' || relname || '"')) AS TableSize,
    idx_scan AS TotalIndexScan
FROM
    pg_stat_all_tables
WHERE
    schemaname = 'public'
    AND pg_relation_size('"public"."' || relname || '"') > 100000
ORDER BY
    2 DESC;

--Missing Indexes - 2
SELECT
    x1.table_in_trouble,
    pg_relation_size(x1.table_in_trouble) AS sz_n_byts,
    x1.seq_scan,
    x1.idx_scan,
    CASE WHEN pg_relation_size(x1.table_in_trouble) > 500000000 THEN
        'Exceeds 500 megs, too large to count in a view. For a count, count individually'::text
    ELSE
        count(x1.table_in_trouble)::text
    END AS tbl_rec_count,
    x1.priority
FROM (
    SELECT
        (schemaname::text || '.'::text) || relname::text AS table_in_trouble,
        seq_scan,
        idx_scan,
        CASE WHEN (seq_scan - idx_scan) < 500 THEN
            'Minor Problem'::text
        WHEN (seq_scan - idx_scan) >= 500
            AND (seq_scan - idx_scan) < 2500 THEN
            'Major Problem'::text
        WHEN (seq_scan - idx_scan) >= 2500 THEN
            'Extreme Problem'::text
        ELSE
            NULL::text
        END AS priority
    FROM
        pg_stat_all_tables
    WHERE
        seq_scan > idx_scan
        AND schemaname != 'pg_catalog'::name
        AND seq_scan > 100) x1
GROUP BY
    x1.table_in_trouble,
    x1.seq_scan,
    x1.idx_scan,
    x1.priority
ORDER BY
    x1.priority DESC,
    x1.seq_scan;

--Most scanned indexes
SELECT
    indexrelname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM
    pg_catalog.pg_stat_user_indexes
ORDER BY
    idx_scan DESC;

--Tuples fetched vs returned
SELECT
    datname,
    TO_CHAR(tup_returned, 'fm999G999G999G999G999') AS tup_returned,
    TO_CHAR(tup_fetched, 'fm999G999G999G999G999') AS tup_fetched
FROM
    pg_catalog.pg_stat_database
WHERE
    datid > 16384;

--Most autovacuumed tables/Most dead tuples
SELECT
    schemaname::text || '.'::text || relname::text AS tablename,
    n_live_tup,
    n_dead_tup,
(n_dead_tup /(n_live_tup + n_dead_tup + 1.00))::decimal(18, 2) AS pct_dead,
    autovacuum_count,
    DATE_PART('day', CURRENT_TIMESTAMP - last_autovacuum) AS days_since_autovacuum,
    autoanalyze_count,
    DATE_PART('day', CURRENT_TIMESTAMP - last_autoanalyze) AS days_since_autoanalyze
FROM
    pg_catalog.pg_stat_user_tables
ORDER BY
    n_dead_tup DESC
    --Large object Count and size
    SELECT
        count(*) AS lob_count,
    sum(length(lo.data)) AS lob_size
FROM
    pg_largeobject lo;

