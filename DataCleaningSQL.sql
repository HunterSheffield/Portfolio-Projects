/*
Cleaning Data in SQL Queries
*/
SELECT 
  * 
FROM 
  PortfolioProject.dbo.NashvilleHousing -- Standardize Date Format(remove time)
Select 
  SaleDate, 
  CONVERT(DATE, SaleDate) 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
UPDATE 
  NashvilleHousing 
SET 
  SaleDate = CONVERT(DATE, SaleDate) -- If it doesn't Update properly
ALTER TABLE 
  NashvilleHousing 
ADD 
  SaleDateConverted Date;
UPDATE 
  NashvilleHousing 
SET 
  SaleDateConverted = CONVERT(Date, SaleDate);
ALTER TABLE 
  NashvilleHousing 
DROP 
  COLUMN SaleDate;
-- Populate Property Address data
SELECT 
  * 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
ORDER BY 
  ParcelID 
Select 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID, 
  b.PropertyAddress, 
  ISNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
FROM 
  PortfolioProject.dbo.NashvilleHousing a 
  JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID 
  AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE 
  a.PropertyAddress IS NULL 
UPDATE 
  a 
SET 
  PropertyAddress = ISNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
FROM 
  PortfolioProject.dbo.NashvilleHousing a 
  JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID 
  AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE 
  a.PropertyAddress IS NULL -- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
  * 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
SELECT 
  SUBSTRING(
    PropertyAddress, 
    1, 
    CHARINDEX(',', PropertyAddress)-1
  ) AS Address, 
  SUBSTRING(
    PropertyAddress, 
    CHARINDEX(',', PropertyAddress)+ 1, 
    LEN(PropertyAddress)
  ) AS City 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
ALTER TABLE 
  NashvilleHousing 
ADD 
  PropertySplitAddress NVARCHAR(255);
UPDATE 
  NashvilleHousing 
SET 
  PropertySplitAddress = SUBSTRING(
    PropertyAddress, 
    1, 
    CHARINDEX(',', PropertyAddress)-1
  ) 
ALTER TABLE 
  NashvilleHousing 
ADD 
  PropertyCity NVARCHAR(50);
UPDATE 
  NashvilleHousing 
SET 
  PropertyCity = SUBSTRING(
    PropertyAddress, 
    CHARINDEX(',', PropertyAddress)+ 1, 
    LEN(PropertyAddress)
  ) 
ALTER TABLE 
  NashvilleHousing 
DROP 
  COLUMN PropertyAddress;
SELECT 
  * 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
Select 
  OwnerAddress 
From 
  PortfolioProject.dbo.NashvilleHousing 
Select 
  PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    3
  ), 
  PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    2
  ), 
  PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    1
  ) 
From 
  PortfolioProject.dbo.NashvilleHousing 
ALTER TABLE 
  NashvilleHousing 
Add 
  OwnerSplitAddress Nvarchar(255);
Update 
  NashvilleHousing 
SET 
  OwnerSplitAddress = PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    3
  ) 
ALTER TABLE 
  NashvilleHousing 
Add 
  OwnerSplitCity Nvarchar(255);
Update 
  NashvilleHousing 
SET 
  OwnerSplitCity = PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    2
  ) 
ALTER TABLE 
  NashvilleHousing 
Add 
  OwnerSplitState Nvarchar(255);
Update 
  NashvilleHousing 
SET 
  OwnerSplitState = PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    1
  ) -- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT 
  Distinct(SoldAsVacant), 
  Count(SoldAsVacant) 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
GROUP BY 
  SoldAsVacant 
ORDER BY 
  2 
SELECT 
  SoldAsVacant, 
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
UPDATE 
  NashvilleHousing 
SET 
  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END -- Remove Duplicates
  WITH RowNumCTE AS (
    SELECT 
      *, 
      ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
        PropertySplitAddress, 
        SalePrice, 
        SaleDateConverted, 
        LegalReference 
        ORDER BY 
          UniqueID
      ) row_num 
    FROM 
      PortfolioProject.dbo.NashvilleHousing
  ) 
DELETE FROM 
  RowNumCTE 
WHERE 
  row_num > 1;
---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
SELECT 
  * 
FROM 
  PortfolioProject.dbo.NashvilleHousing 
ALTER TABLE 
  NashvilleHousing 
DROP 
  COLUMN TaxDistrict, 
  OwnerAddress