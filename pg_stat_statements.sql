-- To enable pg_stat_statements on your server change the following line in postgresql.conf and restart PostgreSQL
-- shared_preload_libraries = 'pg_stat_statements'
-- Once this module has been loaded into the server, PostgreSQL will automatically start to collect information.
-- The good thing is that the overhead of the module is really really low
SET ROLE postgres;

-- DROP EXTENSION IF EXISTS pg_stat_statements;
CREATE EXTENSION pg_stat_statements;

SELECT
    *
FROM
    pg_stat_statements
ORDER BY
    total_time DESC;

SELECT
    substring(query, 1, 500) AS short_query,
    round(total_time::numeric, 2) AS total_time,
    calls,
    round(mean_time::numeric, 2) AS mean,
    round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM
    pg_stat_statements
ORDER BY
    total_time DESC;

SELECT
    dat.datname AS database,
    rol.rolname AS user,
    pss.query,
    to_char(calls, 'fm999G999G999G999G999') AS exec_count,
    ROWS,
    round(mean_exec_time::numeric, 2) AS avg_time_ms,
    round(max_exec_time::numeric, 2) AS max_time_ms,
    round(total_exec_time::numeric, 2) AS total_time_ms,
    round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS pct_cpu,
    shared_blks_hit,
    shared_blks_read,
    shared_blks_dirtied,
    shared_blks_written,
    blk_read_time,
    blk_write_time
FROM
    pg_stat_statements AS pss
    JOIN pg_catalog.pg_roles AS rol ON pss.userid = rol.oid
    JOIN pg_catalog.pg_database AS dat ON pss.dbid = dat.oid
WHERE
    1 = 1
    --AND dat.datname NOT IN ('postgres', 'template0', 'template1', 'azure_sys', 'azure_maintenance')
    AND rol.rolname NOT IN ('azure_superuser', 'azure_backup', 'azure_replication_user')
ORDER BY
    pct_cpu DESC;

-- ORDER BY blk_read_time DESC;
-- ORDER BY calls DESC;
-- ORDER BY avg_time_ms DESC;
-- ORDER BY shared_blks_read DESC;
-- ORDER BY rows DESC;
/* 
 To reset pg_stat_statements data you can run:
 */
--SELECT pg_stat_statements_reset();
/*
 To grant permissions to read all stats
 */
--GRANT pg_read_all_stats TO CURRENT_USER;
