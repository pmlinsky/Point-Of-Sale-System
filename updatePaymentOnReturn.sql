-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER updatePaymentOnReturn
   ON  Returns
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   Declare @SalesOrderDetailID int;
   Declare @qty smallint;
   Declare @ItemUPC bigint;
   Declare @DatePurchased date;
   Declare @SalesOrderID int;
   Declare @TaxToRefund decimal(3,2);
   Declare @UnitPrice decimal(5,2);

	  begin          
	   select @SalesOrderDetailID = Sales_Order_Detail_ID, @qty = qty_returned from deleted
	   select @ItemUPC = Item_UPC, @SalesOrderID = sales_order_id, @UnitPrice = Unit_Price from SALES_ORDER_DETAIL 
			where Sales_Order_Detail_ID = @SalesOrderDetailID
	   select @DatePurchased = Date_Of_sale from SALES_ORDER where Sales_order_id = @SalesOrderID
	  
	  --if taxable, refund tax
	  if exists(select item_upc from tax where item_upc = @itemUPC)
		begin
			select @TaxToRefund = max(tax_amount) from tax where date_applied <= @DatePurchased
			select @TaxToRefund = @TaxToRefund * @qty
			update RECEIVABLE_PAYMENT
			set total_paid = total_paid - @TaxToRefund
			where order_id = @SalesOrderID
		end
	  
	  --refund
	  update RECEIVABLE_PAYMENT
			set total_paid = total_paid - (@UnitPrice * @qty)
			where order_id = @SalesOrderID
    end
END
GO

