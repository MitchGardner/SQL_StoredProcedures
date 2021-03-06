USE [Northpoint]
GO
/****** Object:  StoredProcedure [dbo].[Checkin_equipment]    Script Date: 3/22/2022 1:58:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Created by:		Mitch Gardner
Date:			20190321
Description:	Allows users to checkin equipment using VBA 
*/

ALTER PROCEDURE [dbo].[Checkin_equipment] @barcode char(6), @emp_code varchar(10), @computer varchar(15), @login varchar(15)

AS

declare @emp_id int, @model varchar(20), @serial varchar(20), @description varchar(200)
set @emp_id = (Select ID from employee where Badge_code = @emp_code)
set @model = (select model from equipment where Barcode = @barcode)
set @description = (select Description from equipment where Barcode = @barcode)
set @serial = (Select serial from Equipment where Barcode = @barcode)

insert into equipment_log values (@barcode, @emp_id, 'Checked in equipment', getdate(), @model, @serial, @description, @computer, @login)
update equipment set Assigned = 'N' where barcode = @barcode
delete from equipment_InUse where barcode = @barcode

-- select * from Equipment_InUse
