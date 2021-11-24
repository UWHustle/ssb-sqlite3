CREATE TABLE bf_customer AS
SELECT bloom(c_custkey, 10000)
FROM customer
WHERE c_region = 'ASIA';

CREATE TABLE bf_supplier AS
SELECT bloom(s_suppkey, 10000)
FROM supplier
WHERE s_region = 'ASIA';

CREATE TABLE bf_date AS
SELECT bloom(d_datekey, 10000)
FROM date
WHERE d_year >= 1992
  AND d_year <= 1997;

SELECT c_nation, s_nation, d_year, SUM(lo_revenue) AS revenue
FROM customer,
     lineorder,
     supplier,
     date
WHERE lo_custkey = c_custkey
  AND lo_suppkey = s_suppkey
  AND lo_orderdate = d_datekey
  AND c_region = 'ASIA'
  AND s_region = 'ASIA'
  AND d_year >= 1992
  AND d_year <= 1997
  AND bloom_contains((SELECT * FROM bf_customer), lo_custkey)
  AND bloom_contains((SELECT * FROM bf_supplier), lo_suppkey)
  AND bloom_contains((SELECT * FROM bf_date), lo_orderdate)
GROUP BY c_nation, s_nation, d_year
ORDER BY d_year ASC, revenue DESC;

DROP TABLE bf_customer;
DROP TABLE bf_supplier;
DROP TABLE bf_date;
