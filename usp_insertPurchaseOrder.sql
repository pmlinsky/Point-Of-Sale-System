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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_insertPurchaseOrder
@Order_ID int,
@Order_Date date,
@Vendor_ID int,
@details PurchaseOrderLineTableType READONLY

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 begin try
    begin transaction
	--first insert the order into the purchase order table
  insert into purchase_order(Order_ID,Order_Date, Vendor_ID)
  values (@Order_ID, @Order_Date, @Vendor_ID)
   
	  
  --then insert the related order details into the purchase_order_line table
  insert into purchase_order_line (Order_Line_ID, Item_UPC, Order_ID, Qty_Ordered, Unit_Cost)
   select Order_Line_ID, Item_UPC, Order_ID, Qty_Ordered, Unit_Cost 
   from @details 

  --now update the purchase_order total
  update PURCHASE_ORDER
    set Total_Due = total_due + 
	     (select sum(qty_ordered * unit_cost) from @details)
     where order_id = @Order_ID;

    
     commit transaction
  end try
  begin catch
     
	   rollback;
	   throw;
  end catch
end

