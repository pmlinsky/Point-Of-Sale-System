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
CREATE PROCEDURE usp_insertReceivable
@PaymentID int,
@OrderID int,
@details PaymentDetailsTableType READONLY

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try
		begin transaction
			--insert into receivable
			insert into RECEIVABLE_PAYMENT(Payment_ID, Order_ID)
			values (@PaymentID, @OrderID)

			--insert into receivable details
			insert into PAYMENT_DETAILS(Payment_ID, Method_ID, Amount_Paid, Card_ID)
			select Payment_ID, Method_ID, Amount_Paid, Card_ID
			from @details

			--update EBT balance if applicable
			if exists (select ebt_id from ebt
			where (select card_id from @details) = ebt_id)
			begin
				merge EBT as targetTable
				using @details as source
				on (targetTable.ebt_id = source.card_id)
				when matched 
					then update set ebt_balance = ebt_balance - amount_paid;
			end


		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch

END
GO
