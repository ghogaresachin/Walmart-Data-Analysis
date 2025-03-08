select * from walmart;

drop table walmart;
---
select count(*) from walmart;

-- 
select 
	payment_method,
	count(*)
from walmart
group by payment_method;


select count(distinct Branch)
from walmart;

select max(quantity)
from walmart;

select min(quantity)
from walmart;

-- Business Problems 
-- Q1. Find the different payment methods and number of transactions for that method, 
-- number of qty sold by using that method
select 
	payment_method,
	count(*) as Total_transactions,
	sum(quantity) as Total_qty_sold
from walmart
	group by payment_method

-- Q2. Identify the highest-rated category in each branch, displaying the branch,category and 
-- Avg rating
select *
from
(	select
		branch,
		category,
		avg(rating) as avg_rating,
		rank() over(partition by branch order by avg(rating) desc) as rank
	from walmart
	group by 1,2
) as ranked_categories
where rank = 1;

-- Q3. Identify the busiest day for each branch based on the number of transactions.
select * 
from 
	(select 
		branch,
		to_char(to_date(date,'DD/MM/YY'),'Day') as day_name,
		count(*) as no_transactions,
		rank() over(partition by branch order by count(*) desc) as rank
		from walmart
		group by 1,2
	) as ranked_days
where rank = 1;

-- Q4. Calculate the total quantity of items sold per payment method. List payment_method and 
-- total quantity.

select 
	payment_method,
	sum(quantity) as Total_Quantity
from walmart
group by payment_method;

-- Q5. Determine the average,minimum and maximum rating of products for each city.
-- List the city, average_rating,min_rating and max_rating.
select 
	city,
	category,
	avg(rating) as avg_rating,
	min(rating) as min_rating,
	max(rating) as max_rating
from walmart
group by city,category;


--Q6. Calculate the total profit for each category by considering total_profit as
-- (unit_price*quantity*profit_margin). List category and total_profit, ordered from highest to 
-- lowest profit

select
	category,
	sum(total) as total_revenue,
	sum(unit_price*quantity*profit_margin) as total_profit
from walmart
group by category
order by total_profit desc;

-- Q7. Determine the most common payment_method for each branch. Display branch and the preffered
-- payment_method.

select *
from
	(select
		branch,
		payment_method,
		count(*) as total_trans,
		rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by branch,payment_method
	) as table1
where rank = 1
;

-- Q8. Categorize sales into 3 groups Morning, Afternoon, Evening
-- 	Find out each of the shift and number of invoices.

select
	branch,
	case 
		when Extract (Hour From(time::time)) < 12 Then 'Morning'
		when extract (Hour from(time::time)) between 12 and 17 then 'Afternoon'
		Else 'Evening'
	End day_time,
	count(*)
from walmart
group by 1,2
order by 1,3 desc;	

-- Q9. Identify 5 branch with highest decrease ratio in revenue compare to
-- last year (current year 2023 and last year 2022)

-- rdr = ((last-rev-cr_rev)/last_rev)*100
select * from walmart;


-- 2022 Sales
with revenue_2022
as
(
	select
		branch,
		sum(total) as revenue
	from walmart 
	where extract(Year From to_date(date,'DD/MM/YY')) = 2022
	group by branch
),
revenue_2023
as
(
	select
		branch,
		sum(total) as revenue
	from walmart 
	where extract(Year From to_date(date,'DD/MM/YY')) = 2023
	group by branch
)
select 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(
		((ls.revenue-cs.revenue)::numeric/ls.revenue)::numeric*100,2)
	AS revenue_decrease_ratio
from revenue_2022 as ls
join 
revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue > cs.revenue
order by revenue_decrease_ratio desc limit 5
