SELECT 
    a.pid,
    a.usename,
    a.datname,
    a.query,
    c.relname AS relation,
    c.relkind,
    l.locktype,
    l.mode,
    l.granted
FROM 
    pg_stat_activity AS a
JOIN 
    pg_locks AS l
    ON a.pid = l.pid
JOIN
    pg_class AS c
    ON l.relation = c.oid
WHERE 
    1 = 1
    -- AND granted IS TRUE
    AND a.backend_xmin IS NOT NULL
    AND a.pid = 12345;



SELECT
    locktype,
    virtualtransaction,
    transactionid,
    nspname,
    relname,
    mode,
    granted,
    cast(date_trunc('second',query_start) AS timestamp) AS query_start,
    query
FROM 
    pg_locks 
        LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
        LEFT OUTER JOIN pg_namespace ON (pg_namespace.oid = pg_class.relnamespace),
        pg_stat_activity
    WHERE
        NOT pg_locks.pid=pg_backend_pid() AND
        pg_locks.pid=pg_stat_activity.pid;
        