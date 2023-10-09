--Find missing indexes
SELECT
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    seq_tup_read / seq_scan
FROM
    pg_stat_user_tables
WHERE
    seq_scan > 0
ORDER BY
    seq_tup_read DESC;

--Find missing indexes
SELECT
    relname,
    seq_scan - idx_scan AS too_much_seq,
    CASE WHEN seq_scan - coalesce(idx_scan, 0) > 0 THEN
        'Missing Index ?'
    ELSE
        'OK'
    END,
    pg_relation_size(relname::regclass) AS rel_size,
    seq_scan,
    idx_scan
FROM
    pg_stat_all_tables
WHERE
    schemaname = 'public'
    AND pg_relation_size(relname::regclass) > 80000
ORDER BY
    too_much_seq DESC;

--Find missing indexes
SELECT
    x1.table_in_trouble,
    pg_relation_size(x1.table_in_trouble) AS sz_n_byts,
    x1.seq_scan,
    x1.idx_scan,
    CASE WHEN pg_relation_size(x1.table_in_trouble) > 500000000 THEN
        'Exceeds 500 megs, too large to count in a view. For a count, count individually'::text
    ELSE
        count(x1.table_in_trouble)::text
    END AS tbl_rec_count,
    x1.priority
FROM (
    SELECT
        (schemaname::text || '.'::text) || relname::text AS table_in_trouble,
        seq_scan,
        idx_scan,
        CASE WHEN (seq_scan - idx_scan) < 500 THEN
            'Minor Problem'::text
        WHEN (seq_scan - idx_scan) >= 500
            AND (seq_scan - idx_scan) < 2500 THEN
            'Major Problem'::text
        WHEN (seq_scan - idx_scan) >= 2500 THEN
            'Extreme Problem'::text
        ELSE
            NULL::text
        END AS priority
    FROM
        pg_stat_all_tables
    WHERE
        seq_scan > idx_scan
        AND schemaname != 'pg_catalog'::name
        AND seq_scan > 100) x1
GROUP BY
    x1.table_in_trouble,
    x1.seq_scan,
    x1.idx_scan,
    x1.priority
ORDER BY
    x1.priority DESC,
    x1.seq_scan;

--Find missing indexes
SELECT
    relname AS TableName,
    seq_scan - idx_scan AS TotalSeqScan,
    CASE WHEN seq_scan - idx_scan > 0 THEN
        'Missing Index Found'
    ELSE
        'Missing Index Not Found'
    END AS MissingIndex,
    pg_size_pretty(pg_relation_size(relname::regclass)) AS TableSize,
    idx_scan AS TotalIndexScan
FROM
    pg_stat_all_tables
WHERE
    schemaname = 'public'
    AND pg_relation_size(relname::regclass) > 100000
ORDER BY
    2 DESC;

-- Problem: Return all non-system tables that are missing primary keys
-- Solution:
-- This will actually work equally well on SQL Server, MySQL and any other database that supports the Information_Schema standard. It won't check for unique indexes though.
SELECT
    c.table_schema,
    c.table_name,
    c.table_type
FROM
    information_schema.tables c
WHERE
    c.table_type = 'BASE TABLE'
    AND c.table_schema NOT IN ('information_schema', 'pg_catalog')
    AND NOT EXISTS (
        SELECT
            cu.table_name
        FROM
            information_schema.key_column_usage cu
        WHERE
            cu.table_schema = c.table_schema
            AND cu.table_name = c.table_name)
ORDER BY
    c.table_schema,
    c.table_name;

-- Problem: Return all non-system tables that are missing primary keys and have no unique indexes
-- Solution - this one is not quite as portable. We had to delve into the pg_catalog since we couldn't find a table in information schema that would tell us anything about any indexes but primary keys and foreign keys. Even though in theory primary keys and unique indexes are the same, they are not from a meta data standpoint.
SELECT
    c.table_schema,
    c.table_name,
    c.table_type
FROM
    information_schema.tables c
WHERE
    c.table_schema NOT IN ('information_schema', 'pg_catalog')
    AND c.table_type = 'BASE TABLE'
    AND NOT EXISTS (
        SELECT
            i.tablename
        FROM
            pg_catalog.pg_indexes i
        WHERE
            i.schemaname = c.table_schema
            AND i.tablename = c.table_name
            AND indexdef LIKE '%UNIQUE%')
    AND NOT EXISTS (
        SELECT
            cu.table_name
        FROM
            information_schema.key_column_usage cu
        WHERE
            cu.table_schema = c.table_schema
            AND cu.table_name = c.table_name)
ORDER BY
    c.table_schema,
    c.table_name;

-- Problem - List all tables with geometry fields that have no index on the geometry field.
-- Solution -
SELECT
    c.table_schema,
    c.table_name,
    c.column_name
FROM (
    SELECT
        *
    FROM
        information_schema.tables
    WHERE
        table_type = 'BASE TABLE') AS t
    INNER JOIN (
        SELECT
            *
        FROM
            information_schema.columns
        WHERE
            udt_name = 'geometry') c ON (t.table_name = c.table_name
        AND t.table_schema = c.table_schema)
    LEFT JOIN pg_catalog.pg_indexes i ON (i.tablename = c.table_name
            AND i.schemaname = c.table_schema
            AND indexdef LIKE '%' || c.column_name || '%')
WHERE
    i.tablename IS NULL
ORDER BY
    c.table_schema,
    c.table_name;

--Find missing indexes
SELECT
    relname,
    seq_scan - idx_scan AS too_much_seq,
    CASE WHEN seq_scan - idx_scan > 0 THEN
        'Missing Index?'
    ELSE
        'OK'
    END,
    pg_relation_size(relname::regclass) AS rel_size,
    seq_scan,
    idx_scan
FROM
    pg_stat_all_tables
WHERE
    schemaname = 'public'
    AND pg_relation_size(relname::regclass) > 80000
ORDER BY
    too_much_seq DESC;

