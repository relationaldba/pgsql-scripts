--GRANT ALL permissions
GRANT ALL ON DATABASE < mydb > TO < user_name >;

--Schema
GRANT ALL ON SCHEMA public TO < user_name >;

--TABLES
GRANT ALL ON ALL TABLES IN SCHEMA public TO < user_name >;

--SEQUENCES
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO < user_name >;

--FUNCTIONS
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO < user_name >;

---------------------
---------------------
--CONNECT permission
GRANT CONNECT ON DATABASE < mydb > TO < user_name >;

--USAGE
GRANT USAGE ON SCHEMA public TO < user_name >;

--TABLES
GRANT SELECT ON ALL TABLES IN SCHEMA public TO < user_name >;

GRANT INSERT ON ALL TABLES IN SCHEMA public TO < user_name >;

GRANT UPDATE ON ALL TABLES IN SCHEMA public TO < user_name >;

GRANT DELETE ON ALL TABLES IN SCHEMA public TO < user_name >;

--SEQUENCES
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO < user_name >;

GRANT UPDATE ON ALL SEQUENCES IN SCHEMA public TO < user_name >;

--FUNCTIONS
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO < user_name >;

--DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES FOR USER < owner_name > IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO < user_name >;

ALTER DEFAULT PRIVILEGES FOR USER < owner_name > IN SCHEMA public 
GRANT SELECT, UPDATE, USAGE ON SEQUENCES TO < user_name >;

ALTER DEFAULT PRIVILEGES FOR USER < user_name > IN SCHEMA public 
GRANT EXECUTE ON FUNCTIONS TO < user_name >;

--REVOKE
REVOKE ALL PRIVILEGES ON DATABASE < mydb > FROM < user_name >;

REVOKE ALL PRIVILEGES ON SCHEMA public FROM < user_name >;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM < user_name >;

REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM < user_name >;

REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM < user_name >;

