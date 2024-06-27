SELECT
    *
FROM
    pg_ls_tmpdir(
        SELECT
            oid
        FROM pg_tablespace
        WHERE
            spcname = 'mydb')
ORDER BY
    modification;

SELECT
    pg_size_pretty(sum(size))
FROM
    pg_ls_tmpdir((
        SELECT
            oid
        FROM pg_tablespace
        WHERE
            spcname = 'mydb'));

SELECT
    datname,
    temp_files,
    pg_size_pretty(temp_bytes) AS temp_file_size
FROM
    pg_stat_database
ORDER BY
    temp_bytes DESC;
