USE [master]  
GO  

SET ANSI_NULLS ON  
GO  
SET QUOTED_IDENTIFIER ON  
GO  


-- =====================================================================  
-- By C.Diphoorn 2020
-- Description: Backup Database  
-- Parameter1: databaseName  
-- Parameter2: backupType F=full, D=differential, L=log, C=Certificate
-- =====================================================================  
CREATE PROCEDURE [dbo].[sp_BackupDatabase]   
       @databaseName sysname, @backupType CHAR(1)  
AS  
BEGIN  
       SET NOCOUNT ON;  

       DECLARE @sqlCommand NVARCHAR(1000)  
       DECLARE @dateTime NVARCHAR(20)  

       SELECT @dateTime = REPLACE(CONVERT(VARCHAR, GETDATE(),111),'/','') +  
       REPLACE(CONVERT(VARCHAR, GETDATE(),108),':','')   

		IF @backupType = 'C'  
               SET @sqlCommand = 'BACKUP DATABASE ' + @databaseName +  
               ' TO DISK = ''D:\MSSQL\BACKUP\' + @databaseName + '_Full_' + @dateTime + '.BAK'' WITH ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = Certificate)'  
         
       IF @backupType = 'F'  
               SET @sqlCommand = 'BACKUP DATABASE ' + @databaseName +  
               ' TO DISK = ''D:\MSSQL\BACKUP\' + @databaseName + '_Full_' + @dateTime + '.BAK'''  
         
       IF @backupType = 'D'  
               SET @sqlCommand = 'BACKUP DATABASE ' + @databaseName +  
               ' TO DISK = ''D:\MSSQL\BACKUP\' + @databaseName + '_Diff_' + @dateTime + '.BAK'' WITH DIFFERENTIAL'  
         
       IF @backupType = 'L'  
               SET @sqlCommand = 'BACKUP LOG ' + @databaseName +  
               ' TO DISK = ''D:\MSSQL\BACKUP\' + @databaseName + '_Log_' + @dateTime + '.TRN'''  
         
       EXECUTE sp_executesql @sqlCommand  
END 
