
## Lab | SQL Rolling calculations
## In this lab, you will be using the Sakila database of movie rentals.

#1. Get number of monthly active customers.

use sakila;

create or replace view customer_usage as (select customer_id, convert(rental_date, date) as DateFrame, 
date_format(convert(rental_date,date), '%m') as MonthFrame, date_format(convert(rental_date,date), '%Y') as YearFrame from sakila.rental);

create or replace view month_usage as( select count(distinct customer_id) as customers_usage, YearFrame, MonthFrame
from customer_usage group by YearFrame, MonthFrame order by YearFrame, MonthFrame);

select *from month_usage;

#2. Active users in the previous month.

with cte_usage as (select customers_usage, lag(customers_usage,1) over (partition by YearFrame) as last_month_usage, YearFrame, Monthframe
from month_usage)
select*from cte_usage where last_month_usage is not null;

#3. Percentage change in the number of active customers.

with cte_usage as (select customers_usage, lag(customers_usage,1) over (partition by YearFrame) as last_month_usage, 
(customers_usage-lag(customers_usage,1) over (partition by YearFrame))/customers_usage*100 as percentage, YearFrame, MonthFrame
from month_usage)
select*from cte_usage where last_month_usage is not null;

#4. Retained customers every month.

with unique_customers as (select distinct customer_id , MonthFrame, YearFrame from customer_usage)
select count(distinct d1.customer_id) as customers_retention, d1.MonthFrame, d1.YearFrame
from unique_customers d1 join unique_customers d2 on d1.customer_id = d2.customer_id and d1.MonthFrame = d2.MonthFrame + 1
group by d1.MonthFrame, d1.YearFrame order by d1.YearFrame, d1.MonthFrame;