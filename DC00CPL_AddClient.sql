USE [DC00CPL]
GO
/****** Object:  StoredProcedure [dbo].[Add_Client]    Script Date: 3/22/2022 11:45:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Mitch Gardner - CPL>
-- Create date: <20190724>
-- Description:	Called by Powershell script - Adds single client to all users missing each client listed in the CSV
-- =============================================
ALTER PROCEDURE [dbo].[Add_Client] @clientid varchar(10)

AS

create table #TEMP (ID int not null identity, UserID varchar(20))

insert into #TEMP (UserID)
select userID from SEC_Users

delete from #TEMP
where EXISTS(SELECT 1 FROM SEC_User_Client WHERE #TEMP.UserID = SEC_User_Client.UserID and ClientID = @clientid)

insert into SEC_User_Client (UserID, ClientID)
select userid, @clientid from #TEMP

drop table #TEMP