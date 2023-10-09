
SELECT DISTINCT tablename,
                grantor,
                grantee,
                string_agg(privilege_type, ', ') AS privileges
FROM pg_tables AS t
LEFT OUTER JOIN information_schema.role_table_grants g ON g.table_name = t.tablename
WHERE grantee = '<role_name>'
GROUP BY tablename,
         grantor,
         grantee
order by tablename;

---------------------------------------------------

SELECT table_catalog,
       table_schema,
       table_name,
       privilege_type
FROM information_schema.table_privileges
WHERE grantee = '<role_name>';
