/* Objects owned by a specific user */
WITH pgobjects AS (
SELECT nsp.nspname AS schemaname,
       cls.relname AS objectname,
       rol.rolname AS objectowner,
       CASE cls.relkind
           WHEN 'r' THEN 'TABLE'
           WHEN 'i' THEN 'INDEX'
           WHEN 'S' THEN 'SEQUENCE'
           WHEN 't' THEN 'TOAST_TABLE'
           WHEN 'v' THEN 'VIEW'
           WHEN 'm' THEN 'MATERIALIZED VIEW' /* MATERIALIZED VIEW */
           WHEN 'c' THEN 'COMPOSITE TYPE'
           WHEN 'f' THEN 'FOREIGN TABLE'
           WHEN 'p' THEN 'PARTITIONED TABLE'
           WHEN 'I' THEN 'PARTITIONED INDEX'
           ELSE cls.relkind::text
       END AS objecttype
FROM pg_class AS cls
JOIN pg_namespace AS nsp ON nsp.oid = cls.relnamespace
LEFT JOIN pg_roles AS rol ON rol.oid = cls.relowner
WHERE nsp.nspname NOT IN ('information_schema', 'pg_catalog')
    AND nsp.nspname NOT LIKE 'pg_toast%'
    AND nsp.nspname NOT LIKE 'pg_temp%'

UNION ALL

SELECT nsp.nspname AS schemaname,
       pr.proname AS objectname,
       rol.rolname AS objectowner,
       CASE pr.prokind
           WHEN 'f' THEN 'FUNCTION'
           WHEN 'p' THEN 'PROCEDURE'
           WHEN 'a' THEN 'FUNCTION' /* AGGREGATE FUNCTION */
           WHEN 'w' THEN 'FUNCTION' /* WINDOW FUNCTION */
           ELSE pr.prokind ::text
       END AS objecttype
FROM pg_proc pr
JOIN pg_namespace AS nsp ON nsp.oid = pr.pronamespace
LEFT JOIN pg_roles AS rol ON rol.oid = pr.proowner
WHERE nsp.nspname NOT IN ('information_schema', 'pg_catalog')
    AND nsp.nspname NOT LIKE 'pg_toast%'
    AND nsp.nspname NOT LIKE 'pg_temp%'


UNION ALL

SELECT nsp.nspname AS schemaname,
       nsp.nspname AS objectname,
       rol.rolname AS objectowner,
       'SCHEMA' AS objecttype
FROM pg_namespace AS nsp
JOIN pg_roles AS rol ON nsp.nspowner = rol.oid
WHERE nsp.nspname NOT IN ('information_schema',
                          'pg_catalog')
    AND nsp.nspname NOT LIKE 'pg_toast%'
    AND nsp.nspname NOT LIKE 'pg_temp%'
)

SELECT schemaname,
       objectname,
       objectowner,
       objecttype,
       CASE objecttype
       WHEN 'SCHEMA' THEN 'ALTER ' || objecttype || ' ' || quote_ident(schemaname) || ' OWNER TO crsmaster;' 
       ELSE 'ALTER ' || objecttype || ' ' || quote_ident(schemaname) || '.' || quote_ident(objectname) || ' OWNER TO crsmaster;' 
       END AS alter_owner_command
FROM pgobjects
WHERE schemaname NOT IN ('apg_plan_mgmt',
                         'pganalyze',
                         'datadog',
                         'public')
    AND objecttype IN ('SCHEMA',
                       'TABLE',
                       'VIEW',
                       'SEQUENCE',
                       'FUNCTION',
                       'PROCEDURE') /* enter the types here */
    AND objectowner NOT IN ('rdsadmin', 'rds_superuser') -- AND schemaname IN ('dbo')
    -- AND objectowner = '' /* enter owner username here */
    -- AND objectname = '' /* enter the name of the object here */
ORDER BY schemaname,
         objecttype,
         objectname;







/* Tables, Indexes, Sequences, Views, etc owned by a specific user */
SELECT nsp.nspname AS schemaname,
       cls.relname AS objectname,
       rol.rolname AS objectowner,
       CASE cls.relkind
           WHEN 'r' THEN 'TABLE'
           WHEN 'i' THEN 'INDEX'
           WHEN 'S' THEN 'SEQUENCE'
           WHEN 't' THEN 'TOAST_TABLE'
           WHEN 'v' THEN 'VIEW'
           WHEN 'm' THEN 'MATERIALIZED_VIEW'
           WHEN 'c' THEN 'COMPOSITE_TYPE'
           WHEN 'f' THEN 'FOREIGN_TABLE'
           WHEN 'p' THEN 'PARTITIONED_TABLE'
           WHEN 'I' THEN 'PARTITIONED_INDEX'
           ELSE cls.relkind::text
       END AS objecttype
FROM pg_class AS cls
JOIN pg_namespace AS nsp ON nsp.oid = cls.relnamespace
LEFT JOIN pg_roles AS rol ON rol.oid = cls.relowner
WHERE nsp.nspname NOT IN ('information_schema', 'pg_catalog')
    AND nsp.nspname NOT LIKE 'pg_toast%'
    -- AND rol.rolname = '' /* enter username here */
ORDER BY schemaname, objecttype, objectname;


/* Functions and Procedures owned by a specific user */
SELECT nsp.nspname AS schemaname,
       proname AS objectname,
       rol.rolname AS objectowner,
       CASE pr.prokind
           WHEN 'f' THEN 'FUNCTION'
           WHEN 'p' THEN 'PROCEDURE'
           WHEN 'a' THEN 'FUNCTION_AGGREGATE'
           WHEN 'w' THEN 'FUNCTION_WINDOW'
           ELSE pr.prokind ::text
       END AS objecttype
FROM pg_proc pr
JOIN pg_namespace AS nsp ON nsp.oid = pr.pronamespace
LEFT JOIN pg_roles AS rol ON rol.oid = pr.proowner
WHERE nsp.nspname NOT IN ('information_schema', 'pg_catalog')
    AND nsp.nspname NOT LIKE 'pg_toast%'
    -- AND rol.rolname = '' /* enter username here */
ORDER BY schemaname, objecttype, objectname;




-- DROP ALL Tables in curent schema
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- DROP ALL Sequences
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT relname FROM pg_class where relkind = 'S') LOOP
        EXECUTE 'DROP SEQUENCE IF EXISTS ' || quote_ident(r.relname) || ' CASCADE';
    END LOOP;
END $$;
