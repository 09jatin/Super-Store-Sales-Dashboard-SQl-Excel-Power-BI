-------------------------------------------
-- Data Understanding
-- Purpose: Preview the dataset and verify its structure.
--------------------------------------------

select * 
from super_store
limit 10;

select count(*) as total_records
from super_store;


---------------------------------------
-- Key Performance Indicators (KPI)
-- Purpose: Calculate overall business performance metrics.
---------------------------------------

select 
count(distinct order_id) as total_orders,
count(distinct customer_name) as total_customer,
sum(sales) as total_sales,
sum(profit) as total_profit,
sum(quantity) as total_quantity,
round(avg(sales),2) as avg_order_value,
round(
sum(profit) *100.0/
nullif(sum(sales),0),
2
) as profit_margin,
round(avg(shipping_speed),2) as avg_shipping_days
from super_store;

------------------------------
-- Sales & Profit Analysis
-- Purpose: Analyze category-wise sales and profitability.
------------------------------

select
category,
count(distinct order_id) as total_orders,
sum(quantity) as total_quantity,
sum(sales) as total_sales,
sum(profit) as total_profit,
round(
sum(profit) *100.0/
nullif(sum(sales),0),
2
) as profit_margin,
round(avg(discount),2) as avg_discount,
rank()over(
order by sum(profit)desc)as profit_rank

from super_store
group by category
order by total_sales desc;

------------------------
-- Region Performance 
-- Purpose: Compare sales and profit across regions.
------------------------

select
region,
count(*) as total_orders,
sum(sales) as total_sales,
sum(profit)as total_profit,
round(
sum(sales) * 100.0 /
sum(sum(sales))over(),2) as sales_contribution_percentage,
round(sum(profit) * 100.0 /
nullif(sum(sales),0),2) as profit_margin

from super_store
group by region
order by total_sales desc;

---------------------------------
-- Profit vs Loss
-- Purpose: Compare profitable and loss-making orders.
---------------------------------

select
profit_status,
count(*) as total_orders,
sum(sales) as total_sales,
sum(profit)as total_profit,
round(avg(profit_margin),2) as avg_profit_margin
from super_store
group by profit_status
order by total_profit desc;

-------------------------------------
-- Discount Analysis
-- Purpose: Analyze the impact of discounts on profitability.
-------------------------------------
select
discount_level,
count(*)total_orders,
sum(sales)total_sales,
sum(profit)total_profit,
round(avg(discount),2)avg_discount,
round(
sum(profit)*100.0/
nullif(sum(sales),0),2)profit_margin
from super_store
group by discount_level
order by profit_margin desc;

---------------------------------------
-- Shipping Impact
-- Purpose: Evaluate shipping performance and customer preference.
--------------------------------------

select
shipping_category,
count(*) as total_orders,
sum(profit)total_profit,
round(avg(sales),2)as avg_sales,
round(avg(profit),2)as avg_profit,
round(avg(shipping_cost),2) as avg_shipping_cost,
round(avg(shipping_speed),2)as avg_shipping_days
from super_store
group by shipping_category
order by total_profit desc;

-----------------------------------------
-- Monthly Trend
-- Purpose: Track monthly sales performance over time.
-----------------------------------------

select
to_char(order_date, 'YYYY-MM') as month,
to_char(order_date,'Month') as month_name,
sum(sales) as total_sales,
sum(profit) as total_profit
from super_store
group by to_char(order_date,'YYYY-MM'),
to_char(order_date,'Month')
order by month;

-----------------------
-- Yearly Sales
-- Purpose: Measure year-over-year business growth.
-----------------------

with yearly_sales as(
select
year,
sum(sales) as total_sales,
sum(profit) as total_profit
from super_store
group by year
)
select
year,
total_sales,
totaL_profit,
coalesce(lag(total_sales)over(order by year),0) as previous_sales,
coalesce(
round(
100.0 * (total_sales - lag(total_sales)over(order by year))
/
nullif(lag(total_sales)over(order by year),0),
2
),0.00
) as sales_growth_percentage
from yearly_sales;

-----------------------------
-- Loss Making Product
-- Purpose: Identify products generating the highest losses.
-----------------------------

select
product_name,
sum(profit) as total_profit
from super_store
group by product_name
having sum(profit)<0
order by total_profit asc;

------------------------
-- Product Ranking
-- Purpose: Rank products based on sales within each category.
------------------------

with ranked_product as 
(
select
category,
product_name,
sum(sales) as total_sales,
sum(profit)as total_profit,
dense_rank()over(partition by category order by sum(sales)desc)as product_rank
from super_store
group by category,product_name
)
select
category,
product_name,
total_sales,
total_profit,
product_rank

from ranked_product
where product_rank <= 5
order by category,product_rank;


---------------------------
-- Order Segmentation
-- Purpose: Compare sales performance across order segments.
---------------------------

select
sales_category,
count(*) as total_orders,
sum(sales) as total_sales,
sum(profit) as total_profit,
round(avg(profit_margin),2)  as avg_margin
from super_store
group by sales_category
order by total_sales desc;

------------------------
-- Running Total
-- Purpose: Calculate cumulative sales over time.
------------------------

with monthly_sales as (
select
year,
month_number,
month,
sum(sales) monthly_sales
from super_store
group by year,month_number,month)
select
year,
month_number,
month,
monthly_sales,
sum(monthly_sales)over(order by year,month_number)
as cumulative_sales
from monthly_sales
order by year,month_number;

-------------------------------------
-- Category Analysis By Country
-- Purpose: Compare category performance across countries.
-------------------------------------

select
country,
category,
sum(sales) as total_sales
from super_store
group by category,country
order by total_sales desc;

--------------------------------------
-- Category Analysis By Segment
-- Purpose: Compare category performance across customer segments.
--------------------------------------
select
segment,
category,
sum(sales)as total_sales
from super_store
group by category,segment
order by total_sales desc;

-----------------------------
-- Top vs Loss Product
-- Purpose: Compare the best and worst-performing products.
-----------------------------
select
product_name,
sum(sales) total_sales,
sum(profit) total_profit,
case
when sum(profit)<0 then 'Loss Product' else 'Profitable Product'
end as product_status
from super_store
group by product_name
order by total_sales desc;

--------------------------
-- Discount vs Profit
-- Purpose: Evaluate how discounts affect profit.
--------------------------
select
discount_level,
category,
count(*)as total_orders,
sum(sales)as total_sales,
sum(profit)as total_profit,
round(sum(profit)*100.0/
nullif(sum(sales),0),2
) as profit_margin
from super_store
group by discount_level,category
order by category,discount_level;

-------------------------
-- Top 10 Product
-- Purpose: Identify the highest-selling products.
-------------------------

with product_sales as (
select
product_name,
sum(sales)total_sales,
sum(profit)total_profit
from super_store
group by product_name
)
select
product_name,
total_sales,
total_profit,
round(100*total_sales/sum(total_sales)over(),2) as contribution_percentage,
rank()over(order by total_sales desc)as sales_rank
from product_sales
order by total_sales desc
limit 10;

--------------------------------------
-- Customer Segment Profitability
-- Purpose: Measure profitability across customer segments.
--------------------------------------

select
segment,
count(distinct customer_name) total_customer,
sum(sales)as total_sales,
sum(profit)as total_profit,
round(sum(profit)/nullif(sum(sales),0)*100,2)
profit_margin 
from super_store
group by segment;

---------------------------------
-- High Sales But Low Profit
-- Purpose: Identify products with high sales but low profit.
---------------------------------

with product_summary as (
select
product_name, 
sum(sales)total_sales,
sum(profit)total_profit
from super_store
group by product_name
)
select 
product_name,
total_sales,
total_profit,

round(total_profit / nullif(total_sales, 0)* 100, 2) as profit_margin_percent
from product_summary
where total_sales >(select avg(total_sales)from product_summary)
and total_profit <(select avg(total_profit)from product_summary)
order by total_sales desc;

----------------------------------------
-- Top 5 Customers In Every Market
-- Purpose: Identify the highest-value customers in each market.
----------------------------------------

with customer_sales as (
select
market,
customer_name,
sum(sales) total_sales,
sum(profit) total_profit,
dense_rank()over
(partition by market order by sum(sales)desc) as customer_rank
from super_store
group by market,customer_name)

select
market,
customer_name,
total_sales,
total_profit,
customer_rank
from customer_sales
where customer_rank <= 5
order by 
market,
customer_rank;

---------------------------------------------
-- Sales Contribution Of Every Product
-- Purpose: Measure each product's contribution to total sales.
---------------------------------------------

select
product_name,
sum(sales) total_sales,
round(100*sum(sales)/sum(sum(sales))over(),2)  as contribution_percentage
from super_store
group by product_name
order by total_sales desc;

--------------------------------
-- Running Profit By Date
-- Purpose: Calculate cumulative profit over time.
--------------------------------
select 
order_date,
sum(profit)total_profit,
sum(sum(profit))over(
order by order_date) as running_total
from super_store
group by order_date
order by order_date;

----------------------------------
-- Category Wise Market Share
-- Purpose: Measure the market share of each category.
----------------------------------

select
category,
sum(sales) total_sales,
round(sum(sales)*100.0/sum(sum(sales))over(),2) as market_share
from super_store
group by category
order by total_sales desc;

---------------------------------------------
-- Best Selling Product In Every Region
-- Purpose: Identify the top-selling product in each region.
---------------------------------------------

with ranked_products as (
select
region,
product_name,
sum(profit)total_profit,
round(avg(profit),2)avg_profit,
sum(sales)  total_sales,
dense_rank()over(partition by region order by sum(sales)desc)sales_rank
from super_store
group by region,product_name
)
select 
region,
product_name,
total_sales,
total_profit,
avg_profit
from ranked_products
where sales_rank = 1
order by region;

-----------------------------------------
-- Weekend vs Weekday Performance
-- Purpose: Compare sales between weekdays and weekends.
-----------------------------------------

select
day_type,
count(*) Total_orders,
sum(sales)total_sales,
sum(profit)total_profit,
round(avg(sales),2)avg_sales
from super_store
group by day_type;

-----------------------------------
-- Season Performance
-- Purpose: Compare business performance across seasons.
-----------------------------------

select
season,
sum(sales)total_sales,
sum(profit)total_profit,
round(sum(profit)*100.0/
nullif(sum(sales),0),
2)profit_margin
from super_store
group by season
order by total_sales desc;

---------------------------------------
-- Highest Profit Margin Products
-- Purpose: Identify products with the highest profit margins.
---------------------------------------

with product_margin as (
select
product_name,
category,
sum(sales)total_sales,
sum(profit)total_profit,
round(sum(profit)*100.0/nullif(sum(sales),0),2) as profit_margin
from super_store
group by product_name,category
)
select
product_name,
category,
total_sales,
total_profit,
profit_margin
from product_margin
where profit_margin > ( select avg(profit_margin)from product_margin)
order by profit_margin desc;

-------------------------------------------
-- Customer Purchase Frequency 
-- Purpose: Analyze customer purchasing behavior.
-------------------------------------------

select
customer_name,
count(distinct order_id)total_orders,
sum(quantity)total_quantity,
sum(sales)total_sales,
round(avg(sales),2) as avg_order_value,
min(order_date) as first_purchase,
max(order_date)as last_purchase,
max(order_date)-min(order_date)as customer_lifespan
from super_store
group by customer_name
order by total_sales desc;

----------------------------------
-- Pareto Analysis
-- Purpose: Identify products contributing to 80% of sales.
----------------------------------

with sales_cte as (
select 
product_name,
sum(sales) total_sales
from super_store
group by product_name
),
pareto as 
(
select 
product_name,
total_sales,
sum(total_sales)
over(order by total_sales desc)
running_sales,
sum(total_sales)
over()overall_sales from sales_cte)
select
product_name,
total_sales,
round(running_sales*100.0/overall_sales,2) cumulative_percentage
from pareto
where running_sales*100.0/overall_sales<=80
order by total_sales desc;

---------------------------------
-- Monthly Growth By Region 
-- Purpose: Compare monthly sales growth across regions.
---------------------------------

with monthly_sales as (
select
region,
year,
month_number,
sum(sales) as total_sales
from super_store
group by  region, year, month_number
)
select
region,
year,
month_number,
total_sales,
lag(total_sales)over (
partition by  region
order by year, month_number
) as previous_month,
round(
100.0 * (
total_sales -
lag(total_sales) over (
partition by region
order by  year, month_number
)
) /
nullif(
            
lag(total_sales) over (
partition by region
order by  year, month_number
),
0
),
2
) as growth_percentage
from monthly_sales
order by  region, year, month_number;

----------------------------------------
-- Profit Distribution (Quartiles)
-- Purpose: Group products into profit quartiles.
----------------------------------------

with product_profit as (
select
product_name,
sum(profit)total_profit
from super_store
group by product_name
)
select
product_name,
total_profit,
ntile(4)over(
order by total_profit
) as profit_quartile
from product_profit;

----------------------------------
-- Sales Outliers Detection 
-- Purpose: Detect unusual sales transactions.
----------------------------------

with stats as (
select 
avg(sales)avg_sales,
stddev(sales)std_sales
from super_store
)
select
s.product_name,
s.sales,
s.quantity,
round((s.sales - st.avg_sales) / st.std_sales,2)z_score
from super_store s
cross join stats st 
where abs((s.sales-st.avg_sales)/st.std_sales)>3;


---------------------------------
-- Best Month For Every Year
-- Purpose: Identify the best-performing month each year.
---------------------------------

with monthly_sales as (
select
month,
year,
month_Number,
sum(sales)total_sales,
rank()over( partition by year order by sum(sales)desc)sales_rank
from super_store
group by month,month_Number,year
)
select 
year,
month,
month_number,
total_sales
from monthly_sales
where sales_rank =1
order by year;

-------------------------------------
-- Category And Segment Matrix
-- Purpose: Summarize category and segment performance.
-------------------------------------

select
coalesce(category,'Grand Total')as category,
coalesce(segment,'All Segment') as segment,
sum(sales)total_sales,
sum(profit)total_profit,
round(sum(profit)*100.0/
nullif(sum(sales),0),2
) as profit_margin
from super_store
group by rollup(category,segment)
order by category,segment;

--------------------------------
-- Bottom 10 Products
-- Purpose: Identify the lowest-selling products.
--------------------------------

select
product_name,
sum(sales) as total_sales,
sum(profit) as total_profit
from super_store
group by  product_name
order by total_sales asc
limit 10;


----------------------------------------
--Order Priority Analysis
-- Purpose: Analyze business performance by order priority
----------------------------------------
select
order_priority,
count(distinct order_id) as total_orders,
sum(sales) as total_sales,
sum(profit)as total_profit,
round(sum(profit) * 100.0/
nullif(sum(sales),0),2) as profit_margin,
round(avg(shipping_cost),2) as avg_shipping_cost,
round(avg(shipping_speed),2) as avg_delivery_days
from super_store
group by order_priority
order by total_sales desc;

--------------------------------------------------
-- State Performance Analysis 
-- Purpose: Compare sales and profit across states.
--------------------------------------------------

select
state,
sum(sales) as total_sales,
sum(profit) as total_profit,
count(distinct order_id) as total_orders,
round(sum(profit)*100.0/
nullif(sum(sales),0),2) as profit_margin,
rank()over(order by sum(sales) desc
) as sales_rank
from super_store
group by state
order by sales_rank;

-------------------------------------------------
-- Sub-Category Performance
-- Purpose: Compare sub-category performance.
-------------------------------------------------

select
category,
sub_category,
sum(sales) as total_sales,
sum(profit)as total_profit,
round(sum(profit) * 100.0/
nullif(sum(sales),0),2) as profit_margin,
dense_rank()over(partition by category
order by sum(sales)desc) as sub_category_rank
from super_store
group by category,sub_category
order by category,sub_category_rank;

-------------------------------------------------
-- Quarterly Sales Analysis
-- Purpose: Compare quarterly business performance.
--------------------------------------------------

with ranked_sales as(
select
year,
quater,
sum(sales) as total_sales,
sum(profit) as total_profit,
round(sum(profit)* 100.0 /
nullif(sum(sales),0),2) as profit_margin,
rank()over(partition by year
order by sum(sales)desc) as sales_rank
from super_store
group by year,quater
)
select
year,
quater,
total_sales,
total_profit,
profit_margin,
case when sales_rank = 1 then 'Best Quater' else 'Normal' end as quater_status
from ranked_sales
order by year,Quater;


----------------------------------------------------
-- Average Selling Price Analysis
-- Purpose: Analyze product pricing across categories.
----------------------------------------------------

select
category,
round(avg(average_selling_price),2) as avg_selling_price,
min(average_selling_price) as lowest_price,
max(average_selling_price) as highest_price,
stddev(average_selling_price) as price_variation
from super_store
group by category
order by avg_selling_price desc;


-------------------------------------------------
-- Shipping Mode Performance
-- Purpose: Compare Bussines Performnce Acorss Shipping Modes
-------------------------------------------------

select
ship_mode,
count(distinct order_id) as total_orders,
sum(sales) as total_sales,
sum(profit) as total_profit,
round(
sum(profit)* 100.0/
nullif(sum(sales),0),2) as profit_margin,
round(avg(shipping_cost),2) as avg_shipping_cost,
round(avg(shipping_speed),2) as avg_delivery_days
from super_store
group by ship_mode
order by total_orders desc;


--------------------------------------
--Project Summary
--------------------------------------
--------------------------------
-- Key Business Insights
--------------------------------

-- The Central region is the strongest revenue contributor, while some regions have significant growth potential.

-- Higher discounts have a significant negative impact on profit margins

-- A small number of products generate most of the company's revenue, following the Pareto principle.

-- Technology is the leading revenue-generating category and a key driver of overall business performance

-- Customer purchasing behavior is higher on weekdays and peaks during November and December.

-- Standard Class is the most preferred shipping mode due to its balance of cost and convenience.

-- Repeat customers contribute significantly to business revenue and should be retained through loyalty programs.

-- Seasonal demand peaks during Autumn, highlighting the importance of inventory planning.

-- High-value orders generate better profit margins than low-value orders.

-- Business performance shows consistent year-over-year growth.

--------------------------------------------
-- Business Recommendations
--------------------------------------------

-- Optimize discount strategies to improve profitability.

-- Prioritize inventory for top-selling and high-margin products.

-- Increase marketing efforts in underperforming regions.

-- Launch weekend promotions to improve weekend sales.

-- Strengthen customer loyalty programs to retain high-value customers.

-- Improve Standard Class delivery efficiency while promoting premium shipping options.

-- Plan inventory and marketing campaigns before peak seasons.

-- Review pricing, procurement costs, and discount strategies for consistently loss-making products.
