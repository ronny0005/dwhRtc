CREATE TABLE [dwh].[DimCustomer]
(
    CustomerId int IDENTITY (1, 1) NOT NULL
    ,CustomerName NVARCHAR(150) NULL
    ,Phone NVARCHAR(150) NULL
    ,AddressLine1 NVARCHAR(150) NULL
    ,AddressLine2 NVARCHAR(150) NULL
    ,City NVARCHAR(150) NULL
    ,State NVARCHAR(150) NULL
    ,PostalCode NVARCHAR(150) NULL
    ,Country NVARCHAR(150) NULL
    ,Territory NVARCHAR(150) NULL
    ,ContactLastName NVARCHAR(150) NULL
    ,ContactFirstName NVARCHAR(150) NULL
    --,DealSize NVARCHAR(150) NULL
    ,InsertDate DATETIME2 (7)  NULL
    ,UpdateDate DATETIME2 (7)  NULL
)
WITH
(
CLUSTERED INDEX (CustomerId), DISTRIBUTION = REPLICATE
)
GO
