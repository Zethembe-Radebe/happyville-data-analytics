Create Database happyville;
Use happyville;

Create Table customers (
customer_id INT PRIMARY KEY,
first_name varchar(50),
last_name varchar(50),
email varchar(100),
signup_date date,
city varchar(50),
gender varchar(10)
);

Create table bookings (
booking_id int PRIMARY KEY,
customer_id int,
booking_date date,
visit_date date,
ticket_type varchar(50),
ticket_count int,
total_amount decimal(10,2),
booking_channel varchar(50),
 foreign key (customer_id) references customers(customer_id)
 );
 
 Create table attractions (
 attraction_id int primary key,
 attraction_name varchar(100),
 category varchar(50),
 capacity int
 );
 
 Create table in_park_purchases (
 purchase_id int primary key,
 customer_id int,
 purchase_date date,
 category varchar(50),
 amount decimal(10,2),
 foreign key(customer_id) references customers(customer_id)
 );
 
 Create table attendance (
 attendance_id int primary key,
 customer_id int,
 visit_date date,
 attraction_id int,
 time_spent_minutes int,
  foreign key(customer_id) references customers(customer_id),
  foreign key(attraction_id) references attractions(attraction_id)
  );
  
  -- How many records do we have?
  
  select 'customers' as table_name, count(*) AS records from customers
  union all
  select 'bookings', count(*) from bookings
  union all
  select 'attractions', count(*) from attractions
  union all
  select 'in_park_purchases', count(*) from in_park_purchases
  union all
  select 'attendance', count(*) from attendance
;

-- What does the data look like?
Select * from customers limit 10;
select * from bookings limit 10;
select * from attractions limit 10;
select * from in_park_purchases limit 10;
select * from attendance limit 10;

-- Any Nulls?
Select count(*) - count(email) as missing_emails from customers;
select count(*) - count(total_amount) as missing_amounts from bookings;
Select count(*) - count(capacity) as missing_value from attractions;
select count(*) - count(purchase_date) as missing_dates from in_park_purchases;
select count(*) - count(time_spent_minutes) as missing_minutes from attendance;

-- TOTAL REVENUE ACROSS EVERYTHING?
Select sum(b.total_amount) as booking_revenue, sum(p.amount) as in_park_revenue,
sum(b.total_amount) + sum(p.amount) as total_revenue
From bookings b, in_park_purchases p;

-- WHICH TYPE OF TICKET GENERATES MORE INCOME?
select ticket_type, count(booking_id) as total_bookings,
sum(total_amount) as revenue,
round(sum(total_amount) *100.0 / (select sum(total_amount) from bookings), 1) as revenue_pct
from bookings
group by ticket_type
order by revenue desc;

-- HOW IS REVENUE TRENDING MONTH BY MONTH?
select date_format(booking_date, '%Y-%m') as month,
sum(total_amount) as monthly_revenue,
count(booking_id) as total_bookings
from bookings
group by month
order by month;

-- ONLINE CHANNEL GROWTH SINCE LAUNCH?
select date_format(booking_date, '%Y-%m') as month,
booking_channel, 
count(booking_id) as bookings,
sum(total_amount) as revenue
from bookings
group by month, booking_channel
order by month;

select sum(booking_id) as total_bookings, booking_channel
from bookings
group by booking_channel;

-- WHICH CITIES ARE OUR CONSUMERS FROM??
select city, 
count(customer_id) as total_customers,
round(count(customer_id) *100.0 / (select count(*) from customers), 1) as pct
from customers
group by city
order by total_customers desc;

-- REPEAT CUSTOMERS VS NEW CUSTOMERS
select 
case 
when total_bookings = 1 then ' NEW Customer'
when total_bookings = 2 then 'Retrning Cusotmer'
else 'Loyal Customer'
 end as customer_segment,
count(*) as customer_count
from ( 
select customer_id, count(booking_id) as total_bookings
from bookings
group by customer_id 
)
as booking_counts
group by customer_segment;
 
 -- Average Spend per consumer (both bookings & in-park)
 select c.customer_id,
 c.first_name,
 c.city,
 round(coalesce(sum(b.total_amount),0) + coalesce(sum(p.amount),0), 2) as total_spend
 from customers c
 left join bookings b on c.customer_id = b.customer_id
 left join in_park_purchases p on c.customer_id = p.customer_id
 group by c.customer_id, c.first_name, c.city
 order by total_spend desc
 limit 20;
 
 -- MOST POPULAR ATTRACTIONS??
 select a.attraction_id,
 a.attraction_name,
 count(att.attendance_id) as total_visits,
 round(avg(att.time_spent_minutes), 1) as avg_time_spent_mins
 from attractions a
 join attendance att on a.attraction_id = att.attraction_id
 group by a.attraction_id, a.attraction_name, a.category
 order by total_visits desc;
 
 -- BUSIEST DAYS OF THE WEEK??
 select 
 dayname(visit_date) as day_of_week,
 count(booking_id) as total_visits
 from bookings
 group by day_of_week
 order by total_visits desc;
 
 -- Which in-park categories make most money??
 select 
 category,
 count(purchase_id) as transactions,
 round(sum(amount), 2) as total_revenue,
 round(avg(amount), 2) as avg_spend
 from in_park_purchases
 group by category
 order by total_revenue desc;
 
 
 
 



  
 
 
