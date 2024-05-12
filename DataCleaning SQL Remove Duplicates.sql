--Data cleaning - Removing duplicates 

SELECT *
FROM sales1

--Create a CTE with a Row_Number to identify the duplicates

WITH CTE_duplicate AS
(
	SELECT *,
	(ROW_NUMBER () OVER (PARTITION BY sales_id ORDER BY sales_id))AS Row_No
	FROM sales1
) 
SELECT *
FROM CTE_duplicate
WHERE Row_No > 1

--Create a new table with the CTE created

CREATE TABLE sales1fixed AS 
(
	WITH CTE_duplicate AS
(
	SELECT *,
	(ROW_NUMBER () OVER (PARTITION BY sales_id ORDER BY sales_id))AS Row_No
	FROM sales1
) 
SELECT *
FROM CTE_duplicate
WHERE Row_No > 1
)

--Drop the table sales1 and column name row_no in the new table sales1fixed

DROP TABLE sales1

ALTER TABLE sales1fixed
DROP COLUMN row_no

--you can rename the table sales1fixed to sales1

ALTER TABLE sales1fixed 
RENAME TO sales1

--Chect the table to be sure you are fine

SELECT *
FROM sales1