-- ============================================================
-- RETAIL SALES SQL ANALYSIS — INDIA 2023
-- Author  : Vashu Pandey
-- Program : B.Sc Data Science, IIT Madras
-- Contact : vashupandey101@gmail.com
-- DB      : SQLite (retail_sales.db)
-- Table   : sales (500 rows, 14 columns)
-- ============================================================
-- TABLE SCHEMA:
-- Order_ID, Order_Date, Category, Sub_Category, Region,
-- City, Customer_Segment, Unit_Price, Quantity, Discount,
-- Sales, Profit, Month, Month_Num
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: BASIC EXPLORATION
-- ────────────────────────────────────────────────────────────

-- Q1. How many total orders are in the dataset?
-- Business use: Quick data validation check
SELECT COUNT(*) AS total_orders
FROM sales;


-- Q2. What is the overall revenue, profit, and average order value?
-- Business use: Top-level KPI summary for management report
SELECT
    ROUND(SUM(Sales), 2)          AS total_revenue,
    ROUND(SUM(Profit), 2)         AS total_profit,
    ROUND(AVG(Sales), 2)          AS avg_order_value,
    ROUND(SUM(Profit)*100.0
          / SUM(Sales), 2)        AS profit_margin_pct
FROM sales;


-- Q3. What are the distinct product categories?
-- Business use: Understand product portfolio
SELECT DISTINCT Category
FROM sales
ORDER BY Category;


-- Q4. How many orders came from each region?
-- Business use: Regional distribution check
SELECT
    Region,
    COUNT(*)            AS order_count,
    ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM sales), 1) AS pct_share
FROM sales
GROUP BY Region
ORDER BY order_count DESC;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: SALES & REVENUE ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q5. Which category generates the most revenue and profit?
-- Business use: Identify star products for investment decisions
SELECT
    Category,
    ROUND(SUM(Sales), 2)    AS total_sales,
    ROUND(SUM(Profit), 2)   AS total_profit,
    ROUND(SUM(Profit)*100.0
          / SUM(Sales), 2)  AS profit_margin_pct,
    COUNT(*)                AS num_orders
FROM sales
GROUP BY Category
ORDER BY total_sales DESC;


-- Q6. What are the top 5 best-selling sub-categories by revenue?
-- Business use: Product-level performance to guide stocking decisions
SELECT
    Sub_Category,
    Category,
    ROUND(SUM(Sales), 2)  AS total_sales,
    COUNT(*)              AS orders
FROM sales
GROUP BY Sub_Category, Category
ORDER BY total_sales DESC
LIMIT 5;


-- Q7. Which month had the highest and lowest sales?
-- Business use: Identify seasonal patterns for marketing planning
SELECT
    Month,
    Month_Num,
    ROUND(SUM(Sales), 2)   AS monthly_sales,
    ROUND(SUM(Profit), 2)  AS monthly_profit
FROM sales
GROUP BY Month, Month_Num
ORDER BY Month_Num;


-- Q8. What is the month-over-month sales growth?
-- Business use: Trend analysis for forecasting
SELECT
    Month,
    Month_Num,
    ROUND(SUM(Sales), 2) AS monthly_sales,
    ROUND(SUM(Sales) - LAG(SUM(Sales))
          OVER (ORDER BY Month_Num), 2) AS mom_change,
    ROUND((SUM(Sales) - LAG(SUM(Sales))
          OVER (ORDER BY Month_Num))*100.0
          / LAG(SUM(Sales)) OVER (ORDER BY Month_Num), 1) AS mom_growth_pct
FROM sales
GROUP BY Month, Month_Num
ORDER BY Month_Num;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: REGIONAL & CITY ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q9. Which region has the best profit margin?
-- Business use: Resource allocation — invest more in high-margin regions
SELECT
    Region,
    ROUND(SUM(Sales), 2)           AS total_sales,
    ROUND(SUM(Profit), 2)          AS total_profit,
    ROUND(SUM(Profit)*100.0
          / SUM(Sales), 2)         AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(Profit)*1.0/SUM(Sales) DESC) AS margin_rank
FROM sales
GROUP BY Region;


-- Q10. Top 10 cities by total revenue
-- Business use: Identify key markets for expansion
SELECT
    City,
    Region,
    ROUND(SUM(Sales), 2)  AS total_sales,
    COUNT(*)              AS orders,
    ROUND(AVG(Sales), 2)  AS avg_order_value
FROM sales
GROUP BY City, Region
ORDER BY total_sales DESC
LIMIT 10;


-- Q11. Which city has the highest average order value?
-- Business use: Premium market identification for targeted campaigns
SELECT
    City,
    Region,
    ROUND(AVG(Sales), 2)  AS avg_order_value,
    COUNT(*)              AS orders
FROM sales
GROUP BY City, Region
HAVING COUNT(*) >= 10
ORDER BY avg_order_value DESC
LIMIT 5;


-- ────────────────────────────────────────────────────────────
-- SECTION 4: CUSTOMER SEGMENT ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q12. How do the three customer segments compare on revenue and profit?
-- Business use: Segment prioritization for sales strategy
SELECT
    Customer_Segment,
    COUNT(*)                       AS orders,
    ROUND(SUM(Sales), 2)           AS total_sales,
    ROUND(AVG(Sales), 2)           AS avg_order_value,
    ROUND(SUM(Profit)*100.0
          / SUM(Sales), 2)         AS profit_margin_pct
FROM sales
GROUP BY Customer_Segment
ORDER BY total_sales DESC;


-- Q13. Which segment-category combination is most profitable?
-- Business use: Cross-analysis to find best customer-product pairings
SELECT
    Customer_Segment,
    Category,
    ROUND(SUM(Sales), 2)    AS total_sales,
    ROUND(SUM(Profit), 2)   AS total_profit,
    ROUND(SUM(Profit)*100.0
          / SUM(Sales), 2)  AS margin_pct
FROM sales
GROUP BY Customer_Segment, Category
ORDER BY total_profit DESC
LIMIT 8;


-- ────────────────────────────────────────────────────────────
-- SECTION 5: DISCOUNT IMPACT ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q14. How does discount level affect profit margin?
-- Business use: Pricing strategy — are deep discounts hurting us?
SELECT
    CAST(Discount*100 AS INT) || '%'  AS discount_level,
    COUNT(*)                           AS orders,
    ROUND(AVG(Sales), 2)               AS avg_sales,
    ROUND(AVG(Profit), 2)              AS avg_profit,
    ROUND(AVG(Profit)*100.0
          / AVG(Sales), 2)             AS avg_margin_pct
FROM sales
GROUP BY Discount
ORDER BY Discount;


-- Q15. What percentage of orders have a discount applied?
-- Business use: Discount usage audit
SELECT
    CASE WHEN Discount = 0 THEN 'No Discount'
         ELSE 'Discounted' END        AS discount_status,
    COUNT(*)                           AS orders,
    ROUND(COUNT(*)*100.0
          /(SELECT COUNT(*) FROM sales), 1) AS pct_of_orders,
    ROUND(AVG(Profit), 2)              AS avg_profit
FROM sales
GROUP BY discount_status;


-- ────────────────────────────────────────────────────────────
-- SECTION 6: ADVANCED — WINDOW FUNCTIONS & SUBQUERIES
-- ────────────────────────────────────────────────────────────

-- Q16. Rank categories by sales within each region
-- Business use: Regional product performance comparison
SELECT
    Region,
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    RANK() OVER (
        PARTITION BY Region
        ORDER BY SUM(Sales) DESC
    ) AS rank_in_region
FROM sales
GROUP BY Region, Category
ORDER BY Region, rank_in_region;


-- Q17. Find orders where profit is below the average profit
-- Business use: Flag underperforming transactions for review
SELECT
    Order_ID,
    Category,
    Region,
    ROUND(Sales, 2)   AS sales,
    ROUND(Profit, 2)  AS profit
FROM sales
WHERE Profit < (SELECT AVG(Profit) FROM sales)
  AND Discount > 0.10
ORDER BY Profit ASC
LIMIT 10;


-- Q18. Running total of sales by month
-- Business use: Cumulative revenue tracking for annual targets
SELECT
    Month,
    Month_Num,
    ROUND(SUM(Sales), 2) AS monthly_sales,
    ROUND(SUM(SUM(Sales))
          OVER (ORDER BY Month_Num), 2) AS running_total
FROM sales
GROUP BY Month, Month_Num
ORDER BY Month_Num;


-- Q19. What is the contribution of each category to total revenue? (CTE)
-- Business use: Portfolio share analysis
WITH category_sales AS (
    SELECT
        Category,
        SUM(Sales) AS cat_sales
    FROM sales
    GROUP BY Category
),
total AS (
    SELECT SUM(Sales) AS grand_total FROM sales
)
SELECT
    c.Category,
    ROUND(c.cat_sales, 2)                        AS category_revenue,
    ROUND(c.cat_sales * 100.0 / t.grand_total, 1) AS revenue_share_pct
FROM category_sales c, total t
ORDER BY revenue_share_pct DESC;


-- Q20. Identify the top 3 most profitable orders in each region
-- Business use: Spot high-value transactions for case study
SELECT *
FROM (
    SELECT
        Region,
        Order_ID,
        Category,
        City,
        ROUND(Sales, 2)   AS sales,
        ROUND(Profit, 2)  AS profit,
        RANK() OVER (
            PARTITION BY Region
            ORDER BY Profit DESC
        ) AS profit_rank
    FROM sales
)
WHERE profit_rank <= 3
ORDER BY Region, profit_rank;


-- ============================================================
-- END OF ANALYSIS
-- All queries written by Vashu Pandey
-- Dataset: 500 Indian retail orders, 2023
-- ============================================================
