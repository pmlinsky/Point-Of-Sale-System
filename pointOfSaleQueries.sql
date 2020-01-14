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

--11
select EBT.EBT_ID, EBT.EBT_Balance, Cust_Fname, Cust_Lname, max(date_of_sale) as dateLastUsed
from customer inner join EBT
 on EBT.EBT_ID = CUSTOMER.EBT_ID
  inner join payment_details 
  on Card_ID = EBT.EBT_ID
	inner join RECEIVABLE_PAYMENT
	on PAYMENT_DETAILS.Payment_ID = RECEIVABLE_PAYMENT.Payment_ID
	  inner join SALES_ORDER
	   on Order_ID = Sales_Order_ID
	     group by EBT.EBT_ID, EBT.EBT_Balance, Cust_Fname, Cust_Lname

--12
--what defines generated most sales
select customer.cust_id, max(sales_order_id) as mostOrders
from CUSTOMER inner join SALES_ORDER
on customer.cust_id = sales_order.Cust_ID
group by customer.cust_id

--13
select Product_Category_ID, sum(subtotal) as MoneyGenerated
from item inner join PURCHASE_ORDER_LINE
  on ITEM.Item_UPC = PURCHASE_ORDER_LINE.Item_UPC
    group by Product_Category_ID 
	having sum(subtotal) = 
	(select max(MoneyGenerated) from
     (select Product_Category_ID, sum(subtotal) as MoneyGenerated
	 from item inner join PURCHASE_ORDER_LINE
     on ITEM.Item_UPC = PURCHASE_ORDER_LINE.Item_UPC
	 group by Product_Category_ID)as query)
	
--14
select vendor.vendor_id, vendor_name, vendor_phone, Item_name
from vendor inner join purchase_order
on VENDOR.Vendor_ID = PURCHASE_ORDER.Vendor_ID
  inner join PURCHASE_ORDER_LINE
  on PURCHASE_ORDER.Order_ID = PURCHASE_ORDER_LINE.Order_ID
    inner join item 
	on PURCHASE_ORDER_LINE.Item_UPC = item.Item_UPC

--15
select * 
from SALES_ORDER
where cust_id is null

--16
select vendor_id
from vendor
where vendor_id not in 
	(select distinct vendor_id 
	from PURCHASE_ORDER
	where month(order_date) = month(getDate()))

--17
select cust_id
from customer 
	where cust_id not in 
	(select distinct cust_id
	from SALES_ORDER
	where datediff(day, date_of_sale, getDate()) <= 30) 

--18
select cust_fname, cust_lname
from 
((select distinct cust_id
from SALES_ORDER_DETAIL inner join item
  on SALES_ORDER_DETAIL.item_upc = item.Item_UPC
    inner join SALES_ORDER
    on SALES_ORDER_DETAIL.Sales_Order_ID = SALES_ORDER.Sales_Order_ID
	inner join PRODUCT_CATEGORY
	on PRODUCT_CATEGORY.Product_Category_ID = item.Product_Category_ID
    where Product_Category_Desc = 'MEAT')
	intersect
		(select distinct cust_id
               from SALES_ORDER_DETAIL inner join item
               on SALES_ORDER_DETAIL.item_upc = item.Item_UPC
                inner join SALES_ORDER
                on SALES_ORDER_DETAIL.Sales_Order_ID = SALES_ORDER.Sales_Order_ID
				inner join PRODUCT_CATEGORY
				on PRODUCT_CATEGORY.Product_Category_ID = item.Product_Category_ID
                where Product_Category_Desc = 'FISH')) as intersects
inner join customer on customer.cust_Id = intersects.cust_id 

 --19
 select vendor.vendor_name
 from 
 (select vendor.vendor_id, product_category_id
 from vendor
 inner join purchase_order
	on purchase_order.Vendor_ID = vendor.vendor_id
 inner join purchase_order_line
	on purchase_order_line.Order_ID = purchase_order.Order_ID
 inner join item
	on item.item_upc = purchase_order_line.Item_UPC) as vendorCategories
 inner join vendor
	on vendorCategories.Vendor_ID = vendor.Vendor_ID
 inner join
 (select item.Product_Category_ID from item
 inner join purchase_order_line
	on purchase_order_line.item_upc = item.item_upc
 inner join purchase_order
	on purchase_order.Order_ID = purchase_order_line.order_id
 inner join vendor
	on vendor.Vendor_ID = purchase_order.vendor_id
 where vendor.vendor_id = 100) as vendor100items
 on vendor100items.Product_Category_ID = vendorCategories.Product_Category_ID
 group by vendor.vendor_name
 having count(*) = 
 (select count(Product_Category_ID) from item
 inner join purchase_order_line
	on purchase_order_line.item_upc = item.item_upc
 inner join purchase_order
	on purchase_order.Order_ID = purchase_order_line.order_id
 inner join vendor
	on vendor.Vendor_ID = purchase_order.vendor_id
 where vendor.vendor_id = 100)

--20
select item.item_upc, count(*) as amtOfTimesReturned
from item inner join SALES_ORDER_DETAIL
  on item.Item_UPC = SALES_ORDER_DETAIL.Item_UPC
    inner join RETURNS
    on SALES_ORDER_DETAIL.Sales_Order_detail_ID = RETURNS.Sales_Order_Detail_ID
	group by item.item_upc

--21
select sum(Total_Paid) as totalSales
from item inner join sales_order_detail
 on item.Item_UPC = SALES_ORDER_DETAIL.Item_UPC
   inner join RECEIVABLE_PAYMENT
   on SALES_ORDER_DETAIL.Sales_Order_ID = RECEIVABLE_PAYMENT.Order_ID
     inner join PAYMENT_DETAILS
     on PAYMENT_DETAILS.Payment_ID = RECEIVABLE_PAYMENT.Payment_ID
 where method_id = 2
union
(select sum(Total_Paid) as totalSales
from item inner join sales_order_detail
 on item.Item_UPC = SALES_ORDER_DETAIL.Item_UPC
   inner join RECEIVABLE_PAYMENT
   on SALES_ORDER_DETAIL.Sales_Order_ID = RECEIVABLE_PAYMENT.Order_ID
     inner join PAYMENT_DETAILS
     on PAYMENT_DETAILS.Payment_ID = RECEIVABLE_PAYMENT.Payment_ID
 where food = 1
 intersect
 select sum(Total_Paid) as totalSales
from item inner join sales_order_detail
 on item.Item_UPC = SALES_ORDER_DETAIL.Item_UPC
   inner join RECEIVABLE_PAYMENT
   on SALES_ORDER_DETAIL.Sales_Order_ID = RECEIVABLE_PAYMENT.Order_ID
     inner join PAYMENT_DETAILS
     on PAYMENT_DETAILS.Payment_ID = RECEIVABLE_PAYMENT.Payment_ID
 where method_id != 2)