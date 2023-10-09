--Replace the user_name with the actual user name that needs to be dropped.
--Replace the database_name with the database name from where the permission needs to be revoked
--Connect to the database from where the permission needs to be revoked
\c database_name
--Revoke ALL access of user role
SET ROLE postgres;

--DATABASE
REVOKE ALL ON DATABASE database_name FROM user_name;

--USAGE
REVOKE ALL ON SCHEMA public FROM user_name;

--TABLES
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM user_name;

--SEQUENCES
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM user_name;

--FUNCTIONS
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM user_name;

--DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public REVOKE ALL ON TABLES FROM user_name;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public REVOKE ALL ON SEQUENCES FROM user_name;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public REVOKE ALL ON FUNCTIONS FROM user_name;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public REVOKE ALL ON TYPES FROM user_name;

--Reassign objects owned by role to postgres
SET ROLE postgres;

GRANT user_name TO postgres;

REASSIGN OWNED BY user_name TO postgres;

--Drop role
SET ROLE postgres;

DROP USER user_name;

