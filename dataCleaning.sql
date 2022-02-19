SELECT *
FROM dbo.Housing;


--------


SELECT convert(date,h.SaleDate)
FROM dbo.Housing h;

update dbo.Housing
set SaleDate = convert(date,SaleDate)


ALTER TABLE dbo.housing ALTER COLUMN saledate DATE;

-- populate property address data

select * from dbo.Housing
where PropertyAddress is null

SELECT h.ParcelID, 
       h.PropertyAddress, 
       h2.ParcelID, 
       h2.PropertyAddress
FROM dbo.Housing h
     JOIN dbo.Housing h2 ON h.ParcelID = h2.ParcelID
                            AND h.[UniqueID ] <> h2.[UniqueID ]
                            AND h.PropertyAddress IS NULL;


UPDATE h
  SET PropertyAddress = h2.PropertyAddress
FROM dbo.Housing h
     JOIN dbo.Housing h2 ON h.ParcelID = h2.ParcelID
                            AND h.[UniqueID ] <> h2.[UniqueID ]
                            AND h.PropertyAddress IS NULL;


-- breaking out address into individual columns (address, city,state)

SELECT PropertyAddress, 
       RTRIM(LTRIM(SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress)))) AS Address, 
       RTRIM(LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(propertyaddress)))) AS City
FROM dbo.Housing;


ALTER TABLE dbo.housing add PropertySplitAddress nvarchar(255);
ALTER TABLE dbo.housing add PropertySplitCity nvarchar(255);

UPDATE dbo.Housing
  SET PropertySplitAddress = RTRIM(LTRIM(SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress))));
UPDATE dbo.Housing
  SET PropertySplitCity = RTRIM(LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(propertyaddress))));


SELECT OwnerAddress, 
       RTRIM(LTRIM(PARSENAME(replace(owneraddress, ',', '.'), 3))), 
       RTRIM(LTRIM(PARSENAME(replace(owneraddress, ',', '.'), 2))), 
       RTRIM(LTRIM(PARSENAME(replace(owneraddress, ',', '.'), 1)))
FROM dbo.Housing;


ALTER TABLE dbo.housing add OwnerSplitAddress nvarchar(255);
ALTER TABLE dbo.housing add OwnerSplitCity nvarchar(255);
ALTER TABLE dbo.housing add OwnerSplitState nvarchar(255);


UPDATE dbo.Housing
  SET OwnerSplitAddress = RTRIM(LTRIM(PARSENAME(replace(owneraddress, ',', '.'), 3)));
UPDATE dbo.Housing
  SET OwnerSplitCity =  RTRIM(LTRIM(PARSENAME(replace(owneraddress, ',', '.'), 2)));
UPDATE dbo.Housing
  SET OwnerSplitState = RTRIM(LTRIM(PARSENAME(replace(owneraddress, ',', '.'), 1)));

  select * from dbo.Housing


--

SELECT DISTINCT 
       SoldAsVacant, 
       COUNT(SoldAsVacant)
FROM dbo.Housing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'Y'
           THEN 'Yes'
           WHEN SoldAsVacant = 'N'
           THEN 'No'
           ELSE SoldAsVacant
       END
FROM dbo.Housing;

UPDATE dbo.Housing
  SET 
      SoldAsVacant = CASE
                         WHEN SoldAsVacant = 'Y'
                         THEN 'Yes'
                         WHEN SoldAsVacant = 'N'
                         THEN 'No'
                         ELSE SoldAsVacant
                     END;


-- remove duplicates

with rowNumCTE
as (
SELECT *, 
       ROW_NUMBER() OVER(PARTITION BY parcelid, 
                                      propertyaddress, 
                                      saleprice, 
                                      saledate, 
                                      legalreference
       ORDER BY uniqueid) AS row_num
FROM dbo.Housing)

DELETE FROM rowNumCTE
WHERE row_num > 1;


-- delete unused columns

SELECT *
FROM dbo.Housing;

ALTER TABLE dbo.housing DROP COLUMN owneraddress, taxdistrict, propertyaddress;










