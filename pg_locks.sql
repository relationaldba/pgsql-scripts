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