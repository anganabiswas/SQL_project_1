CREATE DATABASE IF NOT EXISTS salesDataWalmart;
USE salesDataWalmart;


-- create table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12,4),
    rating FLOAT
);


SELECT * FROM sales;

-- ------ Feature engineering
-- time_of_day-------------
SELECT
    time,
    (CASE
        WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);


-- --------------------------- Add time_of_day -------------------------------------
UPDATE sales
SET time_of_day = (
	CASE
        WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END);
    
SET SQL_SAFE_UPDATES = 0;

SET SQL_SAFE_UPDATES = 1;

-- ----------------------------- Add day_name -----------------------------------------
SELECT
	date,
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- ------------------------------- Add Month_name ------------------------------------
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- -------------------- Exploratory Data Analysis(EDA)-----------------------
-- --------------------------------------------------------------------------
-- --------------------- Generic Question -----------------------------------

-- Q1: How many unique product lines does the data have?
SELECT DISTINCT city FROM sales;

-- Q2: In which city is each branch?
SELECT DISTINCT city, branch FROM sales;

-- -------------------------------------------------------------------------
-- -------------------- Product Question -----------------------------------

-- Q1: How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) AS total_product_line
FROM sales;

-- Q2: What is the most common payment method?
SELECT payment, COUNT(payment) as count_payment
FROM sales
GROUP BY payment 
ORDER BY count_payment DESC
LIMIT 1;

-- Q3: What is the most selling product line?
SELECT product_line, COUNT(product_line) AS cnt_prod_line
FROM sales
GROUP BY product_line
ORDER BY cnt_prod_line DESC;

-- Q4: What is the total revenue by month?
SELECT month_name AS month, SUM(total) AS Total_revenue
FROM sales 
GROUP BY month
ORDER BY Total_revenue desc;

-- Q5: What month had the largest COGS?
SELECT month_name AS month, SUM(cogs) AS Total_cogs
FROM sales 
GROUP BY month
ORDER BY Total_cogs desc
LIMIT 1;

-- Q6:  What product line had the largest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM sales 
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Q7: What is the city with the largest revenue?
SELECT city, branch, SUM(total) AS total_revenue
FROM sales 
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- Q8: What product line had the largest VAT?
SELECT product_line, AVG(tax_pct) AS Avg_tax
FROM sales 
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Q9: Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
    product_line,
    SUM(total) AS total_sales,
    CASE
        WHEN SUM(total) > (SELECT AVG(total_sales) FROM (SELECT SUM(total) AS total_sales FROM sales GROUP BY product_line) AS avg_sales) 
        THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM sales
GROUP BY product_line;

-- Q10: Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS quantity
FROM sales 
GROUP BY branch 
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- Q11: What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) AS common_product
FROM sales 
GROUP BY gender, product_line
ORDER BY common_product DESC;

-- Q12: What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating), 2) AS Avg_rating
FROM sales
GROUP BY product_line
ORDER BY Avg_rating DESC;

-- ----------------------------------------------------------------------------------
-- -------------------------- Sales Question ----------------------------------------

-- Q1: Number of sales made in each time of the day per weekday
SELECT time_of_day, COUNT(*) AS Total_Sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY Total_Sales DESC;

-- Q2: Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS Total_revenue
FROM sales 
GROUP BY customer_type
ORDER BY Total_revenue DESC;

-- Q3: Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, ROUND(AVG(tax_pct), 2) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Q4: Which customer type pays the most in VAT?
SELECT customer_type, ROUND(AVG(tax_pct), 2) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ---------------------------------------------------------------------------------
-- ----------------------- Customer Question ---------------------------------------

-- Q1: How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) AS unique_customer_types
FROM sales;

SELECT DISTINCT customer_type FROM sales;

-- Q2: How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) AS unique_payment
FROM sales;

SELECT DISTINCT payment FROM sales;

-- Q3: What is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS Common_cst
FROM sales 
GROUP BY customer_type
ORDER BY common_cst DESC;

-- Q4: Which customer type buys the most?
SELECT customer_type, COUNT(*) AS Common_cst
FROM sales 
GROUP BY customer_type;

-- Q5: What is the gender of most of the customers?
SELECT gender, COUNT(*) AS cnt_gender FROM sales
GROUP BY gender
ORDER BY cnt_gender DESC;

-- Q6:What is the gender distribution per branch?
SELECT gender, COUNT(*) AS cnt_gender
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY cnt_gender DESC;

-- Q7: Which time of the day do customers give most ratings?
SELECT time_of_day, ROUND(AVG(rating), 2) AS Avg_rating
FROM sales 
GROUP BY time_of_day
ORDER BY Avg_rating DESC;

-- Q8: Which time of the day do customers give most ratings per branch?
SELECT time_of_day, ROUND(AVG(rating), 2) AS Avg_rating
FROM sales 
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY Avg_rating DESC;

-- Q9: Which day fo the week has the best avg ratings?
SELECT day_name, ROUND(AVG(rating), 2) AS Avg_rating
FROM sales 
GROUP BY day_name
ORDER BY Avg_rating DESC;

-- Q10: Which day of the week has the best average ratings per branch?
SELECT day_name, ROUND(AVG(rating), 2) AS Avg_rating
FROM sales 
WHERE branch = "B"
GROUP BY day_name
ORDER BY Avg_rating DESC;




