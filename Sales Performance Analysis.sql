-- This analysis evaluates the sales performance.
-- Key metrics
-- Total sales
-- Best-selling products
-- Product categories
-- Regional sales performance
-- Sales trends over time

-- Query 1: Total Sales by Year
-- This query calculates the total sales for each year based on SalesOrderHeader and SalesOrderDetail.
SELECT YEAR(ssoh.OrderDate) AS SalesYear, 
       SUM(ssoh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader ssoh
GROUP BY YEAR(ssoh.OrderDate)
ORDER BY SalesYear DESC
-- Note: It identifies the overall sales performance over time, which can be used for 
-- forecasting and setting future targets.

-- Query 2: Sales by Product Category
-- This query aggregates sales by ProductCategory, showing total revenue by category.
SELECT ppc.Name AS Category, 
       SUM(ssod.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail ssod
JOIN Production.Product pp ON ssod.ProductID = pp.ProductID
JOIN Production.ProductSubcategory pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
JOIN Production.ProductCategory ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
GROUP BY ppc.Name
ORDER BY TotalSales DESC
-- Note: It identifies which product categories are the highest revenue drivers.

-- Query 3: Sales by Product Subcategory
-- This query aggregates sales by ProductSubcategory, showing how subcategories contribute to overall sales.
SELECT ppsc.Name AS Subcategory, 
       SUM(ssod.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail ssod
JOIN Production.Product pp ON ssod.ProductID = pp.ProductID
JOIN Production.ProductSubcategory ppsc ON pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
GROUP BY ppsc.Name
ORDER BY TotalSales DESC
-- Note: Knowing which subcategories perform well will help refine inventory and promotional strategies.

-- Query 4: Top 5 Best-Selling Products
-- This query finds the top 5 best-selling products by quantity sold.
WITH BestSellingProducts AS (
    SELECT pp.ProductID, 
           pp.Name AS ProductName, 
           SUM(ssod.OrderQty) AS QuantitySold
    FROM Sales.SalesOrderDetail ssod
    JOIN Production.Product pp ON ssod.ProductID = pp.ProductID
    GROUP BY pp.ProductID, pp.Name
)
SELECT TOP 5 ProductName, QuantitySold
FROM BestSellingProducts
ORDER BY QuantitySold DESC
-- Note: Identifying the best-selling products helps focus marketing efforts and ensure stock availability.

-- Query 5: Sales by Region
-- This query calculates total sales by region (country).
SELECT pcr.Name AS Region, 
       SUM(sst.SalesYTD) AS TotalSales
FROM Sales.SalesTerritory sst
JOIN Person.CountryRegion pcr ON sst.CountryRegionCode = pcr.CountryRegionCode
GROUP BY pcr.Name
ORDER BY TotalSales DESC
-- Note: This helps identify geographic areas where sales are strong or need improvement.

-- Query 6: Sales by Territory
-- This query calculates total sales by territory, which can be associated with a specific region or sales team.
SELECT sst.Name AS Territory, 
       SUM(ssoh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader ssoh
JOIN Sales.SalesTerritory sst ON ssoh.TerritoryID = sst.TerritoryID
GROUP BY sst.Name
ORDER BY TotalSales DESC
-- Note: Analyzing sales by territory can identify high-performing territories and areas 
-- needing additional resources.


-- Query 7: Sales Growth by Month (Current Year)
-- This query calculates sales growth by month for the current year.
WITH MonthlySales AS (
    SELECT MONTH(soh.OrderDate) AS Month, 
           SUM(soh.TotalDue) AS TotalSales
    FROM Sales.SalesOrderHeader soh
    WHERE YEAR(soh.OrderDate) = '2014'
    GROUP BY MONTH(soh.OrderDate)
)
SELECT Month, TotalSales
FROM MonthlySales
ORDER BY Month
-- Identifying sales trends by month helps with marketing and resource allocation planning.

-- Query 8: Top 10 Customers by Total Spend
-- This query ranks the top 5 customers by total spend.
SELECT TOP 10 sc.CustomerID, 
             SUM(ssoh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader ssoh
JOIN Sales.Customer sc ON ssoh.CustomerID = sc.CustomerID
GROUP BY sc.CustomerID
ORDER BY TotalSales DESC
-- Note: These top customers should be nurtured with personalized offers or loyalty programs.

-- Query 9: Product Performance by Discount
-- This query calculates sales by product, segmented by the average discount applied.
SELECT p.Name AS ProductName, 
       AVG(sod.UnitPriceDiscount) AS AvgDiscount, 
       SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalSales DESC
-- Note: Products with high sales despite high discounts could suggest potential for 
-- premium pricing or a need for revaluation.

-- Query 10: Product Sales with Inventory Levels
-- This query compares sales of products with their inventory levels.
SELECT p.Name AS ProductName, 
       SUM(sod.LineTotal) AS TotalSales, 
       pi.Quantity AS InventoryLevel
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
GROUP BY p.Name, pi.Quantity
ORDER BY TotalSales DESC
-- Note: This helps identify products with high sales but low inventory, guiding stock replenishment decisions.

-- Query 11: Sales by Product in the Last 30 Days
-- This query identifies sales for each product in the last 30 days.
SELECT p.Name AS ProductName, 
       SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderHeader ssoh
JOIN Sales.SalesOrderDetail sod ON ssoh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
--WHERE ssoh.OrderDate >= DATEADD(DAY, -30, '2014')
GROUP BY p.Name
ORDER BY TotalSales DESC
-- Note: Identifying sales patterns in the past month helps with quick adjustments in marketing and stock.

-- Query 12: Monthly Sales by Product Category (Current Year)
-- This query calculates monthly sales by product category for the current year.
WITH MonthlyCategorySales AS (
    SELECT MONTH(soh.OrderDate) AS Month, 
           pc.Name AS Category, 
           SUM(soh.TotalDue) AS TotalSales
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE YEAR(soh.OrderDate) = '2014' -- recall from Query 1 (the last year on the list was 2014)
    GROUP BY MONTH(soh.OrderDate), pc.Name
)
SELECT Month, Category, TotalSales
FROM MonthlyCategorySales
ORDER BY Month, TotalSales DESC
-- Note: This provides a monthly breakdown of sales by category, helping businesses 
-- optimize inventory for key months.

-- Query 13: Customer Sales by Territory
-- This query shows sales by customer within each territory.
SELECT st.Name AS Territory, 
       c.CustomerID, 
       SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name, c.CustomerID
ORDER BY TotalSales DESC
-- Note: This helps identify top customers by territory, 
-- which can guide regional marketing and sales strategies.

-- Query 14: Yearly Product Sales and Inventory
-- This query compares yearly sales for each product against inventory levels.
SELECT p.Name AS ProductName, 
       SUM(sod.LineTotal) AS YearlySales, 
       ppi.Quantity AS InventoryLevel
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductInventory ppi ON p.ProductID = ppi.ProductID
WHERE YEAR(soh.OrderDate) = '2014' -- recall from Query 1 (the last year on the list was 2014)
GROUP BY p.Name, ppi.Quantity
ORDER BY YearlySales DESC
-- Note: This helps prioritize inventory for products that are in high demand.
