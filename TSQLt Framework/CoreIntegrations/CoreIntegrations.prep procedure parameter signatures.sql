IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CoreIntegrations].[prep procedure parameter signatures]') AND type in (N'P', N'PC'))
DROP PROCEDURE [CoreIntegrations].[prep procedure parameter signatures]
GO

CREATE PROCEDURE [CoreIntegrations].[prep procedure parameter signatures]
AS
BEGIN
	--Insert new object signatures
	INSERT INTO IntegrationTestData.dbo.CurrentParameterDefs
           ([Database]
           ,[SCHEMA]
           ,ObjectName
           ,[ObjectType (UDF/SP)]
           ,[ParameterID]
           ,[ParameterName]
           ,[ParameterDataType]
           ,[ParameterMaxBytes]
           ,[IsOutPutParameter])
    SELECT DB_NAME(), 
    SCHEMA_NAME(SCHEMA_ID) AS [Schema],
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
	LEFT JOIN IntegrationTestData.dbo.CurrentParameterDefs d
	on d.[schema] = SCHEMA_NAME(SCHEMA_ID)
	and	d.ObjectName=SO.name
	WHERE SO.OBJECT_ID IN ( SELECT OBJECT_ID
	FROM sys.objects
	WHERE TYPE IN ('P','FN'))
	AND		SCHEMA_NAME(SCHEMA_ID) not like 'tSQLt'
	AND		SCHEMA_NAME(SCHEMA_ID) not like '%Integrations%'
	AND 	SO.name NOT IN (select ObjectName FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = 'test that all procedure parameter signatures are unchanged' AND SchemaName=SCHEMA_NAME())
	AND d.ObjectName is NULL
	UNION 
	--WE add one line with null parameter values per proc
	SELECT DB_NAME(),
	SCHEMA_NAME(SCHEMA_ID) AS [Schema],
	SO.name AS [ObjectName],
	SO.Type_Desc AS [ObjectType (UDF/SP)], 
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
	FROM sys.objects SO
	LEFT JOIN IntegrationTestData.dbo.CurrentParameterDefs d
	on d.[schema] = SCHEMA_NAME(SCHEMA_ID)
	and	d.ObjectName=SO.name
	WHERE 	TYPE IN ('P','FN')
	AND		SCHEMA_NAME(SCHEMA_ID) not like 'tSQLt'
	AND		SCHEMA_NAME(SCHEMA_ID) not like '%Integrations%'
	AND 	SO.name NOT IN (select ObjectName FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = 'test that all procedure parameter signatures are unchanged' AND SchemaName=SCHEMA_NAME())
	AND d.ObjectName is null
	ORDER BY [Schema], SO.name, P.parameter_id

END



GO

GRANT EXECUTE ON [CoreIntegrations].[prep procedure parameter signatures] TO ExecuteOnlyRole

GO

