/*
Cleaning data in SQL Queries
*/

SELECT *
FROM ProjectDatabase..NashvilleHousing$

--Standardise Date Format

SELECT saledateconverted, convert(date, saledate)
FROM ProjectDatabase..NashvilleHousing$

update NashvilleHousing$ 
set SaleDate = convert(date, saledate)

alter table NashvilleHousing$
add saledateconverted date;

update NashvilleHousing$ 
set saledateconverted = convert(date, saledate)

--populate property address data

SELECT *
FROM ProjectDatabase..NashvilleHousing$
--where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectDatabase..NashvilleHousing$ a
join ProjectDatabase..NashvilleHousing$ b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectDatabase..NashvilleHousing$ a
join ProjectDatabase..NashvilleHousing$ b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking address into different columns


SELECT PropertyAddress
FROM ProjectDatabase..NashvilleHousing$

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address

FROM ProjectDatabase..NashvilleHousing$


alter table NashvilleHousing$
add PropertySplitAddress nvarchar(255);

update NashvilleHousing$ 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing$
add PropertySplitCity nvarchar(255);

update NashvilleHousing$ 
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


select *
FROM ProjectDatabase..NashvilleHousing$


select OwnerAddress
FROM ProjectDatabase..NashvilleHousing$


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectDatabase..NashvilleHousing$


alter table NashvilleHousing$
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing$ 
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing$
add OwnerSplitCity nvarchar(255);

update NashvilleHousing$ 
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing$
add OwnerSplitState nvarchar(255);

update NashvilleHousing$ 
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select *
FROM ProjectDatabase..NashvilleHousing$


--change Y and N to YES and No 

select distinct (SoldasVacant), count(SoldasVacant)
FROM ProjectDatabase..NashvilleHousing$
Group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 end
FROM ProjectDatabase..NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 end


-- remove duplicates 

with RowNumCTE as(
select *,
    ROW_NUMBER() OVER (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				    UniqueID
					) row_num

FROM ProjectDatabase..NashvilleHousing$
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--delete unused columns

select *
FROM ProjectDatabase..NashvilleHousing$

Alter table ProjectDatabase..NashvilleHousing$
Drop column OwnerAddress, TaxDistrict, PropertyAddress


Alter table ProjectDatabase..NashvilleHousing$
Drop column SaleDate



