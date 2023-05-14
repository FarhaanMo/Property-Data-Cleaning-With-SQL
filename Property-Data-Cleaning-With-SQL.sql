/*

Property Data Cleaning With SQL

*/


Select *
From DataCleaning.dbo.PropertyData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From DataCleaning.dbo.PropertyData


Update PropertyData
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE PropertyData
Add SaleDateConverted Date;

Update PropertyData
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From DataCleaning.dbo.PropertyData
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.PropertyData a
JOIN DataCleaning.dbo.PropertyData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.PropertyData a
JOIN DataCleaning.dbo.PropertyData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Splitting the Address into Individual Columns (Address, City, State)


Select PropertyAddress
From DataCleaning.dbo.PropertyData
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From DataCleaning.dbo.PropertyData


ALTER TABLE PropertyData
Add PropertySplitAddress Nvarchar(255);

Update PropertyData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PropertyData
Add PropertySplitCity Nvarchar(255);

Update PropertyData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From DataCleaning.dbo.PropertyData





Select OwnerAddress
From DataCleaning.dbo.PropertyData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From DataCleaning.dbo.PropertyData



ALTER TABLE PropertyData
Add OwnerSplitAddress Nvarchar(255);

Update PropertyData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PropertyData
Add OwnerSplitCity Nvarchar(255);

Update PropertyData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PropertyData
Add OwnerSplitState Nvarchar(255);

Update PropertyData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From DataCleaning.dbo.PropertyData




--------------------------------------------------------------------------------------------------------------------------


-- Changing Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaning.dbo.PropertyData
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From DataCleaning.dbo.PropertyData


Update PropertyData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DataCleaning.dbo.PropertyData
--order by ParcelID
)

--Delete
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From DataCleaning.dbo.PropertyData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From DataCleaning.dbo.PropertyData


ALTER TABLE DataCleaning.dbo.PropertyData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















