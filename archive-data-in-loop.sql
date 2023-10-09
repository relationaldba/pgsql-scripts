SET enable_seqscan = false;
DO $$
DECLARE
    cdr_audit_evt_pid_min bigint;
    cdr_audit_evt_pid_max bigint;
    cdr_audit_evt_counter bigint;

    cdr_audit_evt_target_res_pid_min bigint;
    cdr_audit_evt_target_res_pid_max bigint;
    cdr_audit_evt_target_res_counter bigint;

    cdr_audit_evt_target_module_pid_min bigint;
    cdr_audit_evt_target_module_pid_max bigint;
    cdr_audit_evt_target_module_counter bigint;

    cdr_audit_evt_target_user_pid_min bigint;
    cdr_audit_evt_target_user_pid_max bigint;
    cdr_audit_evt_target_user_counter bigint;

    archive_date timestamp without time zone := date_trunc('MONTH', now() - INTERVAL '3 MONTHS')::timestamp without time zone;

BEGIN
    RAISE INFO '[ % ] archive_date: %', current_timestamp::timestamp(0), archive_date::timestamp(0);

    /* cdr_audit_evt_pid_min */
    SELECT min(pid) INTO cdr_audit_evt_pid_min
    FROM cdr_audit_evt;
    RAISE INFO '[ % ] cdr_audit_evt_pid_min: %', current_timestamp::timestamp(0), cdr_audit_evt_pid_min;

    /* cdr_audit_evt_pid_max */
    SELECT max(pid) INTO cdr_audit_evt_pid_max
    FROM cdr_audit_evt
    WHERE evt_timestamp = (
        SELECT max(evt_timestamp)
        FROM cdr_audit_evt
        WHERE evt_timestamp < archive_date::timestamp without time zone
    );
    RAISE INFO '[ % ] cdr_audit_evt_pid_max: %', current_timestamp::timestamp(0), cdr_audit_evt_pid_max;

    /* cdr_audit_evt_target_res_pid_min */
    SELECT min(pid) INTO cdr_audit_evt_target_res_pid_min
    FROM cdr_audit_evt_target_res;
    RAISE INFO '[ % ] cdr_audit_evt_target_res_pid_min: %', current_timestamp::timestamp(0), cdr_audit_evt_target_res_pid_min;

    /* cdr_audit_evt_target_res_pid_max */
    SELECT max(pid) INTO cdr_audit_evt_target_res_pid_max
    FROM ( 
        SELECT pid
        FROM cdr_audit_evt_target_res
        WHERE event_pid <= cdr_audit_evt_pid_max
        ORDER BY event_pid DESC
        LIMIT 10000
    ) AS target_res_max;
    RAISE INFO '[ % ] cdr_audit_evt_target_res_pid_max: %', current_timestamp::timestamp(0), cdr_audit_evt_target_res_pid_max;

    /* cdr_audit_evt_target_module_pid_min */
    SELECT min(pid) INTO cdr_audit_evt_target_module_pid_min
    FROM cdr_audit_evt_target_module;
    RAISE INFO '[ % ] cdr_audit_evt_target_module_pid_min: %', current_timestamp::timestamp(0), cdr_audit_evt_target_module_pid_min;

    /* cdr_audit_evt_target_module_pid_max */
    SELECT max(pid) INTO cdr_audit_evt_target_module_pid_max
    FROM ( 
        SELECT pid
        FROM cdr_audit_evt_target_module
        WHERE event_pid <= cdr_audit_evt_pid_max
        ORDER BY event_pid DESC
        LIMIT 10000
    ) AS target_module_max;
    RAISE INFO '[ % ] cdr_audit_evt_target_module_pid_max: %', current_timestamp::timestamp(0), cdr_audit_evt_target_module_pid_max;

    /* cdr_audit_evt_target_user_pid_min */
    SELECT min(pid) INTO cdr_audit_evt_target_user_pid_min
    FROM cdr_audit_evt_target_user;
    RAISE INFO '[ % ] cdr_audit_evt_target_user_pid_min: %', current_timestamp::timestamp(0), cdr_audit_evt_target_user_pid_min;

    /* cdr_audit_evt_target_user_pid_max */
    SELECT max(pid) INTO cdr_audit_evt_target_user_pid_max
    FROM ( 
        SELECT pid
        FROM cdr_audit_evt_target_user
        WHERE event_pid <= cdr_audit_evt_pid_max
        ORDER BY event_pid DESC
        LIMIT 10000
    ) AS target_module_max;
    RAISE INFO '[ % ] cdr_audit_evt_target_user_pid_max: %', current_timestamp::timestamp(0), cdr_audit_evt_target_user_pid_max;

    cdr_audit_evt_counter := cdr_audit_evt_pid_min;
    cdr_audit_evt_target_res_counter := cdr_audit_evt_target_res_pid_min;
    cdr_audit_evt_target_module_counter := cdr_audit_evt_target_module_pid_min;
    cdr_audit_evt_target_user_counter := cdr_audit_evt_target_user_pid_min;


    /* Insert the rows into the archive table and then delete from the main table in batches of 1000 */

    /* archive cdr_audit_evt_target_module */
    WHILE cdr_audit_evt_target_module_counter <= (cdr_audit_evt_target_module_pid_max + 10000) LOOP
        INSERT INTO cdr_audit_evt_target_module_archive
        SELECT
            *
        FROM
            cdr_audit_evt_target_module
        WHERE
            pid <= LEAST(cdr_audit_evt_target_module_counter, cdr_audit_evt_target_module_pid_max);

        DELETE FROM cdr_audit_evt_target_module
        WHERE pid <= LEAST(cdr_audit_evt_target_module_counter, cdr_audit_evt_target_module_pid_max);

        -- RAISE INFO '[ % ] Archived cdr_audit_evt_target_module upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_target_module_counter, cdr_audit_evt_target_module_pid_max);
        
        COMMIT;

        cdr_audit_evt_target_module_counter := cdr_audit_evt_target_module_counter + 10000;
    END LOOP;
    RAISE INFO '[ % ] Archived cdr_audit_evt_target_module upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_target_module_counter, cdr_audit_evt_target_module_pid_max);

    /* archive cdr_audit_evt_target_user */
    WHILE cdr_audit_evt_target_user_counter <= (cdr_audit_evt_target_user_pid_max + 10000) LOOP
        INSERT INTO cdr_audit_evt_target_user_archive
        SELECT
            *
        FROM
            cdr_audit_evt_target_user
        WHERE
            pid <= LEAST(cdr_audit_evt_target_user_counter, cdr_audit_evt_target_user_pid_max);

        DELETE FROM cdr_audit_evt_target_user
        WHERE pid <= LEAST(cdr_audit_evt_target_user_counter, cdr_audit_evt_target_user_pid_max);

        -- RAISE INFO '[ % ] Archived cdr_audit_evt_target_user upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_target_user_counter, cdr_audit_evt_target_user_pid_max);
        
        COMMIT;

        cdr_audit_evt_target_user_counter := cdr_audit_evt_target_user_counter + 10000;
    END LOOP;
    RAISE INFO '[ % ] Archived cdr_audit_evt_target_user upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_target_user_counter, cdr_audit_evt_target_user_pid_max);
    
    /* archive cdr_audit_evt_target_res */
    WHILE cdr_audit_evt_target_res_counter <= (cdr_audit_evt_target_res_pid_max + 10000) LOOP
        INSERT INTO cdr_audit_evt_target_res_archive
        SELECT
            *
        FROM
            cdr_audit_evt_target_res
        WHERE
            pid <= LEAST(cdr_audit_evt_target_res_counter, cdr_audit_evt_target_res_pid_max);

        DELETE FROM cdr_audit_evt_target_res
        WHERE pid <= LEAST(cdr_audit_evt_target_res_counter, cdr_audit_evt_target_res_pid_max);

        -- RAISE INFO '[ % ] Archived cdr_audit_evt_target_res upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_target_res_counter, cdr_audit_evt_target_res_pid_max);
        
        COMMIT;

        cdr_audit_evt_target_res_counter := cdr_audit_evt_target_res_counter + 10000;
    END LOOP;
    RAISE INFO '[ % ] Archived cdr_audit_evt_target_res upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_target_res_counter, cdr_audit_evt_target_res_pid_max);

    /* archive cdr_audit_evt */
    WHILE cdr_audit_evt_counter <= (cdr_audit_evt_pid_max + 10000) LOOP
        INSERT INTO cdr_audit_evt_archive
        SELECT
            *
        FROM
            cdr_audit_evt
        WHERE
            pid <= LEAST(cdr_audit_evt_counter, cdr_audit_evt_pid_max);

        DELETE FROM cdr_audit_evt
        WHERE pid <= LEAST(cdr_audit_evt_counter, cdr_audit_evt_pid_max);

        -- RAISE INFO '[ % ] Archived cdr_audit_evt upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_counter, cdr_audit_evt_pid_max);

        COMMIT;

        cdr_audit_evt_counter := cdr_audit_evt_counter + 10000;
    END LOOP;
    RAISE INFO '[ % ] Archived cdr_audit_evt upto pid: %', current_timestamp::timestamp(0), LEAST(cdr_audit_evt_counter, cdr_audit_evt_pid_max);


RAISE INFO '[ % ] Archive audit data upto date: %', current_timestamp::timestamp(0), archive_date::date;
END;
$$;
