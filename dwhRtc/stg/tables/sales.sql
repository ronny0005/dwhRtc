﻿CREATE TABLE [stg].[sales](
	[ORDERNUMBER] [int] NOT NULL,
	[QUANTITYORDERED] [int] NOT NULL,
	[PRICEEACH] [nvarchar](50) NOT NULL,
	[ORDERLINENUMBER] [nvarchar](50) NOT NULL,
	[SALES] [nvarchar](50) NOT NULL,
	[ORDERDATE] [nvarchar](50) NOT NULL,
	[STATUS] [nvarchar](50) NOT NULL,
	[QTR_ID] [nvarchar](50) NOT NULL,
	[MONTH_ID] [nvarchar](50) NOT NULL,
	[YEAR_ID] [int] NOT NULL,
	[PRODUCTLINE] [nvarchar](50) NOT NULL,
	[MSRP] [int] NOT NULL,
	[PRODUCTCODE] [nvarchar](50) NOT NULL,
	[CUSTOMERNAME] [nvarchar](50) NOT NULL,
	[PHONE] [nvarchar](50) NOT NULL,
	[ADDRESSLINE1] [nvarchar](50) NOT NULL,
	[ADDRESSLINE2] [nvarchar](50) NULL,
	[CITY] [nvarchar](50) NOT NULL,
	[STATE] [nvarchar](50) NULL,
	[POSTALCODE] [nvarchar](50) NULL,
	[COUNTRY] [nvarchar](50) NOT NULL,
	[TERRITORY] [nvarchar](50) NOT NULL,
	[CONTACTLASTNAME] [nvarchar](50) NOT NULL,
	[CONTACTFIRSTNAME] [nvarchar](50) NOT NULL,
	[DEALSIZE] [nvarchar](50) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);
