SELECT
    pg_database.datname AS "database_name",
    pg_database_size(pg_database.datname) / 1024 / 1024 / 1024 AS size_in_gb
FROM
    pg_database
    --WHERE datdba > 10
ORDER BY
    size_in_gb DESC;

SELECT
    SUM(pg_database_size(pg_database.datname) / 1024 / 1024 / 1024) AS total_size_in_gb
FROM
    pg_database;

SELECT
    pg_size_pretty(pg_database_size('dbname'));

