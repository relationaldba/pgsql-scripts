-- Progress of Index Creation
SELECT
    now()::time(0) AS current_time,
    p.pid,
    p.datname AS database,
    p.relid,
    p.phase,
    a.query,
    p.blocks_total,
    p.blocks_done,
    p.tuples_total,
    p.tuples_done,
    p.partitions_total,
    p.partitions_done
FROM
    pg_stat_progress_create_index AS p
    JOIN pg_stat_activity AS a ON p.pid = a.pid;

