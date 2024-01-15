/* 

Cleaning Data in SQL Queries

*/

SELECT * FROM [dbo].[NashvilleHousing]


-------------------------------------------------------------------------------------

--Standardize Date Format

--SELECT SaleDate,CAST(SaleDate as Date)  FROM [dbo].[NashvilleHousing]
SELECT SaleDateConverted,CONVERT(Date, SaleDate)  FROM [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 


-------------------------------------------------------------------------------------

--Populated Property Address data

SELECT * FROM [dbo].[NashvilleHousing] ORDER BY uNIQUEid


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress FROM [dbo].[NashvilleHousing] a
JOIN [NashvilleHousing] b ON a.ParcelID= b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

SELECT * FROM [dbo].[NashvilleHousing] a
JOIN [NashvilleHousing] b ON a.ParcelID= b.ParcelID
AND a.UniqueID <> b.UniqueID

update a
set PropertyAddress = isnull( a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.ParcelID= b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null



-------------------------------------------------------------------------------------


--Breaking out Address into Individual Columns (Address, City, State)


SELECT * from PortfolioProject.dbo.NashvilleHousing
SELECT PropertyAddress from PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS ADDRESS

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(155)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(155)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),1) ,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(155)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(155)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(155)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



----------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
FROM NashvilleHousing
GROUP BY SOLDASVACANT
ORDER BY 2


SELECT SOLDASVACANT,
	CASE
		WHEN SOLDASVACANT = 'Y' THEN 'YES'
		WHEN SOLDASVACANT = 'N' THEN 'NO'
		ELSE SOLDASVACANT
	END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SOLDASVACANT = 
	CASE
		WHEN SOLDASVACANT = 'Y' THEN 'YES'
		WHEN SOLDASVACANT = 'N' THEN 'NO'
		ELSE SOLDASVACANT
	END



-----------------------------------------------------------------------------------------------------------


--Remove Duplicates

select * from NashvilleHousing


WITH RowNumCte AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
    FROM NashvilleHousing
)

--DELETE
SELECT *
FROM RowNumCte
WHERE row_num > 1;


--------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT * From NashvilleHousing

Alter table NashvilleHousing
drop column ownerAddress, TaxDistrict, PropertyAddress


Alter table NashvilleHousing
drop column SaleDate