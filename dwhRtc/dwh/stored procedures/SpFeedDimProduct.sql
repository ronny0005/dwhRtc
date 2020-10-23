	CREATE PROC [dwh].[SpFeedDimProduct] AS
	BEGIN

			/* ***************************************************************************************************
			   Preparation of the staging data before merging it with the destination table : 
				- Rename field to meet the destination table
				- Cast field's type to meet the destination table 
				- Find Foreign Keys
			**************************************************************************************************** */
			--Drop the CTAS table if it already exists
			IF OBJECT_ID('tempdb..#PrepProducts', 'U') IS NOT NULL
				DROP TABLE #PrepProducts

			CREATE TABLE #PrepProducts
			WITH (
				DISTRIBUTION = ROUND_ROBIN
				,CLUSTERED COLUMNSTORE INDEX
			)
			 AS
			 /****** Script for SelectTopNRows command from SSMS  ******/
			WITH _Products_ AS (
			SELECT  DISTINCT [PRODUCTLINE]
					,[MSRP]
					,[PRODUCTCODE]
			FROM	[FormationAzure].[stg].[sales_data_sample]
			)
			SELECT	ProductId = dim.ProductId
					,ProductLine = src.[PRODUCTLINE]
					,Msrp = src.[MSRP]
					,ProductCode = src.[PRODUCTCODE]
					,InsertDate =  GETDATE()
					,UpdateDate =  CAST(NULL AS DATETIME2 (0))
					,FlagAction = CASE WHEN dim.ProductId IS NULL THEN 'I' 
										WHEN NOT(dim.AlAffiliateId IS NOT NULL 
											AND src.[PRODUCTCODE] = dim.ProductCode
											AND dao.ProductLine = dim.ProductLine) THEN 'U' END
			FROM	_Products_ src
			LEFT JOIN [dwh].DimProduct dim
					ON	src.ProductCode = dim.ProductCode
				
				--Insert new records
				INSERT INTO [dwh].DimProduct(ProductLine,Msrp,ProductCode,InsertDate,UpdateDate)
				SELECT	ProductLine
						,Msrp
						,ProductCode
						,InsertDate
						,UpdateDate
				FROM	#PrepProducts
				WHERE	FlagAction = 'I'

				--Update existing record
				UPDATE	[dwh].DimProduct 
					SET [dwh].DimProduct.ProductLine = src.ProductLine
						,[dwh].DimProduct.Msrp = src.Msrp
						,[dwh].DimProduct.ProductCode = src.ProductCode
						,[dwh].DimProduct.UpdateDate =  GETDATE()			
				FROM	#PrepProducts src
				WHERE	src.ProductId = [dwh].DimProducts.ProductId
				AND		src.FlagAction = 'U'
	
			--Drop all CTAS table (only use as a temporary table)
			IF OBJECT_ID('tempdb..#PrepProducts', 'U') IS NOT NULL
				DROP TABLE #PrepProducts

	END

