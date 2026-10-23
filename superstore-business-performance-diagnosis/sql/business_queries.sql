---Create Table

CREATE TABLE superstore(
    row_id        INT,
    order_id      VARCHAR(20),
    order_date    DATE,
    ship_date     DATE,
    ship_mode     VARCHAR(20),
    customer_id   VARCHAR(20),
    customer_name VARCHAR(100),
    segment       VARCHAR(20),
    country       VARCHAR(50),
    city          VARCHAR(100),
    state         VARCHAR(50),
    postal_code   VARCHAR(10),
    region        VARCHAR(20),
    product_id    VARCHAR(30),
    category      VARCHAR(30),
    sub_category  VARCHAR(30),
    product_name  VARCHAR(255),
    sales         NUMERIC(12,2),
    order_year    INT,
    order_month   INT,
    year_month    VARCHAR(7),
    days_to_ship  INT
);

---Check the Import
SELECT COUNT(*) AS total_rows FROM superstore;                
SELECT ROUND(SUM(sales), 2) AS total_sales FROM superstore;  
SELECT * FROM superstore LIMIT 5;

---Superstore Business Performance Diagnosis: Business Queries

-- Q1. Overall KPIs. What are the total sales, orders, customers, and average order value?
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM superstore;

-- Q2. Sales by year with year-over-year growth. How did sales change from year to year?
WITH yearly AS (
    SELECT order_year, SUM(sales) AS total_sales
    FROM superstore
    GROUP BY order_year
)
SELECT
    order_year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY order_year))
          / NULLIF(LAG(total_sales) OVER (ORDER BY order_year), 0), 2) AS yoy_growth_pct
FROM yearly
ORDER BY order_year;

-- Q3. Monthly sales trend. Which months had the highest and lowest sales?
SELECT year_month, ROUND(SUM(sales), 2) AS monthly_sales
FROM superstore
GROUP BY year_month
ORDER BY year_month;

-- Q4. Sales and share by region. Which regions contribute the most and least to total sales?
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(100.0 * SUM(sales) / SUM(SUM(sales)) OVER (), 2) AS share_pct
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

-- Q5. Sales by category and sub-category (top 10). Which 10 sub-categories generate the most sales?
SELECT category, sub_category, ROUND(SUM(sales), 2) AS total_sales
FROM superstore
GROUP BY category, sub_category
ORDER BY total_sales DESC
LIMIT 10;

-- Q6. Sub-category change from 2017 to 2018. Which sub-categories grew or declined from 2017 to 2018?
SELECT
    sub_category,
    ROUND(SUM(CASE WHEN order_year = 2017 THEN sales END), 2) AS sales_2017,
    ROUND(SUM(CASE WHEN order_year = 2018 THEN sales END), 2) AS sales_2018,
    ROUND(100.0 * (SUM(CASE WHEN order_year = 2018 THEN sales END)
                 - SUM(CASE WHEN order_year = 2017 THEN sales END))
          / NULLIF(SUM(CASE WHEN order_year = 2017 THEN sales END), 0), 2) AS change_pct
FROM superstore
GROUP BY sub_category
ORDER BY change_pct ASC;

-- Q7. Segment performance. Which segment brings in the most sales and the highest order value?
SELECT
    segment,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

-- Q8. Shipping speed by ship mode. How long does each ship mode take, and how much sales does it carry?
SELECT
    ship_mode,
    COUNT(*) AS line_items,
    ROUND(AVG(days_to_ship), 2) AS avg_days_to_ship,
    ROUND(SUM(sales), 2) AS total_sales
FROM superstore
GROUP BY ship_mode
ORDER BY avg_days_to_ship;

-- Q9. Top 10 customers and their share of sales. Who are the top 10 customers, and how much of total sales do they represent?
SELECT
    customer_id,
    MAX(customer_name) AS customer_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(100.0 * SUM(sales) / SUM(SUM(sales)) OVER (), 2) AS share_pct
FROM superstore
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- Q10. Repeat customer rate. What percentage of customers bought more than once?
WITH cust AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM superstore
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE orders > 1) AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders > 1) / COUNT(*), 2) AS repeat_rate_pct
FROM cust;

-- Q11. Top 10 cities by sales. Which cities and states generate the most sales?
SELECT state, city, ROUND(SUM(sales), 2) AS total_sales
FROM superstore
GROUP BY state, city
ORDER BY total_sales DESC
LIMIT 10;

-- Q12. Region by category. Which product categories sell best in each region?
SELECT
    region,
    category,
    ROUND(SUM(sales), 2) AS total_sales
FROM superstore
GROUP BY region, category
ORDER BY region, total_sales DESC;

-- Q13. Data quality checks. Are there missing postal codes, shipping errors, or duplicate row IDs?
SELECT COUNT(*) FILTER (WHERE postal_code = 'Unknown') AS unknown_postal_codes,
       COUNT(*) FILTER (WHERE ship_date < order_date)  AS ship_before_order,
       COUNT(*) - COUNT(DISTINCT row_id) AS duplicate_row_ids
FROM superstore;
















