SELECT
    datname,
    usename,
    client_addr::text,
    application_name,
    COUNT(*)
FROM
    pg_stat_activity
WHERE
    1 = 1
    -- AND state <> 'idle'
    -- AND application_name = 'PostgreSQL JDBC Driver'
GROUP BY
    datname,
    usename,
    client_addr::text,
    application_name
ORDER BY datname,
    usename,
    client_addr::text,
    application_name;

