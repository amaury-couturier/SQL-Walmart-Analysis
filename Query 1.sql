CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(15) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9), 
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1) NOT NULL
);

-- ------------------- --
-- Feature Engineering --

-- Time of day --
SELECT time,
    (CASE
		WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		ELSE 'Evening'
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
SELECT * FROM sales LIMIT 5; -- Check to see if the column was correctly inserted into table

UPDATE sales 
SET time_of_day = 
(
	CASE
		WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		ELSE 'Evening'
	END
);
SELECT * FROM sales LIMIT 5; -- Check if data was inserted

-- Name of the day --
SELECT 
	date,
    DAYNAME(date) AS day_name
 FROM sales;
 
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
SELECT * FROM sales LIMIT 5; -- Check to see if the column was correctly inserted into table

UPDATE sales
SET day_name = DAYNAME(date);
SELECT * FROM sales LIMIT 5; -- Check if data was inserted

-- Name of the Month --
SELECT 
	date, 
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
SELECT * FROM sales LIMIT 5; -- Check to see if the column was correctly inserted into table

UPDATE sales 
SET month_name = MONTHNAME(date);
SELECT * FROM sales LIMIT 5; -- Check if data was inserted

-- -------------------------- --
-- Generic Business Questions --

-- How many unique cities does the data have?
SELECT
	DISTINCT city
FROM sales;

-- 3 distinct cities: Yangon, Naypyitaw, Mandalay

-- In which city is each branch?
SELECT
	DISTINCT city, branch
FROM sales;

-- Branch A in Yangon, Branch C in Napypyitaw, and Branch B in Mandalay

-- -------------------------- --
-- Product Business Questions --

-- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT product_line)
FROM sales;

-- 6

-- What is the most common payment method?
SELECT
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- Cash 

-- What is the best selling product line?
SELECT
	product_line,
	COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;
	
-- Fashion accessories

-- What is the total revenue by month?
SELECT
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- January

-- What month had the largest COGS?
SELECT
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- January

-- What product had the largest revenue?
SELECT
	product_line,
    SUM(total) as total_revenue
FROM sales
GROUP BY product_line 
ORDER BY total_revenue DESC;

-- Food and beverages

-- What is the city with the largest revenue?
SELECT
	branch,
	city,
    SUM(total) as total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue DESC;

-- Branch C in Naypyitaw

-- What product line had the largest VAT?
SELECT
	product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Home and lifestyle

-- Which branch sold more products than average product sold?
SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- Branch A

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- Female: Fashion accessories
-- Male: Health and beauty

-- What is the average rating of each product line?
SELECT
	ROUND(AVG(rating), 2) AS avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- Food and beverages: 7.11
-- Fashion accessories: 7.03
-- Health and beauty: 6.98
-- Electronic accessories: 6.91
-- Sports and travel: 6.86

-- Fetch each product line and add a column to those product line showing "Good", "Bad". 
-- Good if its greater than average sales
WITH ProductLineSales AS (
    SELECT 
        product_line,
        SUM(total) AS total_sales
    FROM 
        sales
    GROUP BY 
        product_line
),
AverageSales AS (
    SELECT 
        AVG(total_sales) AS avg_sales
    FROM 
        ProductLineSales
)
SELECT 
    pls.product_line,
    pls.total_sales,
    CASE 
        WHEN pls.total_sales > (SELECT avg_sales FROM AverageSales) THEN 'Good'
        ELSE 'Bad'
    END AS sales_category
FROM 
    ProductLineSales pls;


-- ------------------------ --
-- Sales Business Questions --

-- Number of sales made in each time of the day per weekday
SELECT
	time_of_day,
    day_name,
    COUNT(*) AS total_sales
FROM sales
GROUP BY time_of_day, day_name
ORDER BY total_sales DESC;

-- Monday: Evening
-- Tuesday: Evening
-- Wednesday: Afternoon
-- Thursday: Evening
-- Friday: Afternoon
-- Saturday: Evening
-- Sunday: Evening

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- Members

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city, 
    AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Naypyitaw

-- Which customer type pays the most in VAT?
SELECT
	customer_type, 
    AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- Member

-- --------------------------- --
-- Customer Business Questions --

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- 2: Member and Normal

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- 3: Cash, Ewallet, Credit card

-- What is the most common customer type?
SELECT
	customer_type,
    COUNT(*) AS type_count
FROM sales
GROUP BY customer_type
ORDER BY type_count DESC;

-- Member: 499, Normal: 496

-- Which customer type buys the most?
SELECT
	DISTINCT customer_type,
    ROUND(SUM(total), 2) AS total_bought
FROM sales
GROUP BY customer_type
ORDER BY total_bought DESC;

-- Member: 163,625.10, Normal: 157,261.29

-- What is the gender of most of the customers?
SELECT
	gender,
    COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- Male: 498, Female: 497

-- What is the gender distribution per branch?
SELECT
	gender,
    branch,
    COUNT(*) as gender_count
FROM sales
GROUP BY gender, branch
ORDER BY gender_count DESC;

-- Branch A: 
	-- Male: 176, Female: 160	
-- Branch B:
	-- Male: 169, Female: 160
-- Branch C:
	-- Female: 177, Male: 150

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
    COUNT(rating) as count_rating
FROM sales
GROUP BY time_of_day
ORDER BY count_rating DESC;

-- Evening

-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
    branch,
    COUNT(rating) as count_rating
FROM sales
GROUP BY 
	time_of_day,
    branch
ORDER BY count_rating DESC;

-- Branch A, B, and C: Evening

-- Which day of the week has the best avg ratings?
SELECT 
	day_name,
    ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;
    
-- Monday
    
-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
    branch,
    ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;
    
-- Branch A: Friday
-- Branch B: Monday
-- Branch C: Saturday
    