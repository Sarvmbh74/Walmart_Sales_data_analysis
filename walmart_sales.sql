create database walmart_db;
use walmart_db;

select count(*) from walmart;
select * from walmart limit 10;

select	
	count(distinct branch)
from walmart;

select max(quantity) from walmart;
select min(quantity) from walmart;

-- Business Problem
-- Q1: Find different payment methods, number of transactions,
-- and quantity sold by payment method
select 
	payment_method,
    count(*) as no_payments,
    SUM(quantity) as no_qty_sold
from walmart
group by payment_method; 

-- Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating    
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE `rank` = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions

select * 
from 
	(select 		
		branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) as day_name,
        count(*) as no_transcations,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as n_rank
	from walmart
	group by branch, day_name
	) as Ranked
where n_rank = 1;

-- Q4: Calculate the total quantity of items sold per payment method
select 
		payment_method,
        sum(quantity) as no_qty_sold
from walmart
group by payment_method;


-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select * from walmart;
select 
		city,
        category,
        avg(rating) as avg_rating,
        min(rating) as min_rating,
        max(rating) as max_rating
from walmart
group by city, category;

-- Q6: Calculate the total profit for each category
select * from walmart;
select
	category,
    sum(unit_price * quantity * profit_margin) as total_profit
from walmart
group by category;
     

-- Q7: Determine the most common payment method for each branch
with cte
AS
	(select 
		branch,
        payment_method,
        count(*) as total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as n_rank
	from walmart
	group by branch, payment_method
)
SELECT *
FROM cte
where n_rank = 1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
*,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END  day_time
from walmart;



SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year
-- to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;