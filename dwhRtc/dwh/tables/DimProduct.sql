CREATE TABLE [dwh].[DimProduct]
(
    ProductId int IDENTITY (1, 1) NOT NULL
    ,ProductCode NVARCHAR(150) NULL
    ,Msrp NVARCHAR(150) NULL
    ,ProductLine NVARCHAR(150) NULL
    ,InsertDate DATETIME2 (7)  NULL
    ,UpdateDate DATETIME2 (7)  NULL
)
WITH
(
CLUSTERED INDEX (ProductId), DISTRIBUTION = REPLICATE
)
GO
