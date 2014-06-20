IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CoreIntegrations].[test that all procedure parameter signatures are unchanged]') AND type in (N'P', N'PC'))
DROP PROCEDURE [CoreIntegrations].[test that all procedure parameter signatures are unchanged]
GO

CREATE PROCEDURE [CoreIntegrations].[test that all procedure parameter signatures are unchanged]
AS
BEGIN
    IF OBJECT_ID('##ParamsActual') IS NOT NULL DROP TABLE ##ParamsActual;
    CREATE TABLE ##ParamsActual(
	[Schema] [nvarchar](128) NULL,
	[ObjectName] [sysname] NOT NULL,
	[ObjectType (UDF/SP)] [nvarchar](60) NULL,
	[ParameterID] [int] NULL,
	[ParameterName] [nvarchar](128) NULL,
	[ParameterDataType] [nvarchar](128) NULL,
	[ParameterMaxBytes] [smallint] NULL,
	[IsOutPutParameter] [bit] NULL
	) 


	--First we load our data into a test table
	INSERT INTO ##ParamsActual
           ([Schema]
           ,[ObjectName]
           ,[ObjectType (UDF/SP)]
           ,[ParameterID]
           ,[ParameterName]
           ,[ParameterDataType]
           ,[ParameterMaxBytes]
           ,[IsOutPutParameter])
	SELECT SCHEMA_NAME(SCHEMA_ID) AS [Schema],
	SO.name AS [ObjectName],
	SO.Type_Desc AS [ObjectType (UDF/SP)],
	P.parameter_id AS [ParameterID],
	P.name AS [ParameterName],
	TYPE_NAME(P.user_type_id) AS [ParameterDataType],
	P.max_length AS [ParameterMaxBytes],
	P.is_output AS [IsOutPutParameter]
	FROM sys.objects AS SO
	INNER JOIN sys.parameters AS P
	ON SO.OBJECT_ID = P.OBJECT_ID
	WHERE SO.OBJECT_ID IN ( SELECT OBJECT_ID
	FROM sys.objects
	WHERE TYPE IN ('P','FN'))
	AND		SCHEMA_NAME(SCHEMA_ID) not like 'tSQLt'
	AND		SCHEMA_NAME(SCHEMA_ID) not like '%Integrations%'
	AND 	SO.name NOT IN (select ObjectName FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = 'test that all procedure output signatures are unchanged' AND SchemaName=SCHEMA_NAME())
	UNION 
	--WE add one line with null parameter values per proc
	SELECT SCHEMA_NAME(SCHEMA_ID) AS [Schema],
	SO.name AS [ObjectName],
	SO.Type_Desc AS [ObjectType (UDF/SP)], 
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
	FROM sys.objects SO
	WHERE 	TYPE IN ('P','FN')
	AND		SCHEMA_NAME(SCHEMA_ID) not like 'tSQLt'
	AND		SCHEMA_NAME(SCHEMA_ID) not like '%Integrations%'
	AND 	SO.name NOT IN (select ObjectName FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = 'test that all procedure output signatures are unchanged' AND SchemaName=SCHEMA_NAME())
	ORDER BY [Schema], SO.name, P.parameter_id
	--and compare them
    EXEC tSQLt.AssertEqualsTable '##Paramsactual', 'IntegrationTestData.dbo.CurrentParameterDefs'

END


GO


