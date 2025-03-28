use walmart_db;

select * from walmart;

select count(*) from walmart;



-- Count payment methods and number of transactions by payment method
select 
payment_method,
count(*) as no_payments
from walmart
 group by payment_method;
 
 select count(distinct branch) from walmart;
 
 select min(quantity) from walmart;
 
 -- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
 select 
 payment_method,
 count(*) as no_payments,
 sum(quantity) as no_quantity_sold
 from walmart
 group by payment_method;
 
 
 -- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
 select branch,category,avg_rating
 from(
 select 
 branch,
 category,
 avg(rating) as avg_rating,
 rank() over(partition by branch order by avg(rating) desc ) as ranked
 from walmart
 group by branch,category
 ) as ranke
 where ranked=1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
 
 SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranke
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranke = 1;
 
 
 -- Q4: Calculate the total quantity of items sold per payment method
 select
 payment_method,
 sum(quantity) as no_qty_sold
 from walmart 
 group by payment_method;
 
 
 
-- Q5: Determine the average, minimum, and maximum rating of categories for each city
 select
 city,
 category,
 min(rating) as min_rating,
 max(rating) as max_rating,
 avg(rating) as avg_rating
 from walmart
 group by city,category;
 
 -- Q6: Calculate the total profit for each category
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
with cte as (
select 
branch,
payment_method,
count(*) as total_trans,
rank() over (partition by branch order by count(*) desc) as ranke
from walmart
group by branch,payment_method
)
select branch,payment_method as preferred_payment_method
from cte
where ranke=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
select
 branch,
CASE
   when hour(time(time))<12 then 'Morning'
   when hour(time(time)) between 12 and 17 then 'Afternoon'
   else 'Evening'
   end as shift,
   count(*) as num_invoices
   from walmart
   group by branch,shift
   order by branch,num_invoices desc;
   
   -- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
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