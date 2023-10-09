SELECT psd.datname,
       xact_commit,
       xact_rollback,
       blks_read,
       blks_hit,
       tup_returned,
       tup_fetched,
       tup_inserted,
       tup_updated,
       tup_deleted,
       2^31 - age(datfrozenxid) AS wraparound,
       deadlocks,
       temp_bytes,
       temp_files,
       pg_database_size(psd.datname) AS pg_database_size
FROM pg_stat_database psd
JOIN pg_database pd ON psd.datname = pd.datname
WHERE psd.datname NOT ILIKE 'template%%'
    AND psd.datname NOT ILIKE 'rdsadmin'
    AND psd.datname NOT ILIKE 'azure%%'
    AND psd.datname NOT ILIKE 'postgres';