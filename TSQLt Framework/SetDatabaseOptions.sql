EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
DECLARE @cmd NVARCHAR(MAX);
SET @cmd='ALTER DATABASE ' + QUOTENAME(DB_NAME()) + ' SET TRUSTWORTHY ON;';
EXEC(@cmd);
GO

