SELECT
    ((blocks_done+tuples_done)::float/(blocks_total+tuples_total)*100)::NUMERIC(6,2) AS pct_done,
    age(clock_timestamp(), query_start),
    idx.datname, 
    idx.command, 
    idx.phase, 
    activity.query, 
    activity.state, 
    activity.application_name, 
    activity.client_addr
FROM pg_stat_progress_create_index AS idx
JOIN pg_stat_activity AS activity
    ON idx.pid = activity.pid;