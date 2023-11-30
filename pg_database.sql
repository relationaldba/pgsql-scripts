SELECT 
    pg_database.datname AS database,
    pg_user.usename AS owner,
    pg_size_pretty(pg_database_size(pg_database.datname)) AS database_size
FROM pg_database
JOIN pg_user ON pg_database.datdba = pg_user.usesysid
WHERE pg_database.datdba > 10
AND datistemplate = false;



SELECT
    d.datname AS database_name,
    pg_catalog.pg_get_userbyid(d.datdba) AS owner_name,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT') THEN
        pg_catalog.pg_database_size(d.datname)
    ELSE
        NULL
    END AS size_bytes,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT') THEN
        pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
    ELSE
        'No Access'
    END AS size_pretty
FROM
    pg_catalog.pg_database d
WHERE
    datdba > 10
ORDER BY
    size_bytes DESC NULLS LAST
LIMIT 20;