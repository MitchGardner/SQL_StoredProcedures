USE [Northpoint]
GO
/****** Object:  StoredProcedure [dbo].[check_equipmentinuse]    Script Date: 3/22/2022 1:55:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		mitch gardner
-- Create date: 20191202
-- Description:	used to prevent workers from checking out multiple thermometers - returns Y or N for VBA code to return messagebox to user if they have equipment checked out.
-- =============================================
ALTER PROCEDURE [dbo].[check_equipmentinuse] @badge_scan varchar(10)

AS

create table #tmp (serial varchar(20), barcode char(6), emp int)

declare @emp_id int

insert into #tmp
select e.serial, eiu.barcode, eiu.Emp_ID from equipment_inuse eiu left outer join equipment e on eiu.barcode = e.barcode 
left outer join employee emp on emp.ID = eiu.Emp_ID
where emp.badge_code = @badge_scan

if exists (select 1 from #tmp where left(serial, 5) = 'THERM')
	select 'Y'
else
	select 'N'

drop table #tmp

--  select e.serial, eiu.barcode from equipment_inuse eiu left outer join equipment e on eiu.barcode = e.barcode where emp_id = 145

--  select * from Equipment_InUse
--  select * from employee where id = 145
-- exec check_equipmentinuse '024b4dcf'
