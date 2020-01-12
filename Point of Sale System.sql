use master
go

create database POINT_OF_SALE
use POINT_OF_SALE
go

create table EBT(
	EBT_ID int not null,
	EBT_Balance decimal(5,2) not null

	constraint [PK_EBT] primary key (ebt_id),
    constraint [CHK_BALANCE] check (ebt_balance >= 0)
)


create table CUSTOMER(
	Cust_ID int identity(1,1) not null,
	Cust_Fname varchar(20) not null,
	Cust_Lname varchar(30) not null,
	Cust_Address varchar(50) not null,
	Cust_City varchar(40) not null,
	Cust_State varchar(15) not null,
	Cust_Zip char(5) not null,
	Cust_Phone char(10) not null,
	EBT_ID int null,
	Cust_CreditCard bigint null

	constraint [PK_CUSTOMER] primary key (cust_id),
	constraint [UIX_EBT] unique (ebt_id),
	constraint [UIX_CC] unique (cust_creditcard),
	constraint [FK_CUST_EBT] foreign key (ebt_id) references EBT (ebt_id)
)

create table EMP_TYPE(
	Emp_Type_ID int identity(1,1) not null,
	Emp_Type_Desc varchar(45) not null

	constraint [PK_EMP_TYPE] primary key (emp_type_id),
	constraint [UIX_EMP_DESC] unique (emp_type_desc)
)

create table EMPLOYEE(
	Emp_ID int identity(1,1) not null,
	Emp_Fname varchar(20) not null,
	Emp_Lname varchar(30) not null,
	Emp_Address varchar(50) not null,
	Emp_City varchar(40) not null,
	Emp_State varchar(15) not null,
	Emp_Zip char(5) not null,
	Emp_Phone char(10) not null,
	Emp_SSN char(9) not null,
	Emp_DOB date not null,
	Emp_HireDate date not null
		constraint [DFLT_HIREDATE] default (getdate()),
	Emp_Type int not null

	constraint [PK_EMPLOYEE] primary key (emp_id),
	constraint [UIX_SSN] unique (emp_ssn),
	constraint [CHK_BirthDate] check
		(datediff(year, emp_dob, emp_hiredate) > 16),
	constraint [FK_EMP_EMP_TYPE] foreign key (Emp_Type) references Emp_Type (emp_type_id)
)

create table SALES_ORDER(
	Sales_Order_ID int not null,
	Date_Of_Sale date not null
		constraint [DFLT_SALE_DATE] default (getdate()),
	Cust_ID int null,
	Cashier_ID int not null,
	Total_Sale decimal(7,2) not null

	constraint [PK_SALES_ORDER] primary key (sales_order_id),
	constraint [FK_SALES_ORDER_CUST] foreign key (cust_id) references customer (cust_id),
	constraint [FK_SALES_ORDER_EMP] foreign key (cashier_id) references employee (emp_id),
	constraint [CHK_TOTAL_SALE] check (total_sale > 0)
)

create table RECEIVABLE_PAYMENT(
	Payment_ID int identity (1,1) not null,
	Order_ID int not null,
	Total_Paid decimal(7,2) not null

	constraint [PK_RECEIVABLE] primary key (payment_id),
	constraint [FK_PAYMENT_SALE] foreign key (order_id) references sales_order (sales_order_id),
	constraint [CHK_TOTAL_PAID] check (total_paid > 0)
)

create table PAYMENT_METHODS(
	Method_ID int identity(1,1) not null,
	Method_Desc varchar(10)

	constraint [PK_PAYMENT_METHODS] primary key (method_id)
)

create table PAYMENT_DETAILS(
	Payment_ID int not null,
	Method_ID int not null,
	Amount_Paid decimal(7,2) not null,
	Card_ID bigint null

	constraint [PK_PAYMENT_DETAILS] primary key (payment_id, method_id),
	constraint [FK_PAYMENT_DETAILS_METHODS] foreign key (method_id) references payment_methods (method_id),
	constraint [FK_PAYMENT_DETAILS_PAYMENT] foreign key (payment_id) references receivable_payment (payment_id),
	constraint [CHK_AMOUNT_PAID] check (amount_paid > 0)
)

create table SALES_ORDER_DETAIL(
	Sales_Order_Detail_ID int identity(1,1) not null,
	Item_UPC bigint not null,
	Sales_Order_ID int not null,
	Item_Qty int not null,
	On_Sale bit not null,
	Unit_Price decimal(5,2) not null

	constraint [PK_SALES_ORDER_DETAIL] primary key (sales_order_detail_id),
	constraint [FK_SALES_ORDER] foreign key (sales_order_id) references sales_order (sales_order_id),
	---------add foreign key to ITEM table later---------------
	constraint [CHK_SALE_ORDER_QTY] check (item_qty >= 1)
)

create table RETURNS(
	Sales_Order_Detail_ID int not null,
	Manager_ID int not null,
	Qty_Returned int not null

	constraint [PK_RETURN] primary key (sales_order_detail_id),
	constraint [FK_RETURN_SALES_DETAIL] foreign key (sales_order_detail_id) references Sales_Order_Detail (sales_order_detail_id),
	constraint [FK_RETURN_MANAGER] foreign key (manager_id) references Employee (emp_id),
	constraint [CHK_QTY] check (qty_returned > 0)
)

create table PRODUCT_CATEGORY (
	Product_Category_ID int identity(1,1) not null,
	Product_Category_Desc varchar(45) not null,
	constraint [PK_PRODUCT_CATEGORY] primary key(Product_Category_ID))

create table ITEM (
	Item_UPC bigint not null,
	Item_name varchar(45) not null,
	Unit_Price decimal(5, 2) not null,
	Product_Category_ID int not null,
	Taxable bit not null,
	Food bit not null,
	Qty_In_Inventory int not null,
	Restock_Level int not null,
	constraint [PK_ITEM] primary key(Item_UPC),
	constraint [FK_ITEM_PRODUCT_CATEGORY] foreign key (Product_Category_ID) 
	references PRODUCT_CATEGORY(product_category_id),
	constraint [CHK_UNIT_PRICE] check (unit_price > 0),
	constraint [CHK_QTY_IN_INVENTORY] check(qty_in_inventory >= 0),
	constraint [CHK_RESTOCK_LEVEL] check (restock_level >= 0))

create table TAX (
	Item_UPC bigint not null, 
	Date_Applied date not null
		constraint [DFLT_DATE_APPLIED] default (getdate()),
	Tax_Amount decimal(3,2) not null,
	constraint [PK_TAX] primary key(Item_UPC, Date_Applied),
	constraint [FK_TAX_ITEM] foreign key (Item_UPC) 
	references ITEM(Item_UPC),
	constraint [CHK_TAX_AMOUNT] check (tax_amount > 0))

create table DISCOUNT_ITEM (
	Sale_ID int identity(1,1) not null,
	Item_UPC bigint not null,
	Sale_Start_Date date not null,
	Sale_End_Date date not null,
	Qty_Limit int null,
	Discount_Price decimal(5, 2) not null,
	Min_Purchase decimal(5, 2) null,
	constraint [PK_DISCOUNT_ITEM] primary key (Sale_ID),
	constraint [FK_DISCOUNT_ITEM_ITEM] foreign key (Item_UPC)
	references ITEM(Item_UPC),
	constraint [CHK_QTY_LIMIT] check (qty_limit > 0),
	constraint [CHK_SALE_DATES] check (sale_end_date >= sale_start_date),
	constraint [CHK_DISCOUNT_PRICE] check (discount_price > 0))

create table VENDOR (
	Vendor_ID int identity(100,5) not null,
	Vendor_Name varchar(45) not null,
	Vendor_Phone char(10),
	constraint [PK_VENDOR] primary key (Vendor_ID))

create table PURCHASE_ORDER (
	Order_ID int identity(1,1) not null,
	Order_Date date not null,
	Vendor_ID int not null,
	Total_Due decimal(7, 2)
	constraint [PK_PURCHASE_ORDER] primary key (Order_ID),
	constraint [FK_PURCHASE_ORDER_VENDOR] foreign key (Vendor_ID)
	references VENDOR(Vendor_ID))

create table PURCHASE_ORDER_LINE (
	Order_Line_ID int identity(1,1) not null,
	Order_ID int not null,
	Item_UPC bigint not null,
	Qty_Ordered int not null,
	Unit_Cost decimal(5, 2),
	Subtotal as (unit_cost * qty_ordered)
	constraint [PK_PURCHASE_ORDER_LINE] primary key (Order_Line_ID), 
	constraint [FK_PURCHASE_ORDER_LINE_ITEM] foreign key (Item_UPC) 
	references ITEM(Item_UPC),
	constraint [FK_PURCHASE_ORDER_LINE_PURCHASE_ORDER] foreign key (Order_ID)
	references PURCHASE_ORDER(Order_ID),
	constraint [CHK_QTY_ORDERED] check (qty_ordered > 0),
	constraint [CHK_SUBTOTAL] check (subtotal > 0))

create table PAYABLE (
	Payment_ID int identity(1,1) not null,
	Order_ID int not null,
	Payment_Amount decimal(7, 2) not null,
	constraint [PK_PAYABLE] primary key (Payment_ID),
	constraint [FK_PAYABLE_PURCHASE_ORDER] foreign key (Order_ID)
	references Purchase_Order(Order_ID))

create table RECEIPT_OF_GOODS (
	Order_Line_ID int not null,
	Qty_Received int not null,
	constraint [PK_RECEIPT_OF_GOODS] primary key (Order_Line_ID),
	constraint [FK_RECEIPT_PURCHASE_ORDER_LINE] foreign key (Order_Line_ID)
	references PURCHASE_ORDER_LINE(Order_Line_ID),
	constraint [CHK_QTY_RECEIVED] check (qty_received >= 0))

alter table SALES_ORDER_DETAIL
add constraint [FK_SALES_ORDER_DETAIL] foreign key (item_upc) references ITEM (item_upc)

insert into PRODUCT_CATEGORY values('ALUMINUM')
insert into PRODUCT_CATEGORY values('BAKERY')
insert into PRODUCT_CATEGORY values('CANDY')
insert into PRODUCT_CATEGORY values('CHICKEN')
insert into PRODUCT_CATEGORY values('FISH')
insert into PRODUCT_CATEGORY values('FRUIT')
insert into PRODUCT_CATEGORY values('GROCERY')
insert into PRODUCT_CATEGORY values('MAGAZINES')
insert into PRODUCT_CATEGORY values('MEAT')
insert into PRODUCT_CATEGORY values('PAPERGOODS')

insert into EMP_TYPE values('Cashier')
insert into EMP_TYPE values('Manager')
insert into EMP_TYPE values('Stock Clerk')

insert into PAYMENT_METHODS values('CreditCard')
insert into PAYMENT_METHODS values('EBTCard')
insert into PAYMENT_METHODS values('Cash')
insert into PAYMENT_METHODS values('DebitCard')
insert into PAYMENT_METHODS values('Check')

create type SalesOrderDetailTableType as TABLE ( 
	Sales_Order_Detail_ID int identity(1,1),
	Item_UPC bigint,
	Sales_Order_ID int,
	Item_Qty int,
	On_Sale bit,
	Unit_Price decimal(5,2)
	primary key (sales_order_detail_id)
)

create type PurchaseOrderLineTableType as TABLE (
	Order_Line_ID int,
	Order_ID int,
	Item_UPC bigint,
	Qty_Ordered int,
	Unit_Cost int,
	Subtotal as unit_cost * qty_ordered
	primary key (order_line_id)

)

create type PaymentDetailsTableType as TABLE (
	Payment_ID int,
	Method_ID int,
	Amount_Paid decimal(7,2),
	Card_ID bigint
	primary key (payment_id)
)