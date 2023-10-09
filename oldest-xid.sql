SELECT 
    pid,
    datname,
    usename,
    state,
    txid_current(),
    backend_xmin,    
    age(backend_xmin) AS xid_min_age,
    backend_xid,
    age(backend_xid) AS xid_age,
    query
FROM 
    pg_stat_activity
WHERE 
    backend_xmin IS NOT NULL
    OR backend_xid IS NOT NULL
ORDER BY 
    datname,
    greatest(age(backend_xmin), age(backend_xid)) DESC;
