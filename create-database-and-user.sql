-- Create a role with login
CREATE ROLE <user_name> WITH LOGIN PASSWORD 'xxxx';
GRANT <user_name> TO psqladmin;

-- Create a database
CREATE DATABASE <database_name> WITH OWNER <user_name>;


-- Assign permissions to the 
GRANT ALL ON DATABASE <database_name> TO <user_name>;
GRANT ALL ON SCHEMA public TO <user_name>;
GRANT ALL ON ALL TABLES IN SCHEMA public TO <user_name>;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO <user_name>;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO <user_name>;


-- Reassign object ownership
REASSIGN OWNED BY psqladmin TO <user_name>;


--DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO <user_name>;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public
GRANT SELECT, UPDATE, USAGE ON SEQUENCES TO <user_name>;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public
GRANT EXECUTE ON FUNCTIONS TO <user_name>;


-- Change ownership of all objects
DO $$
DECLARE 
    r record;
    v_schema varchar := 'public';
    v_new_owner varchar := 'smilecdr';
BEGIN
    FOR r IN 
        select 'ALTER TABLE "' || table_schema || '"."' || table_name || '" OWNER TO ' || v_new_owner || ';' as a from information_schema.tables where table_schema = v_schema
        union all
        select 'ALTER TABLE "' || sequence_schema || '"."' || sequence_name || '" OWNER TO ' || v_new_owner || ';' as a from information_schema.sequences where sequence_schema = v_schema
        union all
        select 'ALTER TABLE "' || table_schema || '"."' || table_name || '" OWNER TO ' || v_new_owner || ';' as a from information_schema.views where table_schema = v_schema
        union all
        select 'ALTER FUNCTION "'||nsp.nspname||'"."'||p.proname||'"('||pg_get_function_identity_arguments(p.oid)||') OWNER TO ' || v_new_owner || ';' as a from pg_proc p join pg_namespace nsp ON p.pronamespace = nsp.oid where nsp.nspname = v_schema
        union all
        select 'ALTER SCHEMA "' || v_schema || '" OWNER TO ' || v_new_owner 
        union all
        select 'ALTER DATABASE "' || current_database() || '" OWNER TO ' || v_new_owner 
    LOOP
        EXECUTE r.a;
    END LOOP;
END$$;


-- Change ownership of all large objects
DO $$
DECLARE
    v_new_owner varchar := 'smilecdr';
BEGIN
    FOR lob IN 
        SELECT oid
	    FROM pg_catalog.pg_largeobject_metadata
    LOOP 
	    EXECUTE 'ALTER LARGE OBJECT ' || lob.oid || ' OWNER TO ' || v_new_owner || ';';
        COMMIT;
    END LOOP;
END$$;