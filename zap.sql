--Drop all tables if exist and create new tables.
--Note all tables without foriegn keys comes before others
--zap.table is use to reference the schema created.
DROP TABLE IF EXISTS zap.Customers CASCADE;
DROP TABLE IF EXISTS zap.Suppliers CASCADE;
DROP TABLE IF EXISTS zap.Products CASCADE;
DROP TABLE IF EXISTS zap.Orders CASCADE;
DROP TABLE IF EXISTS zap.Shipments CASCADE;
DROP TABLE IF EXISTS zap.OrderDetails CASCADE;

CREATE TABLE IF NOT EXISTS zap.Customers (
    CustomerID INT PRIMARY KEY,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS zap.Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(255),
    ContactName VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255)
);



CREATE TABLE IF NOT EXISTS zap.Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(255),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BOOLEAN
);

   CREATE TABLE zap.Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT,
    Freight DECIMAL(10, 2),
    ShipName VARCHAR(255),
    ShipAddress VARCHAR(255),
    ShipCity VARCHAR(255),
    ShipPostalCode VARCHAR(255),
    ShipCountry VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES zap.Customers(CustomerID)
);

    CREATE TABLE zap.Shipments (
    ShipmentID INT PRIMARY KEY,
    OrderID INT,
    ShipperID INT,
    ShipmentDate DATE,
    FOREIGN KEY (OrderID) REFERENCES zap.Orders(OrderID)
);



    CREATE TABLE zap.OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES zap.Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES zap.Products(ProductID)
);


--Answered Queries
--question 1:Select all records from the customers table
SELECT * FROM zap.Customers
ORDER BY CustomerID ASC LIMIT 100

--Find all products that have a price greater than 50
SELECT *
FROM zap.Products
WHERE UnitPrice > 50
LIMIT(10);

--Get the first name, last name, and phone of all customers from the customers table
SELECT 
    LEFT(ContactName, POSITION(' ' IN ContactName) - 1) AS FirstName,
    SUBSTRING(ContactName FROM POSITION(' ' IN ContactName) + 1) AS LastName,
    phone
FROM zap.Customers;

--Count the number of orders made by each customer (identified by customer ID).
SELECT
    CustomerID,
    COUNT(OrderID) AS NumberOfOrders
FROM Orders
GROUP BY CustomerID
ORDER BY CustomerID ASC;



--List all suppliers along with the number of products they supply

SELECT
    s.SupplierName,
    COUNT(p.ProductID) AS NumberOfProducts
FROM zap.Suppliers s
JOIN zap.Products p ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID
LIMIT(10);

--Find all orders that have a total amount greater than 100. (You will need to calculate the total
--amount by joining orders and order_details tables.)
SELECT
    o.OrderID,
    o.CustomerID,
    ROUND(SUM(od.Quantity * od.UnitPrice)) AS TotalAmount
FROM zap.Orders o
JOIN zap.OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.CustomerID
HAVING ROUND(SUM(od.Quantity * od.UnitPrice)) > 100
LIMIT 10;

--Select all customers that have placed more than 5 orders
SELECT
    c.CustomerID,
    c.ContactName,
    COUNT(o.OrderID) AS OrderCount
FROM zap.Customers c
JOIN zap.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(o.OrderID) > 5;

--#List the details of shipments that have not yet been delivered (assuming NULL in
--#delivery_date means not delivered).
SELECT
    ShipmentID,
    OrderID,
    ShippedDate,
    RequiredDate
FROM
    zap.Shipments
WHERE
    ShippedDate IS NULL OR ShippedDate > RequiredDate;

--#Display the product name and the total quantity ordered for each product
SELECT
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantityOrdered
FROM
    zap.Products p
JOIN
    zap.OrderDetails od ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID, p.ProductName
ORDER BY
    TotalQuantityOrdered DESC;

--Find the customer who has spent the most money on orders. (Assume unit_price *
--quantity gives the total price for an order detail record.)
SELECT
    c.CustomerID,
    c.ContactName,
    ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS TotalSpent
FROM
    zap.Customers c
JOIN
    zap.Orders o ON c.CustomerID = o.CustomerID
JOIN
    zap.OrderDetails od ON o.OrderID = od.OrderID
GROUP BY
    c.CustomerID, c.ContactName
ORDER BY
    TotalSpent DESC
LIMIT 1;


--Get a list of products that have never been ordered
SELECT
    p.ProductID,
    p.ProductName
FROM
    zap.Products p
LEFT JOIN
    zap.OrderDetails od ON p.ProductID = od.ProductID
WHERE
    od.OrderID IS NULL
ORDER BY
    p.ProductID ASC;

--#Calculate the monthly sales total (sum of unit_price * quantity from order_details) for
--#each month
SELECT
    TO_CHAR(o.OrderDate, 'YYYY-MM') AS Month,
    ROUND(SUM(od.UnitPrice * od.Quantity)) AS MonthlySalesTotal
FROM
    zap.Orders o
JOIN
    zap.OrderDetails od ON o.OrderID = od.OrderID
GROUP BY
    TO_CHAR(o.OrderDate, 'YYYY-MM')
ORDER BY
    Month ASC;

--Find the top 3 most popular products (most quantity ordered) for each category.
SELECT
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantityOrdered
FROM
    zap.Products p
JOIN
    zap.OrderDetails od ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID, p.ProductName
ORDER BY
    TotalQuantityOrdered DESC
LIMIT 4;
