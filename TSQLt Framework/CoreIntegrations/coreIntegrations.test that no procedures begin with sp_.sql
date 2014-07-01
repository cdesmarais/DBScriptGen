IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[coreIntegrations].[test that no procedures begin with sp_]') AND type in (N'P', N'PC'))
DROP PROCEDURE [coreIntegrations].[test that no procedures begin with sp_]
GO

CREATE PROCEDURE [coreIntegrations].[test that no procedures begin with sp_]
AS
BEGIN
    DECLARE		@expected INT=0,
				@actual INT
	SELECT	OBJECT_NAME(object_id) AS Name
	INTO	#tmp
	FROM	sys.procedures where name like 'sp[_]%'
	AND		OBJECT_SCHEMA_NAME(object_id) not like 'tSQLt'
	AND		OBJECT_SCHEMA_NAME(object_id) not like '%Integrations%'
	AND 	OBJECT_NAME(object_id) NOT IN (select [ObjectName] FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = OBJECT_NAME(@@PROCID) AND SchemaName=OBJECT_SCHEMA_NAME(object_id))
	SET @actual=@@ROWCOUNT
	IF @actual > 0
	BEGIN
		PRINT 'The following procedures are named sp_:'
		DECLARE @Name VARCHAR(100)
		DECLARE ProcList CURSOR FOR SELECT Name FROM #tmp
		OPEN ProcList
		FETCH NEXT FROM ProcList INTO @Name
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @name
			FETCH NEXT FROM ProcList INTO @Name
		END
		CLOSE ProcList
		DEALLOCATE ProcList
	END
    EXEC tSQLt.AssertEquals @expected, @actual;

END;


GO


