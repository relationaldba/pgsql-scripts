-- Details of all existing indexes
SELECT
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    --    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    --    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN
        'Y'
    ELSE
        'N'
    END AS UNIQUE,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    indisunique,
    indisprimary,
    indisclustered,
    indisvalid,
    indisready,
    indislive
FROM
    pg_tables AS t
    LEFT OUTER JOIN pg_class AS c ON t.tablename = c.relname
    LEFT OUTER JOIN (
        SELECT
            c.relname AS ctablename,
            ipg.relname AS indexname,
            x.indnatts AS number_of_columns,
            idx_scan,
            idx_tup_read,
            idx_tup_fetch,
            indexrelname,
            x.indisunique,
            x.indisprimary,
            x.indisclustered,
            x.indisvalid,
            x.indisready,
            x.indislive
        FROM
            pg_index AS x
            JOIN pg_class AS c ON c.oid = x.indrelid
            JOIN pg_class AS ipg ON ipg.oid = x.indexrelid
            JOIN pg_stat_all_indexes AS psai ON x.indexrelid = psai.indexrelid) AS foo ON t.tablename = foo.ctablename
WHERE
    t.schemaname = 'public'
    -- AND t.tablename = 'hfj_res_ver'
ORDER BY
    1,
    2;

-- Index status
SELECT
    nsp.nspname AS schemaname,
    cr.relname AS tablename,
    ci.relname AS indexname,
    i.indisunique AS is_unique,
    i.indisprimary AS is_primary,
    i.indisclustered AS is_clustered,
    i.indisvalid AS is_valid,
    i.indisready AS is_ready,
    i.indislive AS is_live,
    -- (pg_relation_size('"' || nsp.nspname || '"."' || ci.relname || '"') / 1024.0 / 1024.0 / 1024.0)::decimal(18, 2) AS size_gb
FROM
    pg_index AS i
    JOIN pg_class AS ci ON i.indexrelid = ci.oid
        AND ci.relkind = 'i'
    JOIN pg_class AS cr ON i.indrelid = cr.oid
        AND cr.relkind = 'r'
    JOIN pg_namespace AS nsp ON cr.relnamespace = nsp.oid
        AND nsp.nspname NOT LIKE 'pg_%'
WHERE
    cr.relname = '%';

-- Details of all existing indexes
SELECT
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN
        'Y'
    ELSE
        'N'
    END AS UNIQUE,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM
    pg_tables t
    LEFT OUTER JOIN pg_class c ON t.tablename = c.relname
    LEFT OUTER JOIN (
        SELECT
            c.relname AS ctablename,
            ipg.relname AS indexname,
            x.indnatts AS number_of_columns,
            idx_scan,
            idx_tup_read,
            idx_tup_fetch,
            indexrelname,
            indisunique
        FROM
            pg_index x
            JOIN pg_class c ON c.oid = x.indrelid
            JOIN pg_class ipg ON ipg.oid = x.indexrelid
            JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid) AS foo ON t.tablename = foo.ctablename
WHERE
    t.schemaname = 'public'
ORDER BY
    1,
    2;

--List Indexes on a table
SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    indexname;

