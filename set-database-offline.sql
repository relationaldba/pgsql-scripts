BEGIN TRANSACTION;
UPDATE
    pg_database
SET
    datallowconn = FALSE
WHERE
    datname = 'mydb';
COMMIT TRANSACTION;

