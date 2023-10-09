/*
    Get the tables and their primary key columns
*/

SELECT t.table_schema, 
    t.table_name,
    t.table_type,
    tc.constraint_name,
    tc.constraint_type,
    STRING_AGG(ccu.column_name, ',') AS constraint_columns
FROM information_schema.tables AS t
LEFT JOIN information_schema.table_constraints AS tc
    ON t.table_name = tc.table_name
    AND t.table_schema = tc.table_schema
    AND tc.constraint_type = 'PRIMARY KEY'
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON tc.table_name = ccu.table_name
    AND tc.table_schema = ccu.table_schema
    AND tc.constraint_name = ccu.constraint_name
WHERE t.table_type = 'BASE TABLE'
AND t.table_schema = 'public'
--AND tc.table_name IS NULL  /* Uncomment to see tables missing PK */
GROUP BY t.table_schema, t.table_name, t.table_type, tc.constraint_name, tc.constraint_type;