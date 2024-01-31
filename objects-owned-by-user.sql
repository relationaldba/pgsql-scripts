SELECT nsp.nspname AS schemaname,
       cls.relname AS objectname,
       rol.rolname AS objectowner,
       CASE cls.relkind
           WHEN 'r' THEN 'TABLE'
           WHEN 'm' THEN 'MATERIALIZED_VIEW'
           WHEN 'i' THEN 'INDEX'
           WHEN 'S' THEN 'SEQUENCE'
           WHEN 'v' THEN 'VIEW'
           WHEN 'c' THEN 'TYPE'
           ELSE cls.relkind::text
       END AS objecttype
FROM pg_class AS cls
JOIN pg_roles AS rol ON rol.oid = cls.relowner
JOIN pg_namespace AS nsp ON nsp.oid = cls.relnamespace
WHERE nsp.nspname NOT IN ('information_schema',
                          'pg_catalog')
    AND nsp.nspname NOT LIKE 'pg_toast%'
    AND rol.rolname = '' /* enter username here */
ORDER BY objecttype,
         nsp.nspname,
         cls.relname;


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
