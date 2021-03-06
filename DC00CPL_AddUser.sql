USE [DC00CPL]
GO
/****** Object:  StoredProcedure [dbo].[Add_User]    Script Date: 3/22/2022 11:46:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=============================================
-- Author:		Mitch Gardner - CPL
-- Create date: 20190724
-- Description:	Called by Powershell script - Creates a single user, adds all clients, adds picker profile to warehouse users,
and assigns temp password
-- =============================================*/
ALTER PROCEDURE [dbo].[Add_User] @First char(20), @Last char(20), @user_ID char(10), @Group char(20)

AS

declare @today datetime, @pwid int, @sec_group char(20), @userid uniqueidentifier, @passwordID uniqueidentifier, @get_csec_userid char(40), @get_Password_type uniqueidentifier,
@user_password char(20)
set @passwordID = newid()
set @userid = newid()
set @today = getdate()
set @pwid = (select top 1 userpasswordid from sec_users order by UserPasswordID desc) + 1
set @sec_group = 
	case
		when @group = 'Inventory' then 'Inventory'
		when @group = 'IT' then 'Administrators'
		when @group = 'Sanitation' then ''
		else 'Users'
	end -- assigns user access based on department

if not exists (select 1 from SEC_Users where UserID = @user_ID)

Begin

	insert into sec_users values (@user_ID, '1234', @pwid, @First, @Last, 'A', '', '', '', '', @today, 'Emp Mgr', 'Emp Mgr  ') -- table profile for Enterprise Manager

	insert into DC00CPL.dbo.SEC_User_Group values (@user_ID, @sec_group) -- table for mobile device

	insert into sec_user_client (userid, clientid)
	(select @user_ID, clientid from client)  -- allows user to edit all clients

	if exists (select 1 from DC00CPL.dbo.SEC_User_Group where UserID = @user_ID and GroupID = 'Users')
		insert into DC01CPL.dbo.Picker_Profile values (@user_ID, 'TEST1', getdate(), 'DC01CPL', '')

	insert into csec_user values (@user_id, @userid)

	-- get newly created user/PW info
	set @get_csec_userid = (select userid from csec_user where username = @user_ID)
	set @get_Password_type = (select top 1 passwordtypeID from csec_passwordtype)
	set @user_password = (select password from sec_users where userid = @user_ID)

	insert into CSec_Password values (@passwordID, @get_csec_userid, @get_password_type, 
	HASHBYTES('SHA2_256', @user_password), @today, 1, 1, 0, 1, 0, '', '')

	exec cd_SecResetPassword2 @user_ID, 'Direct', '1234', 0, 0, 1, 1, @get_csec_userid -- Stored Procedure created by Cadre to reset PW. Initial PW was not working for mobile devices.

end

-- exec Add_User 'First_Test', 'Last_test', 'User_test', 'Office'
-- select * from client order by clientid
