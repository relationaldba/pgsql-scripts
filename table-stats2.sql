-- Most scanned tables
SELECT relname, seq_scan, seq_tup_read
FROM pg_catalog.pg_stat_user_tables
ORDER BY seq_scan DESC
LIMIT 50;

--Most Scanned indexes
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_catalog.pg_stat_user_indexes
ORDER BY idx_scan DESC
LIMIT 50;

--Least Scanned indexes
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_catalog.pg_stat_user_indexes
ORDER BY idx_scan ASC
LIMIT 50;

--Tuples Returned vs Fetched
SELECT datname, tup_returned, tup_fetched
FROM pg_catalog.pg_stat_database
WHERE datid > 16384;

--Dead Tuples
SELECT relname, n_live_tup, n_dead_tup
FROM pg_catalog.pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 50;

--Most Vacuumed Tables
SELECT relname, n_dead_tup, autovacuum_count, last_autovacuum
FROM pg_catalog.pg_stat_user_tables
ORDER BY autovacuum_count DESC
LIMIT 50;

--Least Vacuumed Tables
SELECT relname, n_dead_tup, autovacuum_count, last_autovacuum
FROM pg_catalog.pg_stat_user_tables
ORDER BY autovacuum_count ASC
LIMIT 50;

--Active vs Idle connections
SELECT *
FROM pg_catalog.pg_stat_activity;

SELECT pg_current_xact_id_if_assigned()