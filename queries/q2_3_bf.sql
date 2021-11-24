CREATE TABLE bf_part AS
SELECT bloom(p_partkey, 10000)
FROM part
WHERE p_brand1 = 'MFGR#2221';

CREATE TABLE bf_supplier AS
SELECT bloom(s_suppkey, 10000)
FROM supplier
WHERE s_region = 'EUROPE';

SELECT SUM(lo_revenue), d_year, p_brand1
FROM lineorder,
     date,
     part,
     supplier
WHERE lo_orderdate = d_datekey
  AND lo_partkey = p_partkey
  AND lo_suppkey = s_suppkey
  AND p_brand1 = 'MFGR#2221'
  AND s_region = 'EUROPE'
  AND bloom_contains((SELECT * FROM bf_part), lo_partkey)
  AND bloom_contains((SELECT * FROM bf_supplier), lo_suppkey)
GROUP BY d_year, p_brand1
ORDER BY d_year, p_brand1;

DROP TABLE bf_part;
DROP TABLE bf_supplier;
