/* Replication Delay: Run on the replica instance. */
SELECT
    now() - pg_last_xact_replay_timestamp() AS replication_lag;


/* Replication Delay: Run on the replica instance. */
SELECT
    pg_last_xlog_receive_location() receive,
    pg_last_xlog_replay_location() replay,
(extract(epoch FROM now()) - extract(epoch FROM pg_last_xact_replay_timestamp()))::int lag;

SELECT
    *
FROM
    pg_stat_wal_receiver;

SELECT
    pg_is_in_recovery();


/* Replication Status: Run on the primary instance. */
SELECT
    usename,
    application_name,
    client_addr,
    state,
    sync_state,
    replay_lag
FROM
    pg_stat_replication;

SELECT
    slot_name,
    slot_type,
    TEMPORARY,
    active,
    wal_status
FROM
    pg_replication_slots;

