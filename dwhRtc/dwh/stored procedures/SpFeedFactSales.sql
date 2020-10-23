CREATE PROC [dwh].[SpFeedFactSales] AS
BEGIN

   /* ***************************************************************************************************
		- Truncate fact table
		- Find Foreign Keys
		- Insert into table
	**************************************************************************************************** */
	TRUNCATE TABLE dwh.FactSales

	INSERT INTO dwh.FactSales (OrderNumber
								,QuantityOrdered
								,PriceEach
								,OrderLineNumber 
								,Sales
								,Status 
								,DatesId
								,CustomersId 
								,ProductsId)
		SELECT	OrderNumber
				,QuantityOrdered
				,PriceEach
				,OrderLineNumber 
				,Sales
				,Status 
				,DatesId = ISNULL(ddt.DateId,-1)
				,CustomersId = ISNULL(dcu.CustomersId,-1) 
				,ProductsId	 = ISNULL(dpr.ProductsId,-1)		
			FROM	[stg].[sales] src
		LEFT JOIN [dwh].DimCustomers dcu
			ON dcu.CustomerName = src.CustomerName
			LEFT JOIN [dwh].DimDates ddt
				ON ddt.[Date] = DATEADD(DAY, 1, EOMONTH(src.[date], -1))
		LEFT JOIN dwh.DimProducts dpr
			ON	dpr.ProductCode = src.ProductCode
END

