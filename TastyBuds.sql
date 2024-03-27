 CREATE SCHEMA `tastybuds` ;
 Create TABLE `tastybuds`.`customers`(
  `customer_ID` INT NOT NULL,
  `First_name` VARCHAR(45) NOT NULL,
  `Lastt_name` VARCHAR(45) NOT NULL,
  `Age` INT NOT NULL,
  `Gender` VARCHAR(45) NOT NULL,
  `Email` VARCHAR(95) NULL,
  `Order_ID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`customer_ID`));
------------------------------------------------------------------------------------------------------
---------- CTE TO CALCULATE SALES
with sales (rowID,Date,time_of_day,orderid,Description,Quantity,price,amount,revenue_per_order,
revenue_per_timeofday,revenue_per_day,revenue_per_month)
as(
select o.rowID,o.Date,o.time,o.orderid,o.Description,o.Quantity,p.price,(p.price * o.Quantity) as amount,
SUM(p.price * o.Quantity) over (partition by o.orderid order by o.rowID,o.orderid) as revenue_per_order,
SUM(p.price * o.Quantity) over (partition by o.time,o.Date order by  o.rowID,o.Date) as revenue_per_timeofday,
SUM(p.price * o.Quantity) over (partition by o.Date order by  o.rowID,o.Date) as revenue_per_day,
SUM(p.price * o.Quantity) over (partition by  monthname(Date) order by  o.rowID,o.Date) as revenue_per_month
 from tastybuds.order as o
join tastybuds.product as p
on o.productID=p.productid
where o.orderid <> 'O0000'
order by o.rowID
)
SELECT *
FROM sales; --- REVENUE PER ORDER, TIME OF DAY,DAY,MONTH
--- REVENUE EACH DAY
select dayname(Date) as day,max(revenue_per_month) as revenue
from sales
group by dayname(Date)
order by revenue desc;
--- REVENUE EACH MONTH
select monthname(Date) as month,max(revenue_per_day) as revenue
from sales
group by monthname(Date);
--- AVERAGE REVENUE PER ORDER
select avg(revenue_per_order)
from sales ;           
         
--------------------------------------------------------------------------------------------------------
---------------- CUSTOMER DYMANICS
---- Average AGE
SELECT avg(age)
FROM tastybuds.customers;
---- AGE GROUPS
select
 case
  when age<= 25 then 'below 25'
  when age between 26 and 36 then'26-35'
  when age between 36 and 51 then '36-50'
  when age>50 then 'above 50'
  end as age_group,
count(orderID) as total_orders_made
from tastybuds.customers
group by
 case
  when age<= 25 then 'below 25'
  when age between 26 and 36 then'26-35'
  when age between 36 and 51 then '36-50'
  when age>50 then 'above 50'
  end
order by total_orders_made DESC;
--- GENDER 
select gender,count(*) as count_gender
FROM tastybuds.customers
group by gender
order by count_gender;
---------------------------------------------------------------------------------------------------------
--- TEMPORARY TABLE TO CALCULATE INGREDIENT EXPENSES
drop temporary table if exists supplies;
create temporary table  supplies
(
select `Ingredient ID`,Ingredient,Supplier,`Unit of measure`,`Order Amount`,`Price per unit`,
(`Order Amount`*`Price per unit`) as amount ,
sum(`Order Amount`*`Price per unit`) over (partition by Supplier order by Ingredient) 
as supplier_payment
from tastybuds.inventory 
);

select sum(amount)
from supplies; --- TOTAL INGREDIENT AMOUNT
select *
from supplies;
-------------------------------------------------------------------------------------------------------