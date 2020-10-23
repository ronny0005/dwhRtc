CREATE TABLE [dwh].[FactSales]
(
    OrderNumber INT NULL
    ,QuantityOrdered INT NULL
    ,PriceEach DECIMAL(15,2) NULL
    ,OrderLineNumber INT NULL
    ,Sales DECIMAL(15,2) NULL
    ,Status NVARCHAR(50) NULL
    ,DatesId INT NULL
    ,CustomersId INT NULL
    ,ProductsId INT NULL
)
WITH
(
CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(OrderNumber)
)
GO
