CREATE DATABASE < database_name >;

CREATE ROLE < user_name > WITH LOGIN PASSWORD 'xxxx';

GRANT ALL ON DATABASE < database_name > TO < user_name >;

GRANT ALL ON SCHEMA public TO < user_name >;

GRANT ALL ON ALL TABLES IN SCHEMA public TO < user_name >;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO < user_name >;

GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO < user_name >;

GRANT < user_name > TO psqladmin;

REASSIGN OWNED BY psqladmin TO < user_name >;



--DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO < user_name >;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public
GRANT SELECT, UPDATE, USAGE ON SEQUENCES TO < user_name >;

ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public
GRANT EXECUTE ON FUNCTIONS TO < user_name >;