--Sales_Data
SELECT
	CAST(SUBSTRING(SalesOrderNumber, 3, LEN(SalesOrderNumber)) AS int) * 1000 + SalesOrderLineNumber AS SalesOrderLineKey,
	-1 AS ResellerKey,
	CustomerKey,
	ProductKey,
	OrderDateKey,
	DueDateKey,
	ShipDateKey,
	SalesTerritoryKey,
	OrderQuantity,
	UnitPrice,
	ExtendedAmount,
	UnitPriceDiscountPct,
	ProductStandardCost,
	TotalProductCost,
	SalesAmount
FROM FactInternetSales
UNION ALL
SELECT
	CAST(SUBSTRING(SalesOrderNumber, 3, LEN(SalesOrderNumber)) AS int) * 1000 + SalesOrderLineNumber AS SalesOrderLineKey,
	ResellerKey,
	-1 AS CustomerKey,
	ProductKey,
	OrderDateKey,
	DueDateKey,
	ShipDateKey,
	SalesTerritoryKey,
	OrderQuantity,
	UnitPrice,
	ExtendedAmount,
	UnitPriceDiscountPct,
	ProductStandardCost,
	TotalProductCost,
	SalesAmount
FROM FactResellerSales;

--SalesOrder_Data
SELECT
	'Reseller' AS Channel,
	CAST(SUBSTRING(SalesOrderNumber, 3, LEN(SalesOrderNumber)) AS int) * 1000 + SalesOrderLineNumber AS SalesOrderLineKey,
	SalesOrderNumber
FROM FactResellerSales
UNION ALL
SELECT
	'Internet' AS Channel,
	CAST(SUBSTRING(SalesOrderNumber, 3, LEN(SalesOrderNumber)) AS int) * 1000 + SalesOrderLineNumber AS SalesOrderLineKey,
	SalesOrderNumber
FROM FactInternetSales;

--SalesTerritory_Data
SELECT
	SalesTerritoryKey,
	SalesTerritoryRegion AS [Region],
	SalesTerritoryCountry AS [Country],
	SalesTerritoryGroup AS [Group]
FROM DimSalesTerritory;

--Reseller_Data
SELECT
	ResellerKey,
	BusinessType,
	ResellerName,
	DimGeography.City,
	DimGeography.StateProvinceName AS [State-Province],
	DimGeography.EnglishCountryRegionName AS [Country-Region],
	DimGeography.PostalCode
FROM DimReseller
LEFT JOIN
	DimGeography ON DimReseller.GeographyKey = DimGeography.GeographyKey
UNION ALL
SELECT 
	-1 AS ResellerKey, 
	NULL AS [BusinessType], 
	NULL AS ResellerName, 
	NULL AS City, 
	NULL AS [State-Province], 
	NULL AS [Country-Region], 
	NULL AS [PostalCode]
ORDER BY ResellerKey ASC;

--Date_data
SELECT 
    DateKey,
    CONVERT(varchar, MONTH(FullDateAlternateKey)) + '/' + CONVERT(varchar, DAY(FullDateAlternateKey)) + '/' + CONVERT(varchar, YEAR(FullDateAlternateKey)) AS [Date],
    'FY' + CONVERT(varchar, FiscalYear + CASE WHEN MONTH(FullDateAlternateKey) >= 7 THEN 1 ELSE 0 END) AS [Fiscal Year],
    'FY' + CONVERT(varchar, FiscalYear + CASE WHEN MONTH(FullDateAlternateKey) >= 7 THEN 1 ELSE 0 END) + ' Q' + CONVERT(varchar, FiscalQuarter) AS [Fiscal Quarter],
    CONVERT(varchar, YEAR(FullDateAlternateKey)) + ' ' + CONVERT(varchar, DATENAME(MONTH, FullDateAlternateKey)) AS [Month],
    CONVERT(varchar, FullDateAlternateKey, 20) AS [Full Date],
    CONVERT(varchar, Year(FullDateAlternateKey)) + RIGHT('0' + CONVERT(varchar, Month(FullDateAlternateKey)), 2) AS [MonthKey]
FROM DimDate;

--Product_Data
SELECT
	p.ProductKey,
	p.ProductAlternateKey AS SKU,
	p.EnglishProductName AS Product,
	p.StandardCost,
	p.Color,
	p.ListPrice,
	p.ModelName AS Model,
	sc.EnglishProductSubcategoryName AS Subcategory,
	c.EnglishProductCategoryName
FROM DimProduct p
LEFT JOIN DimProductSubcategory sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey 
LEFT JOIN DimProductCategory c ON sc.ProductCategoryKey = c.ProductCategoryKey
WHERE p.ProductSubcategoryKey IS NOT NULL;

--Customer_data
SELECT
	c.CustomerKey,
	c.FirstName + ' ' + c.LastName AS Customer,
	g.City,
	g.StateProvinceName AS [State-Province],
	g.EnglishCountryRegionName AS [Country-Region],
	g.PostalCode
FROM DimCustomer c
LEFT JOIN DimGeography g ON c.GeographyKey = g.GeographyKey;
