/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(SaleDate, Date)
From PortfolioProject.NashvilleHousing;


Update NashvilleHousing
SET SaleDate = CONVERT(SaleDate, Date);


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID;
-- Upon inspection we can see that PacelID and PropertyAddress are connected


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.NashvilleHousing a
JOIN PortfolioProject.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null;

Set SQL_SAFE_UPDATES=0;
Update PortfolioProject.NashvilleHousing a
Set PropertyAddress = (
  Select b.PropertyAddress
  From   (Select * From PortfolioProject.NashvilleHousing) as b
  Where  a.Parcelid = b.Parcelid
  And    a.Uniqueid <> b.Uniqueid
  And    b.PropertyAddress IS NOT NULL
  Limit 1
)
Where a.PropertyAddress IS NULL;
Set SQL_SAFE_UPDATES=1;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.NashvilleHousing;
-- Where PropertyAddress is null
-- Order by ParcelID

SELECT
SUBSTRING_INDEX(PropertyAddress, ',', +1 ) as Address
, SUBSTRING_INDEX(PropertyAddress, ',',-1 ) as Address
From PortfolioProject.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress VARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', +1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity VARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1 );




Select *
From PortfolioProject.NashvilleHousing;





Select OwnerAddress
From PortfolioProject.NashvilleHousing;


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.NashvilleHousing;



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

