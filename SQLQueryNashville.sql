--NAHVILLE HOUSING DATA
SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data

-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,[Sale Date])as Date
FROM PortfolioProject.dbo.Nashville_housing_data

Update Nashville_housing_data
SET [Sale Date] = CONVERT(Date,[Sale Date])

ALTER TABLE Nashville_housing_data
Add SaleDateConverted Date;

Update Nashville_housing_data
SET SaleDateConverted = CONVERT(Date,[Sale Date])
 

 --populate property address data

SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data 
--where [Property Address] is null
order by [Parcel ID]

--doing a self join

SELECT a.[Parcel ID], a.[Property Address], b.[Parcel ID], b.[Property Address], ISNULL(a.[Property Address],b.[Property Address])
FROM PortfolioProject.dbo.Nashville_housing_data a
JOIN PortfolioProject.dbo.Nashville_housing_data b 
ON a.[Parcel ID] = b.[Parcel ID]
AND a.[Unnamed: 0] <> b.[Unnamed: 0]
WHERE a.[Property Address] is null

UPDATE a 
SET [Property Address] = ISNULL(a.[Property Address],b.[Property Address])
FROM PortfolioProject.dbo.Nashville_housing_data a
JOIN PortfolioProject.dbo.Nashville_housing_data b 
ON a.[Parcel ID] = b.[Parcel ID]
AND a.[Unnamed: 0] <> b.[Unnamed: 0]
WHERE a.[Property Address] is null


-- Breaking out Adress into Individual Columns (Address, City, State)

SELECT [Property Address]
FROM PortfolioProject.dbo.Nashville_housing_data


--SUBSTRING(string, start, length)
--CHARINDEX(substring, string, start)

SELECT [Property Address], 
SUBSTRING([Property Address], 1, CHARINDEX('DR', [Property Address]))AS ADDRESS,
SUBSTRING([Property Address], CHARINDEX('M', [Property Address]) +1, LEN([Property Address]))AS ADDRESS2
FROM PortfolioProject.dbo.Nashville_housing_data


ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
Add PropertySplitAddress  NVARCHAR(255)

UPDATE PortfolioProject.dbo.Nashville_housing_data
SET PropertySplitAddress = SUBSTRING([Property Address], 1, CHARINDEX('DR', [Property Address]))

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
ADD PropertySplitCity  NVARCHAR(255);


UPDATE PortfolioProject.dbo.Nashville_housing_data
SET PropertySplitCity = SUBSTRING([Property Address], CHARINDEX('M', [Property Address]) +1, LEN([Property Address]))

SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data


SELECT [Owner Name] 
FROM PortfolioProject.dbo.Nashville_housing_data


--USING PARSENAME
SELECT [Owner Name], 
PARSENAME([Owner Name], 1) AS OTHENAME,
PARSENAME([Owner Name], 2) AS FIRSTNAME,
PARSENAME([Owner Name], 3) AS LASTNAME
FROM PortfolioProject.dbo.Nashville_housing_data

--USING REPLACE
SELECT [Owner Name], 
REPLACE([Owner Name], ',', '.')
FROM PortfolioProject.dbo.Nashville_housing_data


SELECT [Owner Name],
PARSENAME(REPLACE([Owner Name], ',', '.'), 1) AS OTHERNAME,
PARSENAME(REPLACE([Owner Name], ',', '.'), 2) AS FIRSTNAME,
PARSENAME(REPLACE([Owner Name], ',', '.'), 3) AS SURNAME
FROM PortfolioProject.dbo.Nashville_housing_data
WHERE [Owner Name] IS NOT NULL


--I can also do this
SELECT [Owner Name],
REPLACE([Owner Name], ',', '.') AS NewOwner
FROM PortfolioProject.dbo.Nashville_housing_data

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
ADD NewOwner NVARCHAR(255)

UPDATE PortfolioProject.dbo.Nashville_housing_data
SET NewOwner = REPLACE([Owner Name], ',', '.')


SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data

--gives same result
SELECT [NewOwner],
PARSENAME([NewOwner], 1) as OtherName,
PARSENAME([NewOwner], 2) as lastName,
PARSENAME([NewOwner], 3) as FirstName
FROM PortfolioProject.dbo.Nashville_housing_data


--change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct[Sold As Vacant], COUNT([Sold As Vacant]) as Vacant
FROM PortfolioProject.dbo.Nashville_housing_data
GROUP BY  [Sold As Vacant]
ORDER BY 1

SELECT [Sold As Vacant],
CASE 
	WHEN [Sold As Vacant] = 'Y' THEN 'Yes'
	WHEN [Sold As Vacant] = 'N' THEN 'NO'
	ELSE [Sold As Vacant]
	END
FROM PortfolioProject.dbo.Nashville_housing_data

--REMOVING DUPLICATE

WITH RowNumCTE AS(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY [Parcel ID],[Property Address],[Sale Price], [Sale Date], [Legal Reference]
	ORDER BY [Unnamed: 0])row_num
					
FROM PortfolioProject.dbo.Nashville_housing_data
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY [Parcel ID]

SELECT *
FROM PortfolioProject.dbo.Nashville_housing_data

ALTER TABLE PortfolioProject.dbo.Nashville_housing_data
DROP COLUMN [Address], [Tax District], [Property Address]