CREATE PROC [dwh].[SpFeedDimDate] AS
BEGIN 
	
	--========================================================================================================================================
	-- 0) Configuration of @@DATEFIRST system value
	--========================================================================================================================================
	
	-- Backup of system starting Day of Week to restore the value at the end
	DECLARE	 @StartDate [DATE] =	CASE
										WHEN (SELECT TOP 1 1 FROM [dwh].[DimDate]) IS NULL THEN CAST('20000101' AS DATE)
										ELSE CAST('20000101' AS DATE)
									END
	DECLARE	@EndDate [DATE] = CAST(DATEADD(YEAR, 10, GETDATE()) AS DATE)
	DECLARE	@DateFirst [TINYINT] = 1 --Monday as first day of week
	DECLARE	@SystemDateFirst TINYINT = @@DATEFIRST
	DECLARE	@SetDateFirst VARCHAR(100) = CONCAT('SET DATEFIRST ', @DateFirst)
	
	-- Modification of starting Day of Week for the duration of the procedure (by default starting at Sunday)
	EXEC(@SetDateFirst)
	;

	--========================================================================================================================================
	-- 1) Declaration of the temporary table that hold intermediate calculations
	--========================================================================================================================================
	
	IF OBJECT_ID('tempdb..#Calendar', 'U') IS NOT NULL
	DROP TABLE #Calendar
	;
	
	CREATE TABLE #Calendar ([Date] DATE NOT NULL)
	;

	--========================================================================================================================================
	-- 2) Generation of all dates existing in the defined interval and calculation of the first fields
	--========================================================================================================================================

	DECLARE
		@MaxDate DATE = @StartDate
	;

	-- use a while loop in case of CROSS JOIN do not generate enough rows to populate the whole interval
	WHILE
		@MaxDate < @EndDate
	BEGIN
		INSERT
			#Calendar ([Date])
		SELECT
			[Date] = DATEADD(DAY, DateAdd, @MaxDate)
		FROM (
			SELECT TOP (DATEDIFF(DAY, @MaxDate, @EndDate) + 1) 
				[DateAdd] = ROW_NUMBER() OVER (ORDER BY s1.object_id) - 1
			FROM
				sys.all_objects AS s1
			CROSS JOIN
				sys.all_objects AS s2
			) d ([DateAdd])
		;

		-- set the start date for the next loop
		SELECT
			@MaxDate = CASE WHEN MAX(Date) < '99991231' THEN DATEADD(DAY, 1, MAX(Date)) END
		FROM
			#Calendar
	END
	;
	
	--========================================================================================================================================
	-- 3) Regeneration of dwh.PrepDate table and cast of all columns to the optimal format
	--========================================================================================================================================
	
	IF OBJECT_ID('tempdb..#PrepDate') IS NOT NULL
		DROP TABLE #PrepDate
	;

	CREATE TABLE #PrepDate
	WITH (
		 DISTRIBUTION = ROUND_ROBIN
		,CLUSTERED COLUMNSTORE INDEX
	)
	AS
		WITH _Calendar_ AS (
			SELECT
				 [DateId] = YEAR([Date]) * 10000 + MONTH([Date]) * 100 + DAY([Date])
				,[Date]
				,[DateName] = CAST(FORMAT([Date], 'dd-MMM-yyyy', 'en-us') AS CHAR(11))
				,[DayNameOfWeek] = CAST(FORMAT([Date], 'dddd', 'en-us') AS VARCHAR(20))
				,[MonthTextNumber] = CAST(FORMAT([Date], 'MM') AS CHAR(2))
				,[QuarterTextNumber] = CAST(CONCAT('Q', DATEPART(QUARTER, [Date])) AS CHAR(2))
				,[MonthName] = CAST(FORMAT([Date], 'MMMM', 'en-us') AS VARCHAR(20))
				,[YearTextNumber] = CAST(FORMAT([Date], 'yyyy') AS CHAR(4))
				,[CalendarYear] = CAST(YEAR([Date]) AS SMALLINT)
				,[CalendarQuarter] = CAST(DATEPART(QUARTER, [Date]) AS TINYINT)
				,[MonthOfYear] = CAST(MONTH([Date]) AS TINYINT)
				,[DayOfWeek] = CAST(DATEPART(WEEKDAY, [Date]) AS TINYINT)
				,[DayOfMonth] = CAST(DAY([Date]) AS TINYINT)
				,[DayOfYear] = CAST(DATEPART(DAYOFYEAR, [Date]) AS SMALLINT)
				,[WeekOfYear] = CAST(DATEPART(WEEK, [Date]) AS TINYINT)
				,[FirstDateOfWeek] = CASE WHEN DATEDIFF(DAY, '00010101', [Date]) > DATEPART(WEEKDAY, [Date]) THEN DATEADD(DAY, - (DATEPART(WEEKDAY, [Date]) - 1), [Date]) ELSE '00010101' END
				,[LastDateOfWeek] = CASE WHEN DATEDIFF(DAY, [Date], '99991231') > 7 - (DATEPART(WEEKDAY, [Date])) THEN DATEADD(DAY, 7 - (DATEPART(WEEKDAY, [Date])), [Date]) ELSE '99991231' END
				,[IsLastDayOfMonth] = CAST(CASE WHEN [Date] = EOMONTH([Date]) THEN 'Y' ELSE 'N' END AS CHAR(1))
			FROM
				#Calendar
		)

		SELECT
			 src.[DateId]
			,src.[Date]
			,src.[DateName]
			,src.[DayOfWeek]
			,src.[DayNameOfWeek]
			,src.[FirstDateOfWeek]
			,src.[LastDateOfWeek]
			,src.[DayOfMonth]
			,src.[DayOfYear]
			,[IsWeekend] = CAST(CASE WHEN src.[DayOfWeek] IN ((13 - @DateFirst) % 7 + 1, (7 - @DateFirst) % 7 + 1) THEN 1 ELSE 0 END AS BIT)
			,src.[WeekOfYear]
			,src.[MonthName]
			,src.[MonthOfYear]
			,src.[IsLastDayOfMonth]
			,src.[CalendarQuarter]
			,src.[CalendarYear]
			,[FirstDateOfMonth] = CONCAT(LEFT(src.[Date],8),'01')
			,[CalendarYearMonth] = CAST(CONCAT(src.YearTextNumber, '-', src.MonthTextNumber) AS CHAR(7))
			,[CalendarYearQuarter] = CAST(CONCAT(src.YearTextNumber, '-', src.QuarterTextNumber) AS CHAR(7))
			,[FiscalMonthOfYear] = CAST(NULL AS [tinyint])
			,[FiscalQuarter] = CAST(NULL AS [tinyint])
			,[FiscalYear] = CAST(NULL AS [smallint])
			,[FiscalYearMonth] = CAST(NULL AS [char](9))
			,[FiscalYearQuarter] = CAST(NULL AS [char](9))
		FROM
			_Calendar_ src
		LEFT JOIN dwh.DimDate ddt
		ON src.DateId = ddt.DateId
		WHERE ddt.DateId IS NULL
	;
	
	INSERT INTO dwh.DimDate ([DateId],[Date],[DateName],[DayOfWeek],[DayNameOfWeek],[FirstDateOfWeek],[LastDateOfWeek],[DayOfMonth]
			,[DayOfYear],[IsWeekend],[WeekOfYear],[MonthName],[MonthOfYear],[IsLastDayOfMonth],[CalendarQuarter],[CalendarYear],[CalendarYearMonth]
			,[CalendarYearQuarter],[FiscalMonthOfYear],[FiscalQuarter],[FiscalYear],[FiscalYearMonth],[FiscalYearQuarter],[FirstDateOfMonth]) 
	
		SELECT
			[DateId]
			,[Date]
			,[DateName]
			,[DayOfWeek]
			,[DayNameOfWeek]
			,[FirstDateOfWeek]
			,[LastDateOfWeek]
			,[DayOfMonth]
			,[DayOfYear]
			,[IsWeekend]
			,[WeekOfYear]
			,[MonthName]
			,[MonthOfYear]
			,[IsLastDayOfMonth]
			,[CalendarQuarter]
			,[CalendarYear]
			,[CalendarYearMonth]
			,[CalendarYearQuarter]
			,[FiscalMonthOfYear]
			,[FiscalQuarter]
			,[FiscalYear]
			,[FiscalYearMonth]
			,[FiscalYearQuarter]
			,[FirstDateOfMonth]
		FROM #PrepDate

	
	IF OBJECT_ID('tempdb..#PrepDate') IS NOT NULL
		DROP TABLE #PrepDate
	;

	IF OBJECT_ID('tempdb..#Calendar', 'U') IS NOT NULL
	DROP TABLE #Calendar
	;

END 