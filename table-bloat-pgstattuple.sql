--CREATE EXTENSION IF NOT EXISTS pgstattuple;

DROP TABLE IF EXISTS temp_pgstattuple;

CREATE  TEMP TABLE IF NOT EXISTS temp_pgstattuple AS
SELECT 'pg_catalog.pg_proc'::varchar(500) AS table_name, * FROM pgstattuple('pg_catalog.pg_proc');

--SELECT * FROM temp_pgstattuple;
DELETE FROM temp_pgstattuple;

DO $$
DECLARE
    rel varchar(100);
BEGIN
    for rel in SELECT '"'||pn.nspname||'"."'||pc.relname||'"' AS relname
                    FROM pg_catalog.pg_class pc
                    INNER JOIN pg_catalog.pg_namespace pn 
                    ON pc.relnamespace = pn.oid 
                    AND pn.nspname NOT IN ('pg_toast', 'information_schema', 'pg_catalog')
                    AND pc.relkind = 'r'
                    AND pc.relpersistence = 'p'
                    --LIMIT 10
    LOOP
        INSERT INTO temp_pgstattuple
        SELECT rel, * FROM pgstattuple(rel);
    END LOOP;
END;
$$


SELECT * FROM temp_pgstattuple;
-- DROP TABLE IF EXISTS temp_pgstattuple;


