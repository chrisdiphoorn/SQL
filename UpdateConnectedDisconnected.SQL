GO
-- =============================================
-- Author:		Chris Diphoorn
-- Create date: 16-01-2020
-- a Script on HCC-GC-CB01 c:\Scripts\UpdateConnectedDisconnected.ps1 runs this Store Proceedure every 5 mins
-- =============================================
ALTER PROCEDURE [dbo].[UpdateUserAction]  @ParUserName VARCHAR(50), @ParAction VARCHAR(20), @ParServer VARCHAR(30), @ParIdle VARCHAR(10), @ParIP VARCHAR(20) = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;


DECLARE @today DATE;
DECLARE @FullDateTime DATE;

DECLARE @LastAction VARCHAR(20);
SET @FullDateTime = getdate();

SET @today = (select Convert(varchar, getdate(),111));

-- Find the last action for today for the user
SET @LastAction=(SELECT TOP 1 Action from dbo.UserActions WHERE CAST([Date] as date) = @today and UserName = @ParUserName and Server = @ParServer ORDER BY Date DESC)


IF @ParAction = 'Active' and @LastAction ='Disconnected' 
   	INSERT INTO dbo.UserActions (UserName, Date, Action, Server, Idle, RemoteIP) VALUES (@ParUserName,(CONVERT(DateTime, getdate())), @ParAction, @ParServer, @ParIdle, @ParIP) ;

IF @ParAction = 'Disconnected' and (@LastAction ='Active' OR @LastAction = 'Logon')
	 INSERT INTO dbo.UserActions (UserName, Date, Action, Server, Idle, RemoteIP) VALUES (@ParUserName,(CONVERT(DateTime, getdate())), @ParAction, @ParServer, @ParIdle, @ParIP) ;

-- LOGON and LOGOFF Actions are normally added by the users logonscript and logoffscript and not with this statement.

-- Update Logon or Logoff Actions
IF @ParAction = 'Logon' or @ParAction = 'Logoff'	
  INSERT INTO dbo.UserActions (UserName, Date, Action, Server, Idle, RemoteIP) VALUES (@ParUserName,(CONVERT(DateTime, getdate())), @ParAction, @ParServer, @ParIdle, @ParIP) ;


-- Update The IP Address for a users Logon if it was not already populated
IF @LastAction ='Logon' and @ParIP is not null and @ParIP <> ''
UPDATE dbo.UserActions SET RemoteIP = @ParIP WHERE ID in (SELECT TOP (1) ID FROM dbo.UserActions WHERE UserName = @ParUserName and Server = @ParServer and Action = 'Logon' and ( RemoteIP is Null OR RemoteIP = '') ORDER BY Date DESC)

-- Update The IDLE for the user if they are in a Disconnected State
IF @LastAction ='Disconnected' and @ParIdle is not null
UPDATE dbo.UserActions SET Idle = @ParIdle WHERE ID in (SELECT TOP (1) ID FROM dbo.UserActions WHERE UserName = @ParUserName and Server = @ParServer and Action = 'Disconnected' ORDER BY Date DESC)

-- Update The IDLE for the user if they are in a Disconnected State
IF @LastAction ='Active' and @ParIdle is not null
UPDATE dbo.UserActions SET Idle = @ParIdle WHERE ID in (SELECT TOP (1) ID FROM dbo.UserActions WHERE UserName = @ParUserName and Server = @ParServer and Action = 'Active' ORDER BY Date DESC)

END;
