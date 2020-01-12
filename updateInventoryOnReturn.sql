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
CREATE TRIGGER updateInventoryOnReturn
   ON  Returns
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   Declare @SalesOrderDetailID int;
   Declare @qty smallint;
   Declare @ItemUPC bigint;

    
	--delete (or modify)
    if exists (select * from deleted)
      begin       
       select @SalesOrderDetailID = Sales_Order_Detail_ID, @qty = qty_returned from deleted
	   select @ItemUPC = Item_UPC from SALES_ORDER_DETAIL where Sales_Order_Detail_ID = @SalesOrderDetailID
       update Item
         set Qty_In_Inventory = Qty_In_Inventory - @qty
         where item_upc = @itemUPC
         
      end
      
	  --insert (or modify)
	  if exists (select * from inserted)
	  begin   
      select @SalesOrderDetailID = Sales_Order_Detail_ID, @qty = qty_returned from inserted
	  select @ItemUPC = Item_UPC from SALES_ORDER_DETAIL where Sales_Order_Detail_ID = @SalesOrderDetailID
	  
	  if @qty > (select item_qty from sales_order_detail where @SalesOrderDetailID = Sales_Order_Detail_ID)
		begin;
			throw 60010, 'cannot return more than original purchase', 1;
		end
	  else
		begin
          update Item
            set Qty_In_Inventory = Qty_In_Inventory + @qty
             where item_upc = @itemUPC  
		end
    end
END
GO
