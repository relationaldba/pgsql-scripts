DO $$
BEGIN
    IF(
        SELECT
            oid
        FROM
            pg_database
        WHERE
            datname = 'mydb') IS NULL THEN
        RAISE NOTICE 'The database mydb is not present. Creating database now.';
    ELSE
        RAISE NOTICE 'The database mydb is already present.';
    END IF;
END
$$
