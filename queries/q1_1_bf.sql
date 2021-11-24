CREATE TABLE bf_date AS
SELECT bloom(d_datekey, 10000)
FROM date
WHERE d_year = 1993;

SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder,
     date
WHERE lo_orderdate = d_datekey
  AND d_year = 1993
  AND lo_discount BETWEEN 1 AND 3
  AND lo_quantity < 25
  AND bloom_contains((SELECT * FROM bf_date), lo_orderdate);

DROP TABLE bf_date;
