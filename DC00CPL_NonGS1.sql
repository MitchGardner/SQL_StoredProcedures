USE [DC00CPL]
GO
/****** Object:  StoredProcedure [dbo].[non_GS1]    Script Date: 3/22/2022 12:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mitch Gardner
-- Create date: 20191023
-- Description:	Breaks out case attributes for non-GS1 labels based on barcode scan.
-- =============================================
ALTER PROCEDURE [dbo].[non_GS1] @barcode char(56)

AS

declare @UPC char(14), @Weight numeric(6,2), @MfgDate char(8), @Serial char(12), @month char(2), @Day char(2), @year char(4)
Set @UPC = substring(@barcode, 3, 14)
Set @Weight = case when SUBSTRING(@barcode, 17, 4) = '3202' then cast(SUBSTRING(@barcode, 21, 6) as numeric(6,2))/100
	when SUBSTRING(@barcode, 17, 4) = '3201' then cast(SUBSTRING(@barcode, 21, 5) as numeric(6,2))/10
	end
set @month = SUBSTRING(@barcode, 31, 2)
set @Day = SUBSTRING(@barcode, 33, 2)
set @year = '20'+SUBSTRING(@barcode, 29, 2)
Set @MfgDate = @month+@Day+@year
Set @Serial = SUBSTRING(@barcode, 37, 20)

select @UPC[UPC], @weight[Weight], @MfgDate[MfgDate], @Serial[Serial]

-- exec non_GS1 '010000000090520632020050351119100221270521365871'
