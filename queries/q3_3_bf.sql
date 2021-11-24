CREATE TABLE bf_customer AS
SELECT bloom(c_custkey, 10000)
FROM customer
WHERE c_city = 'UNITED KI1'
   OR c_city = 'UNITED KI5';

CREATE TABLE bf_supplier AS
SELECT bloom(s_suppkey, 10000)
FROM supplier
WHERE s_city = 'UNITED KI1'
   OR s_city = 'UNITED KI5';

CREATE TABLE bf_date AS
SELECT bloom(d_datekey, 10000)
FROM date
WHERE d_year >= 1992
  AND d_year <= 1997;

SELECT c_city, s_city, d_year, SUM(lo_revenue) AS revenue
FROM customer,
     lineorder,
     supplier,
     date
WHERE lo_custkey = c_custkey
  AND lo_suppkey = s_suppkey
  AND lo_orderdate = d_datekey
  AND (c_city = 'UNITED KI1' OR c_city = 'UNITED KI5')
  AND (s_city = 'UNITED KI1' OR s_city = 'UNITED KI5')
  AND d_year >= 1992
  AND d_year <= 1997
  AND bloom_contains((SELECT * FROM bf_customer), lo_custkey)
  AND bloom_contains((SELECT * FROM bf_supplier), lo_suppkey)
  AND bloom_contains((SELECT * FROM bf_date), lo_orderdate)
GROUP BY c_city, s_city, d_year
ORDER BY d_year ASC, revenue DESC;

DROP TABLE bf_customer;
DROP TABLE bf_supplier;
DROP TABLE bf_date;
