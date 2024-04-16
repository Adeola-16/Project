--North Wind Project------

--Task 1----

---The company wants to reward its Sales Representatives staff only. For this to happen, 
--we would need to know the staff name, the total amount of money the staff has handled during 
--a customer transaction and the department this staff belongs to. (Remember, we want just the sales Rep staff).

---Please, help the Finance department to generate a summary table that shows the full name 
--(last + first name combined), the total amount of transaction, and the title of these employees.

--Put this output in a view.


SELECT (LastName || ' ' || FirstName) AS Staff_Name,
ROUND(SUM(((UnitPrice * Quantity)*(1-Discount)))::NUMERIC,2) AS Total_Revenue,
titleofcourtesy AS Employee_Title
FROM Employees AS emp
LEFT JOIN Orders AS o
USING (EmployeeID)
LEFT JOIN Order_Details AS ord
USING (OrderID)
WHERE title = 'Sales Representative'
GROUP BY EmployeeID
ORDER BY 2 DESC;

--CREATE VIEW FOR THE FINANCE DEPARTMENT TO SEE THE SUMMARY OF SALES REP STAFF

CREATE VIEW sales_rep AS 
(
SELECT (LastName || ' ' || FirstName) AS Staff_Name,
ROUND(SUM(((UnitPrice * Quantity)*(1-Discount)))::NUMERIC,2) AS Total_Revenue,
titleofcourtesy AS Employee_Title
FROM Employees AS emp
LEFT JOIN Orders AS o
USING (EmployeeID)
LEFT JOIN Order_Details AS ord
USING (OrderID)
WHERE title = 'Sales Representative'
GROUP BY EmployeeID
ORDER BY 2 DESC
);

SELECT *
FROM sales_rep;

--Task 2---

--The board of directors are interested in seeing the volume of transactions this business has made. 
--your mission: In the operation year, give a breakdown of the total number of orders by year and by month.

SELECT COUNT(orderid) AS Total_Order, 
EXTRACT(YEAR FROM orderdate) AS Year, 
TO_CHAR(orderdate, 'Month') AS Month,
EXTRACT(MONTH FROM orderdate) AS Month_No
FROM Orders
GROUP BY 2,3,4
ORDER BY 2,4 ASC;

--TOTAL TRANSACTION BY YEAR

SELECT COUNT(orderid) AS Total_Order, EXTRACT(YEAR FROM orderdate) AS "Year of transaction"
FROM orders
GROUP BY 2

--TOTAL TRANSACTION BY MONTH

SELECT COUNT(orderid) AS Total_Order, 
TO_CHAR(orderdate,'Month') AS "Months of Transaction",
EXTRACT(MONTH FROM orderdate) AS "Month_no"
FROM orders
GROUP BY 2,3
ORDER BY 3


--Task 3:

--The company is doing well in terms of revenue. 
--The directors are planning to expand their customer base in some countries. 
--Generate a ranked table from the customers table that displays the 
--customer id, company name, city, country, total quantity, and the ranked value.
--This rank table should be partitioned by country.

SELECT c.CustomerID, CompanyName, City, Country, COUNT(orderid) AS Total_Qty,
RANK () OVER (PARTITION BY Country ORDER BY quantity) AS Rank_No
FROM customers c
LEFT JOIN orders o
USING (CustomerID)
LEFT JOIN order_details AS ord
USING (OrderID)
GROUP BY 1,ord.quantity


--Task 4:

--There have been some concerns with some of our suppliers. 
--The management would like to know the MVP (most valuable players) suppliers and the ones that can be replaced.
--Return a table that shows the name of the company, the contact’s name and the average quantity these companies have done for the company.

SELECT companyname, contactname, COUNT (ProductID) Qty_Supplied
FROM suppliers s
LEFT JOIN products p
USING (SupplierID)
GROUP BY SupplierID
ORDER BY 3 DESC;


