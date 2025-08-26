create database Amazon

use Amazon

select * from [amazon_orders_dataset]

select distinct(status) from [amazon_orders_dataset]

select count(*) from [amazon_orders_dataset]

--1.List all orders placed in Hyderabad.
select orderid,city from [amazon_orders_dataset]
where city = 'Hyderabad'

--2.Get all delivered orders between 2024-01-01 and 2024-03-31.
select * from [amazon_orders_dataset]
select OrderID,[Status] from [amazon_orders_dataset]
where [status]='Delivered'

--3.Show the top 10 most expensive products by price.
SELECT TOP 10 ProductName, Price
FROM amazon_orders_dataset
ORDER BY Price DESC;

--4.Find the total number of orders per city.
select * from [amazon_orders_dataset]
SELECT City,count(OrderID) as Total_No_Of_Orders
from [amazon_orders_dataset]
group by City

--5.Retrieve all orders where quantity > 3.
SELECT * FROM [amazon_orders_dataset]
SELECT OrderID,QUANTITY
FROM amazon_orders_dataset
WHERE CAST(Quantity AS INT) > 3;--76

--6.Find the total sales amount per category.
SELECT 
    Category,
    SUM(CAST(Price AS DECIMAL(10,2)) * CAST(Quantity AS INT)) AS Total_Sales
FROM amazon_orders_dataset
GROUP BY Category
ORDER BY Total_Sales DESC;


--7.Calculate the average order value per city
SELECT 
    City,
    AVG(CAST(Price AS DECIMAL(10,2)) * CAST(Quantity AS INT)) AS Average_Order_Value
FROM amazon_orders_dataset
GROUP BY City
ORDER BY Average_Order_Value DESC;

--8.Show the top 5 customers by total spend.
SELECT * FROM [amazon_orders_dataset]
SELECT TOP 5 CustomerID,
      SUM(CAST(Price AS DECIMAL(10,2))*CAST(Quantity AS INT)) AS Total_Spend 
FROM [amazon_orders_dataset]
GROUP BY CustomerID
ORDER BY 2 DESC

--9.Count the number of cancelled orders per city.
SELECT * from [amazon_orders_dataset]
select City,count([Status]) as No_Of_Cancelled_Orders
FROM [amazon_orders_dataset]
Where [Status]='Cancelled'
Group by City
order by 2 DESC--Highest cancelled was in Hyd

--10.Find the month with the highest sales.
SELECT TOP 1
    FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
    SUM(Price * Quantity) AS Total_Sales
FROM amazon_orders_dataset
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY Total_Sales DESC;

--11.Rank customers by their total purchase value (dense_rank).
SELECT 
    CustomerID,
    SUM(Price * Quantity) AS Total_Purchase_Value,
    DENSE_RANK() OVER (ORDER BY SUM(Price * Quantity) DESC) AS Rank_Position
FROM amazon_orders_dataset
GROUP BY CustomerID
ORDER BY Total_Purchase_Value DESC;

--12. Show the top 3 best-selling products per city
WITH ProductSales AS (
    SELECT 
        City,
        ProductName,
        SUM(Quantity * Price) AS Total_Sales,
        DENSE_RANK() OVER (PARTITION BY City ORDER BY SUM(Quantity * Price) DESC) AS rnk
    FROM [amazon_orders_dataset]
    GROUP BY City, ProductName
)
SELECT City, ProductName, Total_Sales
FROM ProductSales
WHERE rnk <= 3
ORDER BY City, Total_Sales DESC;

--13.Find the percentage contribution of each city to overall sales.
SELECT * FROM [amazon_orders_dataset]

SELECT CITY,
      SUM(Quantity*Price) AS City_Total_Sales,
      ROUND(
         (SUM(Quantity*Price) *100/
         (SELECT SUM(Quantity*Price) FROM [amazon_orders_dataset])),2
         )as Percentage_Contribution
FROM [amazon_orders_dataset]
GROUP BY CITY
ORDER BY Percentage_Contribution desc

--14.Identify repeat customers (those who placed more than 2 orders)

SELECT * FROM [amazon_orders_dataset]
SELECT CUSTOMERID,
     count(OrderID) as Total_Orders
FROM [amazon_orders_dataset]
GROUP BY CUSTOMERID
HAVING COUNT(ORDERID)>2
ORDER BY Total_Orders DESC

--15.Calculate the cumulative sales trend month by montH
SELECT 
    YEAR(OrderDate) AS Sales_Year,
    MONTH(OrderDate) AS Sales_Month,
    SUM(Price * Quantity) AS Monthly_Sales,
    SUM(SUM(Price * Quantity)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ) AS Cumulative_Sales
FROM [amazon_orders_dataset]
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Sales_Year, Sales_Month

--16.Detect the most cancelled product category
SELECT TOP 1 
    Category, 
    COUNT(*) AS Cancelled_Count
FROM [amazon_orders_dataset]
WHERE [Status] = 'Cancelled'
GROUP BY Category
ORDER BY Cancelled_Count DESC
--17.Find the city with the highest average order size
SELECT TOP 1 
    City,
    AVG(Quantity) AS Avg_Order_Size
FROM [amazon_orders_dataset]
GROUP BY City
ORDER BY Avg_Order_Size DESC

--18.Show the sales share of Electronics vs. Groceries
Select distinct(category) from [amazon_orders_dataset]
SELECT 
    Category,
    SUM(Price * Quantity) AS Total_Sales,
    CAST(SUM(Price * Quantity) * 100.0 / 
         (SELECT SUM(Price * Quantity) FROM [amazon_orders_dataset]) AS DECIMAL(10,2)) AS Sales_Share_Percentage
FROM [amazon_orders_dataset]
WHERE Category IN ('Electronics', 'Groceries')
GROUP BY Category

--19.List customers who have spent above the average spending of all customers
WITH CustomerSpend AS (
    SELECT 
        CustomerID,
        SUM(Price * Quantity) AS Total_Spend
    FROM [amazon_orders_dataset]
    GROUP BY CustomerID
),
AvgSpend AS (
    SELECT AVG(Total_Spend) AS Avg_Spend FROM CustomerSpend
)
SELECT c.CustomerID, c.Total_Spend
FROM CustomerSpend c, AvgSpend a
WHERE c.Total_Spend > a.Avg_Spend
ORDER BY c.Total_Spend DESC

--20.Identify the slow-moving products (sold less than 5 times)
SELECT 
    ProductName,
    COUNT(*) AS Times_Sold
FROM [amazon_orders_dataset]
GROUP BY ProductName
HAVING COUNT(*) < 5
ORDER BY Times_Sold ASC

