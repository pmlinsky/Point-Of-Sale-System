use POINT_OF_SALE
go

--1
select cust_fname +' '+ cust_lname as Cust_Name,
	Cust_Address, Cust_City, Cust_State, Cust_Zip, Cust_Phone
from Customer

--2
select product_category_desc, sum(sales_order_detail.unit_price * item_qty) as TotalSales
from product_category
inner join item 
	on item.product_category_id = product_category.Product_Category_ID
inner join sales_order_detail
	on sales_order_detail.item_upc = item.item_upc
group by product_category_desc

--3
select item.item_upc, item.item_name, (TotalSales - qty_ordered * unit_cost) as TotalIncome
from
(select item.item_upc, item_name, sum(sales_order_detail.unit_price * item_qty) as TotalSales
from item
inner join sales_order_detail
	on item.item_upc = sales_order_detail.item_upc
group by item.item_upc, item_name) as itemTotals
inner join item
	on itemTotals.item_upc = item.item_upc
inner join purchase_order_line
	on item.item_upc = purchase_order_line.item_upc

--4
select numSales.Item_UPC, item_name, vendor_name, NumSales
from
(select item.item_upc, item_name, count(sale_id) as NumSales
from item
inner join discount_item
	on item.item_upc = discount_item.item_upc
group by item.item_upc, item_name) as NumSales
inner join purchase_order_line
	on numsales.item_upc = purchase_order_line.item_upc
inner join purchase_order
	on purchase_order_line.order_id = purchase_order.order_id
inner join vendor
	on purchase_order.vendor_id = vendor.vendor_id

--5
select item_upc 
from discount_item
where '2020-01-12' between sale_start_date and sale_end_date

--6
select item_upc
from sales_order_detail
group by item_upc
having count(*) =
(select max(timespurchased) as MaxPurchased
from
(select item_upc, count(*) as TimesPurchased
from sales_order_detail
group by item_upc) as TimesPurchased)

--7
select emp_fname, emp_lname
from employee
inner join sales_order
	on sales_order.cashier_id = employee.emp_id
group by emp_fname, emp_lname
having sum(total_sale) = 
(select max(totalPurchased) as MaxPurchased
from
(select sum(total_sale) as totalPurchased
from sales_order
group by cashier_id) as totalPurchased)

--8
select vendor_id, count(distinct item_upc) as TotalItems
from purchase_order
inner join purchase_order_line
	on PURCHASE_ORDER.Order_ID = PURCHASE_ORDER_LINE.Order_ID
group by vendor_id

--9
select item.item_upc, item_name, vendor_name
from item
inner join purchase_order_line
	on PURCHASE_ORDER_LINE.Item_UPC = item.Item_upc
inner join purchase_order
	on PURCHASE_ORDER_LINE.Order_ID = PURCHASE_ORDER.Order_ID
inner join vendor
	on PURCHASE_ORDER.Vendor_ID = vendor.vendor_id
where Qty_In_Inventory < restock_level

--10
select item_name
from item
where unit_price =
(select max(unit_price)
from item)
