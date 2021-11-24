CREATE TABLE bf_date AS
SELECT bloom(d_datekey, 10000)
FROM date
WHERE d_yearmonthnum = 199401;

SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder,
     date
WHERE lo_orderdate = d_datekey
  AND d_yearmonthnum = 199401
  AND lo_discount BETWEEN 4 AND 6
  AND lo_quantity BETWEEN 26 AND 35
  AND bloom_contains((SELECT * FROM bf_date), lo_orderdate);

DROP TABLE bf_date;
