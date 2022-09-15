

-- Cleaning Data in SQL Project

Select *
from PortfolioProject.dbo.NashvilleHousingProject


---------------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format

Select SaleDateConverted, Convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousingProject

Update NashvilleHousingProject
Set SaleDate = Convert(date, SaleDate)

Alter table NashvilleHousingProject
Add SaleDateConverted Date

Update NashvilleHousingProject
Set SaleDateConverted = Convert(date, SaleDate)


---------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address Data

Select *
from PortfolioProject.dbo.NashvilleHousingProject
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingProject a
Join PortfolioProject.dbo.NashvilleHousingProject b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingProject a
Join PortfolioProject.dbo.NashvilleHousingProject b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------


-- Breaking Out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousingProject

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousingProject
 
 
 Alter table NashvilleHousingProject
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousingProject
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


 Alter table NashvilleHousingProject
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousingProject
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

 -- Checking after making the above changes. The new columns should appear at the very last. 

Select *
from PortfolioProject.dbo.NashvilleHousingProject






-- Breaking Out Owner Address into Individual Columns(Address, City, State) using PARSENAME 
-- Parsename is an easier approach than using a substring, but it only works with period(.) and not with a comma( ,)
-- hence, we will be replacing , with a . and then use parsename. Parsename works backwards. 

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousingProject

Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousingProject


-- Adding these new columns and updating values into them, just as we did before

 Alter table NashvilleHousingProject
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousingProject
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)


 Alter table NashvilleHousingProject
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousingProject
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)


 Alter table NashvilleHousingProject
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousingProject
Set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


Select *
from PortfolioProject.dbo.NashvilleHousingProject


---------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousingProject
group by SoldAsVacant
order by 2


Select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'YES'
      when SoldAsVacant = 'N' then 'NO'
	  else SoldAsVacant
	  end
from PortfolioProject.dbo.NashvilleHousingProject


-- Updating using the Case when Statement 

Update NashvilleHousingProject
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
      when SoldAsVacant = 'N' then 'NO'
	  else SoldAsVacant
	  end


---------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates

-- Using CTEs and Rownum to find duplicates


Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousingProject
order by ParcelID


-- Now In the above query, just pulling all the duplicate records ONLY, using CTE

With RownumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousingProject
--order by ParcelID
)
Select *
from RownumCTE
where row_num > 1
order by PropertyAddress


-- Query to Delete the above Duplicate Rows

With RownumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousingProject
--order by ParcelID
)
Delete
from RownumCTE
where row_num > 1
--order by PropertyAddress


-- Checking for duplicates again if there are any, after deleting them.

With RownumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousingProject
--order by ParcelID
)
Select *
from RownumCTE
where row_num > 1
order by PropertyAddress



---------------------------------------------------------------------------------------------------------------------------------



-- Delete Unused Columns

Select *
from PortfolioProject.dbo.NashvilleHousingProject

Alter Table PortfolioProject.dbo.NashvilleHousingProject
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousingProject
Drop Column SaleDate