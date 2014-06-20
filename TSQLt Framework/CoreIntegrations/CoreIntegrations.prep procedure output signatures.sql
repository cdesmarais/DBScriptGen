IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CoreIntegrations].[prep procedure output signatures]') AND type in (N'P', N'PC'))
DROP PROCEDURE [CoreIntegrations].[prep procedure output signatures]
GO

CREATE PROCEDURE [CoreIntegrations].[prep procedure output signatures]
AS
BEGIN
	DECLARE @tSQL VARCHAR(4096)
	DECLARE CreateSigs CURSOR FAST_FORWARD FOR
	SELECT 'SELECT * INTO IntegrationtestData.' + DB_NAME() + '_TestIntegrationSignatures.' + SO.name + ' FROM OPENROWSET(''SQLNCLI'', ''Server=(local);Trusted_Connection=yes;'', ''SET NOCOUNT ON;SET FMTONLY ON;' + 
	CASE WHEN Count(*) > 0 THEN left('EXEC ' + DB_NAME() + '.' + SCHEMA_NAME(SCHEMA_ID) + '.' + SO.name + ' ' + REPLICATE('NULL, ', COUNT(*)), LEN ('EXEC ' + DB_NAME() + '.' + SCHEMA_NAME(SCHEMA_ID) + '.' + SO.name + ' ' + REPLICATE('NULL, ', COUNT(*))) -1)
	ELSE 'EXEC ' + DB_NAME() + '.' + SCHEMA_NAME(SCHEMA_ID) + '.' + SO.name END 
	 +';SET FMTONLY OFF'')'
	FROM sys.objects AS SO
	INNER JOIN sys.parameters AS P
	ON SO.OBJECT_ID = P.OBJECT_ID
	WHERE SO.type IN ('P','FN')
	AND		SCHEMA_NAME(SCHEMA_ID) not like 'tSQLt'
	AND		SCHEMA_NAME(SCHEMA_ID) not like '%Integration%'
	AND 	SO.name NOT IN (select ObjectName FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = OBJECT_NAME(@@PROCID) AND SchemaName=OBJECT_SCHEMA_NAME(@@procid))
	AND		DB_NAME() + '_testIntegrationSignatures.'+SO.name not in (select OBJECT_SCHEMA_NAME([Object_ID], DB_ID('IntegrationTestData')) + '.' + Name from IntegrationtestData.sys.tables)
	GROUP BY SCHEMA_NAME(SCHEMA_ID), SO.name
	OPEN CreateSigs
	FETCH NEXT FROM CreateSigs INTO @tSQL
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@tSQL)
		FETCH NEXT FROM CreateSigs INTO @tSQL
	END

END

GO

GRANT EXECUTE ON [CoreIntegrations].[prep procedure output signatures] TO ExecuteOnlyRole

GO


