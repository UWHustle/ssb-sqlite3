CREATE TABLE bf_date AS
SELECT bloom(d_datekey, 10000)
FROM date
WHERE d_weeknuminyear = 6
  AND d_year = 1994;

SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder,
     date
WHERE lo_orderdate = d_datekey
  AND d_weeknuminyear = 6
  AND d_year = 1994
  AND lo_discount BETWEEN 5 AND 7
  AND lo_quantity BETWEEN 36 AND 40;

DROP TABLE bf_date;
