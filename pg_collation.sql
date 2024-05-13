-- Get collation and type
SHOW LC_COLLATE;

SHOW LC_CTYPE;

-- Get all collation settings
SELECT
   *
FROM
   pg_settings
WHERE
   name LIKE 'lc%';

-- Get collation of all columns in a relation
WITH defcoll AS (
   SELECT
      datcollate AS coll
   FROM
      pg_database
   WHERE
      datname = current_database())
SELECT
   a.attname,
   CASE WHEN c.collname = 'default' THEN
      defcoll.coll
   ELSE
      c.collname
   END AS collation
FROM
   pg_attribute AS a
   CROSS JOIN defcoll
   LEFT JOIN pg_collation AS c ON a.attcollation = c.oid
WHERE
   a.attrelid = 'cstm.stage_komig_master'::regclass
   AND a.attnum > 0
ORDER BY
   attnum;

-- Get collation of all columns in an index
WITH defcoll AS (
   SELECT
      datcollate AS coll
   FROM
      pg_database
   WHERE
      datname = current_database())
SELECT
   a.attname,
   CASE WHEN c.collname = 'default' THEN
      defcoll.coll
   ELSE
      c.collname
   END AS collation
FROM
   pg_attribute AS a
   CROSS JOIN defcoll
   LEFT JOIN pg_collation AS c ON a.attcollation = c.oid
WHERE
   a.attrelid = 'idx_sp_string_hash_nrm_v2'::regclass
   AND a.attnum > 0
ORDER BY
   attnum;

-- Get collation of all columns in an index
WITH defcoll AS (
   SELECT
      datcollate AS coll
   FROM
      pg_database
   WHERE
      datname = current_database())
SELECT
   icol.pos,
   CASE WHEN c.collname = 'default' THEN
      defcoll.coll
   ELSE
      c.collname
   END AS collation
FROM
   pg_index AS i
   CROSS JOIN unnest(i.indcollation)
   WITH ORDINALITY AS icol(coll, pos)
   CROSS JOIN defcoll
   LEFT JOIN pg_collation AS c ON c.oid = icol.coll
WHERE
   i.indexrelid = 'idx_sp_string_hash_nrm_v2'::regclass
ORDER BY
   icol.pos;

