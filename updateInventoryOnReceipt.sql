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
CREATE TRIGGER [dbo].[UpdateInventory]
   ON  Receipt_Of_Goods
   AFTER  INSERT,DELETE,UPDATE

AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   Declare @OrderLineID int;
   Declare @qty smallint;
   Declare @ItemUPC bigint;

    
	--delete (or modify)
    if exists (select * from deleted)
      begin       -- add the qty back to units on hand
       select @OrderLineID = Order_Line_ID, @qty = Qty_Received from deleted
	   select @ItemUPC = Item_UPC from PURCHASE_ORDER_LINE where Order_Line_ID = @OrderLineID
       update Item
         set Qty_In_Inventory = Qty_In_Inventory - @qty
         where item_upc = @itemUPC
         
      end
      
	  --insert (or modify)
	  if exists (select * from inserted)
	  begin   
      select @OrderLineID = Order_Line_ID, @qty = Qty_Received from inserted
	  select @ItemUPC = Item_UPC from PURCHASE_ORDER_LINE where Order_Line_ID = @OrderLineID

          update Item
            set Qty_In_Inventory = Qty_In_Inventory + @qty
             where item_upc = @itemUPC   

    end 

END
GO
