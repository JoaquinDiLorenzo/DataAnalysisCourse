-- CLEANING DATA
Select *
From PortfolioProject..NashvilleHousing

-- Standarize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Adress data
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- All the rows with same ParcelID has the same PropertyAdress, so we have to populate it
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Adress into Individual Columns (Address,City,State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- Another way to do it
Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject..NashvilleHousing
WHERE OwnerAddress is not null

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select *
From PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE  When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE  When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


-- Remove duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY ParcelID) row_num
From PortfolioProject..NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate


