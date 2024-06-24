/* Actitivities with blocking info */
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
    AND coalesce(state, 'idle') <> 'idle'
    AND query NOT LIKE 'autovacuum%'
    -- AND COALESCE(application_name, '') IN ('vacuumlo', 'vacuumdb', '')
    -- AND cardinality(pg_blocking_pids(pid)) > 0  /* uncomment to see blocked queries */
ORDER BY
    query_age DESC;



/* Actitivities with locking info */
WITH pg_blocking_pids AS (
    SELECT
        string_to_array(string_agg(array_to_string(pg_blocking_pids (pid), ','), ','), ',') AS blocking_pids
    FROM
        pg_stat_activity
    WHERE
        cardinality(pg_blocking_pids (pid)) > 0
), 
pg_locking_pids AS (
    SELECT 
        l.pid AS "locking_pid",
        '[' || string_agg('{ relation: "' || c.relname || '", relkind: "' || c.relkind || '", locktype: "' || l.locktype || '", lockmode: "' || l.mode || '", lockgranted: "' || l.granted || '"}', ',') || ']' AS "locks_held"
    FROM 
        pg_catalog.pg_locks AS l
    JOIN
        pg_catalog.pg_class AS c
        ON l.relation = c.oid
        -- WHERE l.mode NOT IN ('AccessShareLock', 'RowShareLock')
    GROUP BY l.pid
)
SELECT
    pid,
    CASE WHEN COALESCE(array_position(blocking_pids, pid::text), 0) > 0
        AND cardinality(pg_blocking_pids (pid)) = 0 
    THEN
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
    CASE WHEN datname = current_database()
    THEN
        locks_held
    ELSE
        '<invalid-db-context>'::text
    END AS "locks_held",
    txid_current(),
    backend_xmin,    
    age(backend_xmin) AS xid_min_age,
    backend_xid,
    age(backend_xid) AS xid_age,
    'SELECT pg_terminate_backend(' || pid || ');' AS "kill_command"
FROM
    pg_stat_activity
    CROSS JOIN pg_blocking_pids
    LEFT JOIN pg_locking_pids
        ON pg_stat_activity.pid = pg_locking_pids.locking_pid
WHERE
    1 = 1
    /* exclude this pid from the list */
    AND pid <> pg_backend_pid()
    /* exclude idle pids */
    AND coalesce(state, 'idle') <> 'idle'
    AND query NOT LIKE 'autovacuum%'
    -- AND COALESCE(application_name, '') IN ('vacuumlo', 'vacuumdb', '')
    -- AND cardinality(pg_blocking_pids(pid)) > 0  /* uncomment to see blocked queries */
ORDER BY
    query_age DESC;



/* Queries that ran in the last 5 minutes */
SELECT
    datid,
    datname,
    pid,
    usesysid,
    usename,
    application_name,
    client_addr,
    client_hostname,
    client_port,
    backend_start,
    xact_start,
    query_start,
    state_change,
    wait_event_type,
    wait_event,
    state,
    backend_xid,
    backend_xmin,
    query,
    backend_type
FROM
    pg_stat_activity
WHERE
    coalesce(trim(query), '') != ''
    AND query_start IS NOT NULL
    AND datname NOT ILIKE 'template%'
    AND datname NOT ILIKE 'rdsadmin'
    AND datname NOT ILIKE 'azure_maintenance'
    AND query_start > current_timestamp - interval '5 minutes'
    AND state = 'idle';



