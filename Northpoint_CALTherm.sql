USE [Northpoint]
GO
/****** Object:  StoredProcedure [dbo].[CAL_Thermometer]    Script Date: 3/22/2022 1:52:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mitch Gardner
-- Create date: 20190918
-- Description:	For Quality Assurance team to calibrate and track calibration of thermometers
-- =============================================
ALTER PROCEDURE [dbo].[CAL_Thermometer] @barcode char(6), @badge_scan varchar(10), @nist decimal(5,2), @handheld decimal(5, 2), @Deviation decimal(4, 2), 
@Pass char(1), @computer char(15), @login varchar(15)

AS

declare @cal_date datetime, @emp_ID int, @renew int, @equip_id int, @comment varchar(200), @emp_name char(40), @cal_exp datetime, @serial char(14), @Model varchar(20), @description varchar(200)
set @cal_date = CURRENT_TIMESTAMP
set @emp_ID = (select id from employee where Badge_code = @badge_scan)
set @equip_id = (select id from Equipment where Barcode = @barcode)
set @emp_name = (select first_name+' '+Last_name from employee where id = @emp_ID)
set @renew = 30
set @cal_exp = DATEADD(DAY, @renew, @cal_date)
set @serial = (select serial from Equipment where Barcode = @barcode)
set @comment = 
	case when @Pass = 'Y' then 'CAL passed: ' + rtrim(cast(@cal_date as char)) + ' with deviation of ' + rtrim(cast(@Deviation as char)) + ' - completed by: '+ rtrim(@emp_name) + 
		' on PC: ' + rtrim(@computer) + ' Expires: '+ rtrim(cast(@cal_exp as char))
	else 'CAL failed: ' + rtrim(cast(@cal_date as char)) + ' with deviation of ' + rtrim(cast(@Deviation as char)) + ' - completed by '+ rtrim(@emp_name) 
	+ ' on PC: ' + rtrim(@computer) end
set @model = (select model from Equipment where id = @equip_id)
set @description = (select description from Equipment where id = @equip_id)

if exists (select 1 from Calibration_List cl
where serial = @serial)

		update Calibration_List set barcode = @barcode, Serial = @serial, NIST_Reading = @nist, Handheld_Reading = @handheld, Deviation = @Deviation, Pass = @Pass, 
		cal_date = @cal_date, CAL_Exp = @cal_exp, cal_user = @emp_ID
		where serial = @serial

else

		insert into Calibration_List values (@barcode, @serial, @nist, @handheld, @Deviation, @Pass, @cal_date, @cal_exp, @emp_ID)
		
insert into Equipment_log values (@barcode, @emp_ID, @comment, @cal_date, @Model, @serial, @description, @computer, @login)


-- exec CAL_Thermometer '000001', '024b4dcf', 29.00, 30.02, 1.02, 'Y', 'cp-mgardner'
-- select * from calibration_list
-- delete from calibration_list
-- select * from equipment_log order by time_modified desc
-- delete from equipment_log where emp_id = 84
