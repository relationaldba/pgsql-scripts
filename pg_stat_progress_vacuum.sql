
/* VACUUM progress */
SELECT
    p.pid,
    age(current_timestamp, a.xact_start) AS duration,
    coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting,
    CASE
    WHEN a.query ~*'^autovacuum.*to prevent wraparound' THEN 'wraparound'
    WHEN a.query ~*'^vacuum' THEN 'user'
    ELSE 'regular'
    END AS mode,
    p.datname AS database,
    p.relid::regclass AS table,
    p.phase,
    pg_size_pretty(p.heap_blks_total * current_setting('block_size')::int) AS table_size,
    -- pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(p.heap_blks_scanned * current_setting('block_size')::int) AS scanned,
    pg_size_pretty(p.heap_blks_vacuumed * current_setting('block_size')::int) AS vacuumed,
    round(100.0 * p.heap_blks_scanned / p.heap_blks_total, 1) AS scanned_pct,
    round(100.0 * p.heap_blks_vacuumed / p.heap_blks_total, 1) AS vacuumed_pct,
    p.index_vacuum_count,
    round(100.0 * p.num_dead_tuples / p.max_dead_tuples,1) AS dead_pct
FROM 
    pg_stat_progress_vacuum p
    JOIN pg_stat_activity a using (pid)
ORDER BY 
    duration DESC;


/*ANALYZE Progress */
SELECT
    p.pid,
    age(current_timestamp, a.xact_start) AS duration,
    coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting,
    CASE
    WHEN a.query ~*'^autovacuum.*to prevent wraparound' THEN 'wraparound'
    WHEN a.query ~*'^vacuum' THEN 'user'
    ELSE 'regular'
    END AS mode,
    p.datname AS database,
    p.relid::regclass AS table,
    p.phase,
    -- pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(p.sample_blks_scanned * current_setting('block_size')::int) AS analyzed,
    round(100.0 * p.sample_blks_scanned / p.sample_blks_total, 1) AS analyzed_pct
FROM 
    pg_stat_progress_analyze p
    JOIN pg_stat_activity a using (pid)
ORDER BY 
    duration DESC;


/* CLUSTER/VACUUM-FULL progress*/
SELECT
    p.pid,
    age(current_timestamp, a.xact_start) AS duration,
    coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting,
    CASE
        WHEN a.query ~*'^autovacuum.*to prevent wraparound' THEN 'wraparound'
        WHEN a.query ~*'^vacuum' THEN 'user'
    ELSE 'regular'
    END AS mode,
    p.datname AS database,
    p.relid::regclass AS table,
    p.phase,
    pg_size_pretty(p.heap_blks_total * current_setting('block_size')::int) AS table_size,
    -- pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(p.heap_blks_scanned * current_setting('block_size')::int) AS scanned,
    round(100.0 * p.heap_blks_scanned / p.heap_blks_total, 1) AS scanned_pct
FROM 
    pg_stat_progress_cluster p
    LEFT JOIN pg_stat_activity a using (pid)
ORDER BY 
    duration DESC;