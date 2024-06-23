/*Data Cleaning Project */

---------------------------------------------------------------------------------------------------------------
-- Please note that standard practise is not to delete from database or a table.
-- In this project, you can use a temp table to perform the task.
--1. Standardization of the data format for saledate column
--2. Populate the missing or null property address column
--3. Breaking out the address column into individual columns (Address, City, State)
--4. Change Y and N values to Yes and No in the "Sold as Vacant" column
--5. Remove duplicates
--6. Delete unused columns. 
---------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS nashville_cleaned;
CREATE TABLE nashville_cleaned AS
(
	SELECT * FROM nashvillehousing
);

----------------------------------------------------------------------------------------------------------------
-- 1. STANDARDIZATION OF DATE 

SELECT saledate, DATE(saledate) AS saledate_converted
FROM nashville_cleaned;

UPDATE nashville_cleaned
SET saledate = DATE(saledate)

-- Unable to populate the saledate column with the converted saledate, hence we add new column
	
ALTER TABLE nashville_cleaned
ADD COLUMN saledate_converted DATE

UPDATE nashville_cleaned
SET saledate_converted = DATE(saledate)

--2. POPULATE THE MISSING OR NULL VALUES IN THE PROPERTY ADDRESS COLUMN
SELECT *
FROM nashville_cleaned
WHERE propertyaddress IS NULL

-- Observation shows that the missing values can be gotten from other property address with the same parcelid

-- Joing the table to itself can reveal the missing values

SELECT n1.parcelid,n1.propertyaddress,
		n2.parcelid,n2.propertyaddress,COALESCE(n1.propertyaddress,n2.propertyaddress) AS missing_address
FROM nashville_cleaned n1
JOIN nashville_cleaned n2
ON n1.parcelid = n2.parcelid
WHERE n1.uniqueid != n2.uniqueid
AND n1.propertyaddress IS NULL
ORDER BY 1

-- Update the property address for the missing values
UPDATE nashville_cleaned
SET propertyaddress = COALESCE(n1.propertyaddress,n2.propertyaddress)
						FROM nashville_cleaned n1
						JOIN nashville_cleaned n2
						ON n1.parcelid = n2.parcelid
						WHERE n1.uniqueid != n2.uniqueid
						AND n1.propertyaddress IS NULL


-- As a form of bonus, can we populate the missing values for owneraddress column and ownername?


--3. Breaking out the address column into individual columns (Address, City, State)
	
-- We have two different address columns, propertyaddress and owneraddress

-- Starting off with propertyaddress,

-- Using Substring

SELECT propertyaddress, 
		SUBSTRING (propertyaddress FROM 1 FOR POSITION (',' IN propertyaddress)-1) AS Property_Split_Address,
		SUBSTRING (propertyaddress FROM (POSITION (',' IN propertyaddress)+1) FOR LENGTH (propertyaddress)) AS Property_Split_City
FROM nashville_cleaned


-- Using Split Part,

SELECT propertyaddress,
       SPLIT_PART(propertyaddress, ',', 1) AS Property_Split_Address,
       SPLIT_PART(propertyaddress, ',', 2) AS Property_Split_City
FROM nashville_cleaned;

-- Add new columns
ALTER TABLE nashville_cleaned
ADD COLUMN Property_Split_Address VARCHAR (100),
ADD COLUMN Property_Split_City VARCHAR(50)

-- Populate new column

UPDATE nashville_cleaned
SET Property_Split_Address = SPLIT_PART(propertyaddress, ',', 1),
	Property_Split_City = SPLIT_PART(propertyaddress, ',', 2);

-- Owneraddress

-- Using Substring

--Assignment

-- Using Split Part,

SELECT owneraddress,
       SPLIT_PART(owneraddress, ',', 1) AS Owner_Split_Address,
       SPLIT_PART(owneraddress, ',', 2) AS Owner_Split_City,
	   SPLIT_PART(owneraddress, ',', 3) AS Owner_Split_State
FROM nashville_cleaned;

-- ADD new columns

ALTER TABLE nashville_cleaned
ADD COLUMN Owner_Split_Address VARCHAR (100),
ADD COLUMN Owner_Split_City VARCHAR(50),
ADD COLUMN Owner_Split_State VARCHAR(4)

-- Populate new columns

UPDATE nashville_cleaned
SET Owner_Split_Address = SPLIT_PART(owneraddress, ',', 1),
	Owner_Split_City = SPLIT_PART(owneraddress, ',', 2),
	Owner_Split_State = SPLIT_PART(owneraddress, ',', 3)
	
--4. Change Y and N values to Yes and No in the "Sold as Vacant" column

SELECT DISTINCT(soldasvacant),COUNT(soldasvacant)
FROM nashville_cleaned
GROUP BY soldasvacant
ORDER BY 2

-- Using the case function

SELECT soldasvacant,
	CASE
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
	END AS soldasvacant_cleaned
FROM nashville_cleaned
	
-- Update the soldasvacant column

UPDATE nashville_cleaned
SET soldasvacant = CASE
					WHEN soldasvacant = 'Y' THEN 'Yes'
					WHEN soldasvacant = 'N' THEN 'No'
					ELSE soldasvacant
					END 
					
	
--5. Remove duplicates

WITH CTE_duplicate AS 
	(
SELECT uniqueid,parcelid,propertyaddress,saledate,saleprice,legalreference,
	ROW_NUMBER () OVER (PARTITION BY
						parcelid,
						propertyaddress,	
						saledate,
						saleprice,
						legalreference
						ORDER BY uniqueid
						) AS row_no
FROM nashville_cleaned
	)
SELECT *
FROM CTE_duplicate
WHERE row_no > 1
ORDER BY 2

-- 104 Duplicates exists

-- Next is to delete them

WITH duplicate1 AS 
	(
SELECT uniqueid,parcelid,propertyaddress,saledate,saleprice,legalreference,
	ROW_NUMBER () OVER (PARTITION BY
						parcelid,
						propertyaddress,	
						saledate,
						saleprice,
						legalreference
						ORDER BY uniqueid
						) AS row_no
FROM nashville_cleaned
	)
DELETE
FROM nashville_cleaned
WHERE uniqueid IN (SELECT uniqueid FROM duplicate1 WHERE row_no > 1)
	

--6. Delete unused columns. 
	
ALTER TABLE nashville_cleaned
DROP COLUMN propertyaddress, 
DROP COLUMN	saledate, 
DROP COLUMN	owneraddress

-- You can check the final outcome of your cleaned data. The cleaned data is more usable for analysis.
	
SELECT * FROM nashville_cleaned

-- Please note that you can do additional data cleaning as you desire, and when you do, kindly share on my github
-- https://github.com/Adeola-16/Project
-- Thank you! Data is life (:
