create database ecommerce_analysis;
use ecommerce_analysis;
SELECT DATABASE();

select * from ecommerce_orders;
rename table ecommerce_orders to orders;
describe Orders;
show tables;
select * from orders
limit 5;

select count(*) as total_orders
from orders;

select count(*) as total_rows,
count(OrderId) as non_null_orders,
count(distinct OrderId) as unique_order_ids
from orders;

select count(*) as total_customers
from ecommerce_customers;
rename table ecommerce_customers to customers;
select * from customers
limit 5;

select count(*) as total_products
from ecommerce_products;
rename table ecommerce_products to products;
select * from products
limit 5;

select count(*) as total_orders from orders;
select count(*) as total_customers from customers;
select count(*) as total_products from products;

describe orders;

select count(*) as unmatched_customers
from orders as o
left join customers as c
on o.CustomerId = c.CustomerID
where c.CustomerID is null;
describe customers;

select count(*) as unmatcherd_products
from orders as o
left join products as p
on o.ProductID = p.ProductID
where p.ProductId is null;

select o.CustomerID,
COUNT(*) AS affected_orders
from orders o
left join customers c
on o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL
GROUP BY o.CustomerID
ORDER BY affected_orders DESC;

select * from customers
where CustomerID in('C0091','C0286','C00287','C0323');

show create table customers;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CustomerID) AS unique_customer_ids,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS duplicate_ids
FROM customers;

show index from customers;

# select specific column
select OrderID,OrderDate,CustomerID,TotalAmount
from orders
limit 5;

# filter orders by status
SELECT OrderID, OrderStatus, TotalAmount
FROM orders
WHERE OrderStatus = 'Delivered'
LIMIT 10;

# find high value orders
SELECT OrderID, CustomerID, TotalAmount
FROM orders
WHERE TotalAmount > 500
ORDER BY TotalAmount DESC;

#use multiple filter conditions
SELECT OrderID, OrderStatus, TotalAmount
FROM orders
WHERE OrderStatus = 'Delivered'
and PaymentMethod='UPI';

# using OR
SELECT OrderID, OrderStatus, TotalAmount
FROM orders
WHERE OrderStatus = 'Cancelled'
OR OrderStatus = 'Returned';
   
# sort the results (YYYY-MM-DD)
SELECT OrderID, OrderDate, TotalAmount
FROM orders
ORDER BY OrderDate DESC
LIMIT 10;

# Aggregate functions
SELECT COUNT(*) AS total_orders
FROM orders;

# calculate total revenue
SELECT ROUND(SUM(TotalAmount), 2) AS total_revenue
FROM orders;

# calculate average order value
SELECT ROUND(AVG(TotalAmount), 1) AS average_order_value
FROM orders;

# find the highest and lowest order amounts
select max(TotalAmount) as highest_order,
min(TotalAmount) as lowest_order
from orders;

#count unique customers who have ordered
select count(distinct CustomerID) as unique_customers
from orders;

# calculate total quantity sold
select sum(Quantity) as total_quantity
from orders;

# Group BY and HAVING
# Revenue by order status
SELECT
    OrderStatus,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalAmount), 2) AS total_amount
FROM orders
GROUP BY OrderStatus
ORDER BY total_amount DESC;

# Revenue by payment method
SELECT
    PaymentMethod,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalAmount), 2) AS total_amount
FROM orders
GROUP BY PaymentMethod
ORDER BY total_amount DESC;

# Sales by channel
SELECT
    SalesChannel,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalAmount), 2) AS total_amount
FROM orders
GROUP BY SalesChannel
ORDER BY total_amount DESC;

# Find customers with more than three orders
SELECT
    CustomerID,
    COUNT(*) AS order_count
FROM orders
GROUP BY CustomerID
HAVING COUNT(*) > 3
ORDER BY order_count DESC;

# Category-level product performance
SELECT
    p.Category,
    SUM(o.Quantity) AS units_sold,
    ROUND(SUM(o.TotalAmount), 2) AS total_amount
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY total_amount DESC;

# JOINS(Orders with customer names)
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    o.TotalAmount
FROM orders o
JOIN customers c
    ON o.CustomerID = c.CustomerID
LIMIT 10;

# Orders with product details
SELECT
    o.OrderID,
    p.ProductName,
    p.Category,
    o.Quantity,
    o.TotalAmount
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
LIMIT 10;

# Complete order analysis
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    p.ProductName,
    p.Category,
    o.Quantity,
    o.TotalAmount,
    o.OrderStatus
FROM orders o
JOIN customers c
    ON o.CustomerID = c.CustomerID
JOIN products p
    ON o.ProductID = p.ProductID
LIMIT 10;

# Preserve all orders when customers are missing
SELECT
    o.OrderID,
    o.CustomerID,
    c.CustomerName,
    o.TotalAmount
FROM orders o
LEFT JOIN customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

# Classify orders by amount
SELECT
    OrderID,
    TotalAmount,
    CASE
        WHEN TotalAmount >= 200 THEN 'High Value'
        WHEN TotalAmount >= 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_category
FROM orders
LIMIT 20;

# Calculate order status percentages
SELECT
    OrderStatus,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage
FROM orders
GROUP BY OrderStatus
ORDER BY percentage DESC;

# Compare delivered and non-delivered amounts
SELECT
    SUM(CASE
            WHEN OrderStatus = 'Delivered'
            THEN TotalAmount ELSE 0
        END) AS delivered_amount,
    SUM(CASE
            WHEN OrderStatus <> 'Delivered'
            THEN TotalAmount ELSE 0
        END) AS non_delivered_amount
FROM orders;

# Subqueries (Find orders above the average order amount)
SELECT OrderID, CustomerID, TotalAmount
FROM orders
WHERE TotalAmount > (
    SELECT AVG(TotalAmount)
    FROM orders
)
ORDER BY TotalAmount DESC;

# Find customers who have placed orders
SELECT CustomerID, CustomerName
FROM customers
WHERE CustomerID IN (
    SELECT DISTINCT CustomerID
    FROM orders
);

# Find products priced above the average product price
SELECT ProductID, ProductName, UnitPrice
FROM products
WHERE UnitPrice > (
    SELECT AVG(UnitPrice)
    FROM products
)
ORDER BY UnitPrice DESC;

# CTE(Calculate revenue by customer)
WITH CustomerSales AS (
    SELECT
        CustomerID,
        SUM(TotalAmount) AS total_spent,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    total_spent,
    order_count
FROM CustomerSales
ORDER BY total_spent DESC
LIMIT 10;

# Monthly sales summary using a CTE
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m') AS sales_month,
        SUM(TotalAmount) AS monthly_amount,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
)
SELECT
    sales_month,
    ROUND(monthly_amount, 2) AS monthly_amount,
    order_count
FROM MonthlySales
ORDER BY sales_month;

# Window Function(Rank customers by spending)
SELECT
    CustomerID,
    total_spent,
    RANK() OVER (
        ORDER BY total_spent DESC
    ) AS spending_rank
FROM (
    SELECT
        CustomerID,
        SUM(TotalAmount) AS total_spent
    FROM orders
    GROUP BY CustomerID
) AS CustomerTotals
ORDER BY spending_rank
LIMIT 10;

# Rank products within each category
WITH ProductSales AS (
    SELECT
        p.Category,
        p.ProductID,
        p.ProductName,
        SUM(o.TotalAmount) AS total_amount
    FROM products p
    JOIN orders o
        ON p.ProductID = o.ProductID
    GROUP BY p.Category, p.ProductID, p.ProductName
)
SELECT
    Category,
    ProductName,
    ROUND(total_amount, 2) AS total_amount,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY total_amount DESC
    ) AS category_rank
FROM ProductSales
ORDER BY Category, category_rank;

# Calculate running monthly sales
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m') AS sales_month,
        SUM(TotalAmount) AS monthly_amount
    FROM orders
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
)
SELECT
    sales_month,
    ROUND(monthly_amount, 2) AS monthly_amount,
    ROUND(
        SUM(monthly_amount) OVER (
            ORDER BY sales_month
        ),
        2
    ) AS running_amount
FROM MonthlySales
ORDER BY sales_month;

# Date and time analysis
# Sales by year
SELECT
    YEAR(OrderDate) AS sales_year,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalAmount), 2) AS total_amount
FROM orders
GROUP BY YEAR(OrderDate)
ORDER BY sales_year;

# sales by weekday
SELECT
    DAYNAME(OrderDate) AS weekday,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalAmount), 2) AS total_amount
FROM orders
GROUP BY DAYOFWEEK(OrderDate), DAYNAME(OrderDate)
ORDER BY DAYOFWEEK(OrderDate);

# final portfolio analysis
# Top 5 products by units sold
SELECT
    p.ProductName,
    SUM(o.Quantity) AS units_sold
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY units_sold DESC
LIMIT 5;

# Top 5 customers by total order amount
SELECT
    c.CustomerID,
    c.CustomerName,
    ROUND(SUM(o.TotalAmount), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY total_spent DESC
LIMIT 5;

# Create a high-level sales KPI summary
SELECT
    COUNT(*) AS total_order_records,
    COUNT(DISTINCT CustomerID) AS unique_ordering_customers,
    ROUND(SUM(TotalAmount), 2) AS total_order_amount,
    ROUND(AVG(TotalAmount), 2) AS average_order_amount,
    SUM(Quantity) AS total_units
FROM orders;

# Check whether the stored amount matches the discount calculation
SELECT
    OrderID,
    GrossAmount,
    DiscountAmount,
    TotalAmount,
    ROUND(GrossAmount - DiscountAmount, 2) AS calculated_amount
FROM orders
WHERE ABS(
    TotalAmount - (GrossAmount - DiscountAmount)
) > 0.01
LIMIT 20;

# Verify the final record counts
SELECT COUNT(*) AS total_orders FROM orders;

SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(*) AS total_products FROM products;

# Data cleaning
SELECT
    COUNT(*) AS total_rows,
    COUNT(OrderID) AS order_ids,
    COUNT(OrderDate) AS order_dates,
    COUNT(CustomerID) AS customer_ids,
    COUNT(ProductID) AS product_ids,
    COUNT(TotalAmount) AS total_amounts
FROM orders;

# Check for duplicate Order IDs
SELECT
    OrderID,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

# Check blank values
SELECT *
FROM orders
WHERE OrderID = ''
   OR CustomerID = ''
   OR ProductID = '';