WITH pg_blocking_pids AS (
    SELECT
        string_to_array(string_agg(array_to_string(pg_blocking_pids (pid), ','), ','), ',') AS blocking_pids
    FROM
        pg_stat_activity
    WHERE
        cardinality(pg_blocking_pids (pid)) > 0
)
SELECT
    pid,
    CASE WHEN COALESCE(array_position(blocking_pids, pid::text), 0) > 0
        AND cardinality(pg_blocking_pids (pid)) = 0 THEN
        'Y'::char(1)
    ELSE
        ''::char(1)
    END AS "head_blocker",
    pg_blocking_pids (pid) AS "blocked_by",
    datname AS "database",
    usename,
    -- age(clock_timestamp(), backend_start) AS "backend_age",
    age(clock_timestamp(), query_start) AS "query_age",
    query,
    application_name,
    client_addr::text,
    wait_event_type,
    wait_event,
    state,
    txid_current(),
    backend_xmin,    
    age(backend_xmin) AS xid_min_age,
    backend_xid,
    age(backend_xid) AS xid_age,
    'SELECT pg_terminate_backend(' || pid || ');' AS "kill_command"
FROM
    pg_stat_activity
    CROSS JOIN pg_blocking_pids
WHERE
    1 = 1
    /* exclude this pid from the list */
    AND pid <> pg_backend_pid()
    /* exclude idle pids */
    AND state <> 'idle'
    AND query NOT LIKE 'autovacuum%'
    -- AND COALESCE(application_name, '') IN ('vacuumlo', 'vacuumdb', '')
    -- AND cardinality(pg_blocking_pids(pid)) > 0  /* uncomment to see blocked queries */
ORDER BY
    query_age DESC;