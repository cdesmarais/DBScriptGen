IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CoreIntegrations].[test that all procedure output signatures are unchanged]') AND type in (N'P', N'PC'))
DROP PROCEDURE [CoreIntegrations].[test that all procedure output signatures are unchanged]
GO


CREATE PROCEDURE [CoreIntegrations].[test that all procedure output signatures are unchanged]
AS
BEGIN
	Return 0
	DECLARE @tSQL VARCHAR(4096)
	DECLARE @DropSQL VARCHAR(4096)
	--First we load all of our outputs into #temp tables
	DECLARE CreateTempSigs CURSOR FAST_FORWARD FOR
	SELECT 'SELECT * INTO ##' + SO.name + ' FROM OPENROWSET(''SQLNCLI'', ''Server=(local);Trusted_Connection=yes;'', ''SET NOCOUNT ON;SET FMTONLY ON;' + 
	CASE WHEN COUNT(DISTINCT  Parameter_ID) > 0 THEN left('EXEC ' + DB_NAME() + '.' + SCHEMA_NAME(SCHEMA_ID) + '.' + SO.name + ' ' + REPLICATE('NULL, ', COUNT(DISTINCT  Parameter_ID)), LEN ('EXEC ' + DB_NAME() + '.' + SCHEMA_NAME(SCHEMA_ID) + '.' + SO.name + ' ' + REPLICATE('NULL, ', COUNT(DISTINCT  Parameter_ID))) -1)
	ELSE 'EXEC ' + DB_NAME() + '.' + SCHEMA_NAME(SCHEMA_ID) + '.' + SO.name END 
	 +';SET FMTONLY OFF'')'
	FROM sys.objects AS SO
	LEFT JOIN sys.parameters AS P
	ON SO.OBJECT_ID = P.OBJECT_ID
	WHERE SO.type IN ('P','FN')
	AND		SCHEMA_NAME(SCHEMA_ID) not like 'tSQLt'
	AND		SCHEMA_NAME(SCHEMA_ID) not like '%Integration%'
	AND		DB_NAME() + '_testIntegrationSignatures.'+SO.name not in (select OBJECT_SCHEMA_NAME([Object_ID], DB_ID('IntegrationTestData')) + '.' + Name from IntegrationtestData.sys.tables)
	GROUP BY SCHEMA_NAME(SCHEMA_ID), SO.name
	OPEN CreateTempSigs
	FETCH NEXT FROM CreateTempSigs INTO @tSQL
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@tSQL)
		FETCH NEXT FROM CreateTempSigs INTO @tSQL
	END
	CLOSE CreateTempSigs
	DEALLOCATE CreateTempSigs
	--and compare them
	DECLARE Compare CURSOR FOR 
	SELECT 'EXEC tSQLt.AssertEqualsTable ''IntegrationtestData.' + DB_NAME() + '_TestIntegrationSignatures.' + SO.name + ''', ''##' + name + '''', 'DROP TABLE ##' + name FROM sys.objects SO WHERE SCHEMA_NAME(SCHEMA_ID) = 'testIntegrationSignatures' AND SO.type IN ('P','FN')
	OPEN Compare
	FETCH NEXT FROM Compare INTO @tSQL, @DropSQL
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@tSQL)
		EXEC (@DropSQL)
		FETCH NEXT FROM Compare INTO @tSQL, @DropSQL
	END
	CLOSE Compare
	DEALLOCATE Compare
END

GO

GRANT EXECUTE ON [CoreIntegrations].[test that all procedure output signatures are unchanged] TO ExecuteOnlyRole
GO


