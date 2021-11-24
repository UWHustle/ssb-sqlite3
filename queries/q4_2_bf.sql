CREATE TABLE bf_customer AS
SELECT bloom(c_custkey, 10000)
FROM customer
WHERE c_region = 'AMERICA';

CREATE TABLE bf_supplier AS
SELECT bloom(s_suppkey, 10000)
FROM supplier
WHERE s_region = 'AMERICA';

CREATE TABLE bf_date AS
SELECT bloom(d_datekey, 10000)
FROM date
WHERE d_year = 1997
   OR d_year = 1998;

CREATE TABLE bf_part AS
SELECT bloom(p_partkey, 10000)
FROM part
WHERE p_mfgr = 'MFGR#1'
   OR p_mfgr = 'MFGR#2';

SELECT d_year,
       s_nation,
       p_category,
       SUM(lo_revenue - lo_supplycost) AS profit
FROM date,
     customer,
     supplier,
     part,
     lineorder
WHERE lo_custkey = c_custkey
  AND lo_suppkey = s_suppkey
  AND lo_partkey = p_partkey
  AND lo_orderdate = d_datekey
  AND c_region = 'AMERICA'
  AND s_region = 'AMERICA'
  AND (d_year = 1997 OR d_year = 1998)
  AND (p_mfgr = 'MFGR#1' OR p_mfgr = 'MFGR#2')
  AND bloom_contains((SELECT * FROM bf_customer), lo_custkey)
  AND bloom_contains((SELECT * FROM bf_supplier), lo_suppkey)
  AND bloom_contains((SELECT * FROM bf_date), lo_orderdate)
  AND bloom_contains((SELECT * FROM bf_part), lo_partkey)
GROUP BY d_year, s_nation, p_category
ORDER BY d_year, s_nation, p_category;

DROP TABLE bf_customer;
DROP TABLE bf_supplier;
DROP TABLE bf_date;
DROP TABLE bf_part;
