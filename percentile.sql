
select
  percentile_cont(0.25) within group (order by len asc)::int4 as percentile_25,
  percentile_cont(0.50) within group (order by len asc)::int4 as percentile_50,
  percentile_cont(0.75) within group (order by len asc)::int4 as percentile_75,
  percentile_cont(0.95) within group (order by len asc)::int4 as percentile_95,
  percentile_cont(0.99) within group (order by len asc)::int4 as percentile_99,
  max(len) as max
from (
    SELECT oid, length(lo_get(oid)::text) as len
    FROM pg_largeobject_metadata
    LIMIT 1000
) as percentiles;



select
  percentile_cont(0.25) within group (order by length(lo_get(oid)::text) asc) as percentile_25,
  percentile_cont(0.50) within group (order by length(lo_get(oid)::text) asc) as percentile_50,
  percentile_cont(0.75) within group (order by length(lo_get(oid)::text) asc) as percentile_75,
  percentile_cont(0.95) within group (order by length(lo_get(oid)::text) asc) as percentile_95,
  percentile_cont(0.99) within group (order by length(lo_get(oid)::text) asc) as percentile_99,
  max(length(lo_get(oid)::text)) as max
from pg_largeobject_metadata;

