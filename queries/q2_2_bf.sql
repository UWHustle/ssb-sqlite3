CREATE TABLE bf_part AS
SELECT bloom(p_partkey, 10000)
FROM part
WHERE p_brand1 BETWEEN 'MFGR#2221' AND 'MFGR#2228';

CREATE TABLE bf_supplier AS
SELECT bloom(s_suppkey, 10000)
FROM supplier
WHERE s_region = 'ASIA';

SELECT SUM(lo_revenue), d_year, p_brand1
FROM lineorder,
     date,
     part,
     supplier
WHERE lo_orderdate = d_datekey
  AND lo_partkey = p_partkey
  AND lo_suppkey = s_suppkey
  AND p_brand1 BETWEEN 'MFGR#2221' AND 'MFGR#2228'
  AND s_region = 'ASIA'
  AND bloom_contains((SELECT * FROM bf_part), lo_partkey)
  AND bloom_contains((SELECT * FROM bf_supplier), lo_suppkey)
GROUP BY d_year, p_brand1
ORDER BY d_year, p_brand1;

DROP TABLE bf_part;
DROP TABLE bf_supplier;
