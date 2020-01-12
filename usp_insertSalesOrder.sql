-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Adina & Penina
-- Create date: 1/12/2020
-- =============================================
CREATE PROCEDURE usp_insertSalesOrder
@SalesOrderID int,
@DateOfSale date,
@CustID int,
@CashierID int,
@OrderDetails SalesOrderDetailTableType READONLY

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Insert statements for procedure here
  begin try
    begin transaction
	--first insert the order into the sales order table
  insert into sales_order(Sales_Order_ID,date_of_sale,cust_id, cashier_id)
  values (@SalesOrderID, @DateOfSale,@CustID, @CashierID)
   
	  
  --then insert the related order details into the sales_order_detail table
  insert into sales_order_detail (Sales_Order_Detail_ID, Item_UPC, Sales_Order_ID, Item_Qty, On_Sale, Unit_Price)
   select Sales_Order_Detail_ID, Item_UPC, Sales_Order_ID, Item_Qty, On_Sale, Unit_Price 
   from @orderDetails 

  --now update the item table , lower the inventory levels
  merge Item  as targetTable
  using @orderDetails  As Source
  on (targetTable.item_upc =Source.item_upc)
  when matched 
    then update set targetTable.qty_in_inventory =
	              targetTable.qty_in_inventory - source.item_qty;

  --now update the sales_order total
  update sales_order
    set total_sale = total_sale + 
	     (select sum(item_qty * unit_price) from @orderdetails)
     where sales_order_id = @SalesOrderID;

    
     commit transaction
  end try
  begin catch
     
	   rollback;
	   throw;
  end catch
end
