DO $$
DECLARE
    var_counter int = 1;
BEGIN
    DROP TABLE IF EXISTS table_relationship, migrate_order;
    CREATE TEMP TABLE table_relationship(
        parent_table_name varchar(128 ),
        foreign_table_name varchar(128 )
    );
    CREATE TEMP TABLE migrate_order(
        id int,
        parent_table_name varchar(128 )
    );
INSERT INTO table_relationship(parent_table_name, foreign_table_name)
SELECT
    t.table_name AS parent_table_name,
    ccu.table_name AS foreign_table_name
FROM
    information_schema.tables t
    LEFT JOIN information_schema.table_constraints AS tc ON t.table_schema = tc.table_schema
        AND t.table_name = tc.table_name
        AND t.table_schema = 'rpcspine'
        AND tc.constraint_type = 'FOREIGN KEY'
    LEFT JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    LEFT JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
WHERE
    t.table_schema = 'rpcspine';
    LOOP
        INSERT INTO migrate_order SELECT DISTINCT
            var_counter,
            parent_table_name
        FROM
            table_relationship
        WHERE
            foreign_table_name IS NULL
            AND parent_table_name NOT IN (
                SELECT
                    parent_table_name
                FROM
                    migrate_order)
            AND parent_table_name NOT IN (
                SELECT
                    parent_table_name
                FROM
                    table_relationship
                WHERE
                    foreign_table_name IS NOT NULL);
        UPDATE
            table_relationship
        SET
            foreign_table_name = NULL
        WHERE
            foreign_table_name IN (
                SELECT
                    parent_table_name
                FROM
                    migrate_order);
        var_counter = var_counter + 1;
        EXIT
        WHEN (
                SELECT
                    COUNT(DISTINCT parent_table_name)
                FROM
                    table_relationship) =(
                SELECT
                    COUNT(DISTINCT parent_table_name)
                FROM
                    migrate_order);
    END LOOP;
END
$$;

SELECT
    *
FROM
    migrate_order
ORDER BY
    id;

