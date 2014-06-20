IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'CoreIntegrations')
exec ('CREATE SCHEMA CoreIntegrations AUTHORIZATION [dbo]')
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'IntegrationTestData')
	CREATE DATABASE IntegrationTestData
GO

DECLARE @MySQLState VARCHAR(1000)
SET @MySQLState = 'USE IntegrationTestData' /*+ CHAR(10) + 'GO'*/ + CHAR(10) + 'IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + DB_NAME() + '_TestIntegrationSignatures'')' + CHAR(10) + 'exec (''CREATE SCHEMA ' + DB_NAME() + '_TestIntegrationSignatures AUTHORIZATION [dbo]'')'
exec (@MySQLState)

USE IntegrationTestData
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestCaseExceptions]') AND type in (N'U'))
CREATE TABLE [dbo].[TestCaseExceptions](
	[SchemaName] [nvarchar](100) NOT NULL,
	[TestName] [nvarchar](100) NOT NULL,
	[ObjectName] [nvarchar](100) NOT NULL
) 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CurrentParameterDefs]') AND type in (N'U'))
CREATE TABLE [dbo].[CurrentParameterDefs](
	[Database] [nvarchar](128) NOT NULL,
	[Schema] [nvarchar](128) NULL,
	[ObjectName] [sysname] NOT NULL,
	[ObjectType (UDF/SP)] [nvarchar](60) NULL,
	[ParameterID] [int] NULL,
	[ParameterName] [nvarchar](128) NULL,
	[ParameterDataType] [nvarchar](128) NULL,
	[ParameterMaxBytes] [smallint] NULL,
	[IsOutPutParameter] [bit] NULL
) ON [PRIMARY]

GO



