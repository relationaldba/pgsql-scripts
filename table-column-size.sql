SELECT
    pg_size_pretty(pg_relation_size('public.mytable')) table_size;

SELECT
    concat(CAST(SUM(length(content)) / 1024.0 / 1024.0 / 1024.0 AS decimal(12, 2)), ' GB') AS column_size
FROM
    public.mytable;

