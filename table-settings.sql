SELECT
    pg_namespace.nspname,
    relname,
    reloptions
FROM
    pg_class
    JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
        AND relkind = 'r'
WHERE
    relname LIKE '%%'
    OR reloptions IS NOT NULL
    AND pg_namespace.nspname = 'public';


/*
ALTER TABLE public.mytable RESET (autovacuum_vacuum_scale_factor = 0.05);
ALTER TABLE public.mytable RESET (autovacuum_vacuum_threshold = 5000);

ALTER TABLE public.mytable RESET (autovacuum_vacuum_scale_factor);
ALTER TABLE public.mytable RESET (autovacuum_vacuum_threshold);
 */
