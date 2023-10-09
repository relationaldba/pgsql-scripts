/*
* vacuumlo - The below statements are run by the vacuumlo
* utility on the PostgreSQL database while cleaning up
* orphan large objects
*/

-- vacuumlo command
-- vacuumlo -h localhost -U postgres lob_test 

2023-01-22 22:16:10.691 EST [54142] postgres@lob_test LOG:  statement: SELECT pg_catalog.set_config('search_path', '', false);
2023-01-22 22:16:10.691 EST [54142] postgres@lob_test LOG:  statement: CREATE TEMP TABLE vacuum_l AS SELECT oid AS lo FROM pg_largeobject_metadata
2023-01-22 22:16:10.692 EST [54142] postgres@lob_test LOG:  statement: ANALYZE vacuum_l
2023-01-22 22:16:10.693 EST [54142] postgres@lob_test LOG:  statement: SELECT s.nspname, c.relname, a.attname FROM pg_class c, pg_attribute a, pg_namespace s, pg_type t WHERE a.attnum > 0 AND NOT a.attisdropped       AND a.attrelid = c.oid       AND a.atttypid = t.oid       AND c.relnamespace = s.oid       AND t.typname in ('oid', 'lo')       AND c.relkind in ('r', 'm')      AND s.nspname !~ '^pg_'
2023-01-22 22:16:10.694 EST [54142] postgres@lob_test LOG:  statement: DELETE FROM vacuum_l WHERE lo IN (SELECT "oid" FROM "public"."test_table")
2023-01-22 22:16:10.695 EST [54142] postgres@lob_test LOG:  statement: begin
2023-01-22 22:16:10.695 EST [54142] postgres@lob_test LOG:  statement: DECLARE myportal CURSOR WITH HOLD FOR SELECT lo FROM vacuum_l
2023-01-22 22:16:10.695 EST [54142] postgres@lob_test LOG:  statement: FETCH FORWARD 1000 IN myportal
2023-01-22 22:16:10.695 EST [54142] postgres@lob_test LOG:  statement: select proname, oid from pg_catalog.pg_proc where proname in ('lo_open', 'lo_close', 'lo_creat', 'lo_create', 'lo_unlink', 'lo_lseek', 'lo_lseek64', 'lo_tell', 'lo_tell64', 'lo_truncate', 'lo_truncate64', 'loread', 'lowrite') and pronamespace = (select oid from pg_catalog.pg_namespace where nspname = 'pg_catalog')
2023-01-22 22:16:10.695 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  fastpath function call: "lo_unlink" (OID 964)
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  statement: FETCH FORWARD 1000 IN myportal
2023-01-22 22:16:10.696 EST [54142] postgres@lob_test LOG:  statement: commit
