/* To view PostgreSQL config parameters */
-- show all;
SELECT
    *
FROM
    pg_settings;


/* Syntax to set a config value in PostgreSQL */
ALTER SYSTEM SET configuration_parameter { TO | = } { value | 'value' | DEFAULT };


/* Reset value of a specific config parameter */
ALTER SYSTEM RESET configuration_parameter;


/* Reset value of all config parameters */
ALTER SYSTEM RESET ALL;


/* Examples */
ALTER SYSTEM SET log_statement = 'all';

ALTER SYSTEM SET log_min_duration_statement = 1000;

ALTER SYSTEM SET log_duration = TRUE;

ALTER SYSTEM SET shared_buffers = '8GB';

ALTER SYSTEM SET effective_cache_size = '24GB';

ALTER SYSTEM SET maintenance_work_mem = '1.99GB';

ALTER SYSTEM SET work_mem = '256MB';

ALTER SYSTEM SET max_worker_processes = '12';

ALTER SYSTEM SET max_parallel_workers_per_gather = '6';

ALTER SYSTEM SET max_parallel_workers = '12';

ALTER SYSTEM SET timezone = 'UTC';

SELECT
    *
FROM
    pg_settings
WHERE
    name IN ('shared_buffers', 'effective_cache_size', 'maintenance_work_mem', 'work_mem', 'max_worker_processes', 'max_parallel_workers_per_gather', 'max_parallel_workers');

SELECT
    *
FROM
    pg_settings
WHERE
    name ILIKE '%log%';

