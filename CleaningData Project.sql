--First Step is Exploing the data to start Cleaning up my Data
select * from PortfolioProject.dbo.[Nashvill Housing]

--Second Step is Standrizing Date Format
select SaleDate, Convert(Date,SaleDate)
from PortfolioProject.dbo.[Nashvill Housing]
ALTER TABLE [Nashvill Housing]
ALTER COLUMN SaleDate Date;

-- Third Step is Populate Property Address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashvill Housing] a
JOIN PortfolioProject.dbo.[Nashvill Housing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashvill Housing] a
JOIN PortfolioProject.dbo.[Nashvill Housing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

--Fourth Step is Breaking up Propert and Owner Address into Individual Coulmns (Address, City, State)
SELECT 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address1
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address2
From PortfolioProject.dbo.[Nashvill Housing]

USE PortfolioProject
Alter Table [Nashvill Housing]
Add  PropertySplitAddress Nvarchar(255);
UPDATE [Nashvill Housing]
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [Nashvill Housing]
Add PropertySplitCity Nvarchar(255);
UPDATE [Nashvill Housing]
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

-- Or using below optimized query instead of above query but if you wanted to Delete the PropertyAddress Column later it cant be deleted because the other columns will be dependent on it
--USE PortfolioProject;

---- Add computed column PropertySplitAddress and Add computed column PropertySplitCity
--ALTER TABLE [Nashvill Housing]
--ADD Property_SplitAddress AS (SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)) PERSISTED;

--ALTER TABLE [Nashvill Housing]
--ADD Property_SplitCity AS (SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) PERSISTED;

--ALTER TABLE [Nashvill Housing]
--DROP COLUMN PropertySplitAddress;
--ALTER TABLE [Nashvill Housing]
--DROP COLUMN PropertySplitCity;


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.[Nashvill Housing]

USE PortfolioProject
Alter Table [Nashvill Housing]
Add OwnerSplitAddress Nvarchar(255);
UPDATE [Nashvill Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table [Nashvill Housing]
Add OwnerSplitCity Nvarchar(255);
UPDATE [Nashvill Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table [Nashvill Housing]
Add OwnerSplitState Nvarchar(255);
UPDATE [Nashvill Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Fifth Step is changing N&Y to No&Yes in SoldAsVacant Column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[Nashvill Housing]
Group By SoldAsVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.[Nashvill Housing]
UPDATE [Nashvill Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END

--Sixth Step is to Remove the Duplicates
WITH ROW_NUM_CTE AS(
Select *,
   ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
                     ORDER BY UniqueID) row_num
From PortfolioProject.dbo.[Nashvill Housing])
--DELETE FROM ROW_NUM_CTE
--WHERE row_num>1
SELECT * FROM ROW_NUM_CTE
WHERE row_num>1


--Seventh Step is to Delete Unused Columns
ALTER TABLE PortfolioProject.dbo.[Nashvill Housing]
DROP COLUMN Property_SplitCity, Property_SplitAddress
ALTER TABLE PortfolioProject.dbo.[Nashvill Housing]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

