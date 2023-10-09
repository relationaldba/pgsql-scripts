-- List Foreign Keys of mytable
SELECT
    tc.table_schema, 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name='mytable';



-- Get the script of the FK constraint
SELECT
    connamespace::regnamespace "Schema",
    conrelid::regclass "Table",
    conname "Constraint",
    pg_get_constraintdef(oid) "Definition",
    format('ALTER TABLE %I.%I ADD CONSTRAINT %I %s;', connamespace::regnamespace, conrelid::regclass, conname, pg_get_constraintdef(oid)),
    *
FROM
    pg_constraint
WHERE
    conname IN ('fk_reslink_target');

