IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[coreIntegrations].[test that all procedures run readuncommitted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [coreIntegrations].[test that all procedures run readuncommitted]
GO


CREATE PROCEDURE [CoreIntegrations].[test that all procedures run readuncommitted]
AS
BEGIN
    DECLARE		@expected INT=0,
				@actual INT
	SELECT OBJECT_NAME(object_id) as Name
	INTO #tmp
	from sys.sql_modules 
	where definition not like '%LEVEL READ UNCOMMITTED%'
	AND		OBJECT_SCHEMA_NAME(object_id) not like 'tSQLt'
	AND		OBJECT_SCHEMA_NAME(object_id) not like '%Integrations%'
	AND 	OBJECT_NAME(object_id) NOT IN (select ObjectName FROM IntegrationTestData.dbo.TestCaseExceptions WHERE TestName = OBJECT_NAME(@@PROCID) AND SchemaName=Object_SCHEMA_NAME(object_id))
	SET @actual=@@ROWCOUNT
	IF @actual > 0
	BEGIN
		PRINT 'The following procedures do not have an explicit READ UNCOMMITTED setting:'
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

END

GO

GRANT EXECUTE ON [coreIntegrations].[test that all procedures run readuncommitted] TO ExecuteOnlyRole
GO


