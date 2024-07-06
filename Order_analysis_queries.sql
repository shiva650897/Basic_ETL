/* 
create table df_orders (

[order_id] int primary key,
[order_date] date,
[ship_mode] varchar(20),
[segment] varchar(20),
[country] varchar(20),
[city] varchar(20),
[state] varchar(20),
[postal_code] varchar(20),
[region] varchar(20),
[category] varchar(20), 
[sub_category] varchar(20),
[product_id] varchar(50),
[quantity] int,
[discount] decimal (7,2),
[sale_price] decimal (7,2),
[profit] decimal(7,2));
*/

select * from df_orders;

--1) find top 10 highest revenue generating products

select top 10 product_id, sum(sale_price * quantity) as sales
from df_orders
group by product_id
order by sales desc;

--2) Find top 5 highest selling products in each region. (cte --> commmon table expression)
with cte as (
select region, product_id, sum(sale_price * quantity) as sales 
from df_orders
group by region, product_id) 
select * from (
select *, ROW_NUMBER() over(partition by region order by sales desc) as row_num
from cte) A
where row_num<=5;

--3) Find month over month growth comparison for 2022 and 2023 eg: jan 2022 vs jan 2023
with cte as (
select year(order_date) as yr, month(order_date) as mt, sum(sale_price * quantity) as sales 
from df_orders
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)
select mt,
sum(case when yr=2022 then sales else 0 end) as sales_2022,
sum(case when yr=2023 then sales else 0 end) as sales_2023
from cte
group by mt
order by mt;

--4) for each category which month had highest sales
with cte as (
select category, format(order_date,'yyyyMM') as order_yr_mt,
sum(sale_price * quantity) as sales
from df_orders
group by category, format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rm
from cte) A where rm=1;

--5) which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
select sub_category, year(order_date) as yr, sum(sale_price * quantity) as sales 
from df_orders
group by sub_category, year(order_date)
--order by year(order_date), month(order_date)
),
cte2 as (select sub_category,
sum(case when yr=2022 then sales else 0 end) as sales_2022,
sum(case when yr=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *,(sales_2023-sales_2022) *100 / sales_2022 as growth
from cte2
order by (sales_2023-sales_2022) *100 / sales_2022 desc;