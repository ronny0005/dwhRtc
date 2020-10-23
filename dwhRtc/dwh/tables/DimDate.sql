CREATE TABLE [dwh].[DimDate] (
    [DateId]              INT         NOT NULL,
    [Date]                DATE         NOT NULL,
    [DateName]            CHAR (11)    NULL,
    [DayOfWeek]           TINYINT      NULL,
    [DayNameOfWeek]       VARCHAR (20) NULL,
    [FirstDateOfWeek]     DATE         NULL,
    [FirstDateOfMonth]    DATE         NULL,
    [LastDateOfWeek]      DATE         NULL,
    [DayOfMonth]          TINYINT      NULL,
    [DayOfYear]           SMALLINT     NULL,
    [IsWeekend]           BIT          NULL,
    [WeekOfYear]          TINYINT      NULL,
    [MonthName]           VARCHAR (20) NULL,
    [MonthOfYear]         TINYINT      NULL,
    [IsLastDayOfMonth]    CHAR (1)     NULL,
    [CalendarQuarter]     TINYINT      NULL,
    [CalendarYear]        SMALLINT     NULL,
    [CalendarYearMonth]   CHAR (7)     NULL,
    [CalendarYearQuarter] CHAR (7)     NULL,
    [FiscalMonthOfYear]   TINYINT      NULL,
    [FiscalQuarter]       TINYINT      NULL,
    [FiscalYear]          SMALLINT     NULL,
    [FiscalYearMonth]     CHAR (9)     NULL,
    [FiscalYearQuarter]   CHAR (9)     NULL
)
WITH (
        DISTRIBUTION = REPLICATE
        ,CLUSTERED INDEX (DateId));


GO