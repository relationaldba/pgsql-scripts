SELECT
       usename,
       useconfig
FROM
       pg_shadow;

SELECT
       coalesce(role.rolname, 'database wide') AS role,
       coalesce(db.datname, 'cluster wide') AS database,
       setconfig AS what_changed
FROM
       pg_db_role_setting role_setting
       LEFT JOIN pg_roles ROLE ON role.oid = role_setting.setrole
       LEFT JOIN pg_database db ON db.oid = role_setting.setdatabase;


/* Role specific settings */
SELECT
       *
FROM
       pg_catalog.pg_shadow;


/* Role specific settings */
SELECT
       coalesce(rl.rolname, 'database wide') AS role,
       coalesce(db.datname, 'cluster wide') AS database,
       setconfig AS what_changed
FROM
       pg_db_role_setting AS rs
       LEFT JOIN pg_roles AS rl ON rl.oid = rs.setrole
       LEFT JOIN pg_database AS db ON db.oid = rs.setdatabase;


/* List all the database users and roles along with a list of roles that have been granted to them */
SELECT
       r.rolname,
       ARRAY (
              SELECT
                     b.rolname
              FROM
                     pg_catalog.pg_auth_members m
                     JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
              WHERE
                     m.member = r.oid) AS memberof
FROM
       pg_catalog.pg_roles r
WHERE
       r.rolname NOT IN ('pg_signal_backend', 'rds_iam', 'rds_replication', 'rds_superuser', 'rdsadmin', 'rdsrepladmin')
ORDER BY
       1;

