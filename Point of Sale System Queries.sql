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
select item.item_upc, item.item_name, (qty_ordered * unit_cost - TotalSales) as TotalIncome
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
select item.item_upc, item_name, vendor_name, count(sale_id) as NumSales
from item
inner join purchase_order_line
	on item.item_upc = purchase_order_line.item_upc
inner join purchase_order
	on purchase_order_line.order_id = purchase_order.order_id
inner join vendor
	on purchase_order.vendor_id = vendor.vendor_id
inner join discount_item
	on item.item_upc = discount_item.item_upc
group by item.item_upc, item_name, vendor_name --make sure vendor name doesn't ruin the group by

--5
