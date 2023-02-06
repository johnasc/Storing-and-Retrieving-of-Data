
#F. Using MySQL, write the queries to retrieve the following information:

USE `vmagazine_sales` ;

#1. List all the customer’s names, dates, and products or services used/booked/rented/bought by these customers in a range of two dates.

#explain
select 
concat(c.FirstName,' ',c.LastName) as 'Customer Name',
o.CreateDate as 'Sales Date',
p.ProdName as 'Product',
oi.Quantity as 'Total Products'
from customer c
join `order` o on o.CustomerId=c.CustomerId
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
where o.CreateDate between '2021-01-01' AND '2022-12-31'
order by 1,2 desc;

/*
COMMENT:
Considering the data we have, we can conclude that the query is optimal because the measured duration time of 0 seconds was achieved, 
the rows column on the Result Grid window have a one-to-one match asides the orders table and type is 'eq_ref' or 'ref' in most tables.
However, more optimization can be done by avoid using temporary tables created by order statement and also having less possible keys.
*/


#2. List the best three customers/products/services/places (you are free to define the criteria for what means “best”)

#Having defined total selling in euro as best

#explain
select 
p.ProdName as 'Best Products Sold',
round(sum(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100))),2) 'Total Sales (euro)'
from `order` o 
join `order_itens` oi on oi.OrderId=o.OrderId
join promotion pr on pr.PromoId=o.PromoId
join Product p on p.ProdId=oi.ProdId
group by p.ProdId
order by 2 desc
limit 3;

/*
COMMENT:
Considering the data we have, we can conclude that the query is optimal because the measured duration time of 0 seconds was achieved, 
the rows column on the Result Grid window have a one-to-one match asides the orders table and type is 'eq_ref' or 'ref' in most tables.
However, more optimization can be done by avoid using temporary tables created by order statement and also having less possible keys. It's also possible to add an index for the multiplication expression of Total Sales.
*/


#3. Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more years, as in the following example. This query only returns one record:
#PeriodOfSales TotalSales (euros) YearlyAverage (of the given period) MonthlyAverage (of the given period)

#explain
select 
'2021-01-01 to 2022-12-31' as PeriodOfSales,
round(sum(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100))),2) as 'TotalSales (euros)',
round(sum(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100)))/count(distinct year(o.CreateDate)),2) as 'YearlyAverage (of the given period)',
round(sum(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100)))/count(distinct concat(year(o.CreateDate),month(o.CreateDate))),2) as 'MonthlyAverage (of the given period)'
from `order` o 
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
join promotion pr on pr.PromoId=o.PromoId
where o.CreateDate between '2021-01-01' AND '2022-12-31';

/*
COMMENT:
Considering the data we have, we can conclude that the query is optimal because the measured duration time of 0 seconds was achieved, 
the rows column on the Result Grid window have a one-to-one match asides the orders table and type is 'eq_ref' or 'ref' in most tables.
The key on the order table is NULL, but according to the documentation, it hapens when MySQL finds no index to use for executing the query more efficiently.
*/

#4. Get the total sales/bookings/rents/deliveries by geographical location (city/country).

#explain
select 
co.CountryName as 'Country',
ci.CityName as 'City',
round(sum(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100))),2) 'Total Sales (euro)',
sum(oi.Quantity) 'Total Sales (Quantity)'
from `order` o
join promotion pr on pr.PromoId=o.PromoId
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
join store s on s.Storeid=o.StoreId
join address a on a.AddressId=s.AddressId
join city ci on ci.Cityid=a.Cityid
join country co on co.CountryId = ci.CountryId
group by ci.Cityid
order by 1,2;


/*
COMMENT:
Given that the number of joins needed to create the query, it is understandable to have some lag in performance. However, all joins was created using primary key and foreign key relationships. 
Additionally, the duration time was about 0 seconds. The rows column on the Result Grid window have a one-to-one match asides the store table and type is 'eq_ref' or 'ref' in most tables.
More optimization can be done by avoid using temporary tables created by order statement and also having less possible keys.
*/


#5. List all the locations where products/services were sold, and the product has customer’s ratings (Yes, your ERD must consider that customers can give ratings).

/*explain
select distinct 
co.CountryName as 'Country', 
ci.cityname as 'City', 
s.storename as 'Store Name'
from `order` o
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
join store s on s.Storeid=o.StoreId
join address a on a.AddressId=s.AddressId
join city ci on ci.Cityid=a.Cityid
join country co on co.CountryId = ci.CountryId
where o.rating is not null;*/

#explain
select 
co.CountryName as 'Country', 
ci.cityname as 'City', 
s.storename as 'Store Name'
from `order` o
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
join store s on s.Storeid=o.StoreId
join address a on a.AddressId=s.AddressId
join city ci on ci.Cityid=a.Cityid
join country co on co.CountryId = ci.CountryId
where o.rating is not null
group by co.CountryId,ci.Cityid,s.Storeid;

/*
COMMENT:
Given that the number of joins needed to create the query, it is understandable to have some lag in performance. However, all joins was created using primary key and foreign key relationships. 
Additionally, the duration time was about 0 seconds. The rows column on the Result Grid window have a one-to-one match asides the store table and type is 'eq_ref' or 'ref' in most tables.
The query is faster because we decided to use GROUP BY instead of DISTINCT.
More optimization can be done by avoid using temporary tables created by order statement and also having less possible keys.
*/

