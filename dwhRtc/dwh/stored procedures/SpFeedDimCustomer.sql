	CREATE PROC [dwh].[SpFeedDimCustomer] AS
	BEGIN

			/* ***************************************************************************************************
			   Preparation of the staging data before merging it with the destination table : 
				- Rename field to meet the destination table
				- Cast field's type to meet the destination table 
				- Find Foreign Keys
			**************************************************************************************************** */
			--Drop the CTAS table if it already exists
			IF OBJECT_ID('tempdb..#PrepCustomers', 'U') IS NOT NULL
				DROP TABLE #PrepCustomers

			CREATE TABLE #PrepCustomers
			WITH (
				DISTRIBUTION = ROUND_ROBIN
				,CLUSTERED COLUMNSTORE INDEX
			)
			 AS
			 /****** Script for SelectTopNRows command from SSMS  ******/
			WITH _Customers_ AS (
				SELECT DISTINCT 
						[CUSTOMERNAME]
					  ,[PHONE]
					  ,[ADDRESSLINE1]
					  ,[ADDRESSLINE2]
					  ,[CITY]
					  ,[STATE]
					  ,[POSTALCODE]
					  ,[COUNTRY]
					  ,[TERRITORY]
					  ,[CONTACTLASTNAME]
					  ,[CONTACTFIRSTNAME]
					  ,[DEALSIZE]
				  FROM [FormationAzure].[stg].[sales_data_sample]
				)

				SELECT	CustomerName= [CUSTOMERNAME]
					  ,Phone = [PHONE]
					  ,AddressLine1 = [ADDRESSLINE1]
					  ,AddressLine2 = [ADDRESSLINE2]
					  ,City = [CITY]
					  ,State = [STATE]
					  ,PostalCode = [POSTALCODE]
					  ,Country = [COUNTRY]
					  ,Territory = [TERRITORY]
					  ,ContactLastName = [CONTACTLASTNAME]
					  ,ContactFirstName = [CONTACTFIRSTNAME]
--					  ,DealSize = [DEALSIZE]
					  ,InsertDate =  GETDATE()
					  ,UpdateDate =  CAST(NULL AS DATETIME2 (0))
					  ,FlagAction = CASE WHEN dim.ProductId IS NULL THEN 'I' 
										WHEN NOT(dim.AlAffiliateId IS NOT NULL 
											AND src.AddressLine1 = dim.AddressLine1
											AND src.AddressLine2 = dim.AddressLine2
											AND src.City = dim.City
											AND src.State = dim.State
											AND src.PostalCode = dim.PostalCode
											AND src.Country = dim.Country
											AND src.Territory = dim.Territory
											AND src.ContactLastName = dim.ContactLastName
											AND src.ContactFirstName = dim.ContactFirstName) THEN 'U' END
				FROM	_Customers_ src
				LEFT JOIN [dwh].DimCustomer dim
					ON	src.CustomerName = dim.CustomerName
				
				--Insert new records
				INSERT INTO [dwh].DimCustomer(CustomerName,Phone,AddressLine1,AddressLine2,City,State,PostalCode,Country,Territory,ContactLastName
												,ContactFirstName,InsertDate,UpdateDate)
				SELECT	CustomerName
						,Phone
						,AddressLine1
						,AddressLine2
						,City
						,State
						,PostalCode
						,Country
						,Territory
						,ContactLastName
						,ContactFirstName
						,InsertDate
						,UpdateDate
				FROM	#PrepCustomers
				WHERE	FlagAction = 'I'

				--Update existing record
				UPDATE	[dwh].DimCustomer 
					SET [dwh].DimCustomer.CustomerName = src.CustomerName
						,[dwh].DimCustomer.Phone = src.Phone
						,[dwh].DimCustomer.AddressLine1 = src.AddressLine1
						,[dwh].DimCustomer.AddressLine2 = src.AddressLine2
						,[dwh].DimCustomer.City = src.City
						,[dwh].DimCustomer.State = src.State
						,[dwh].DimCustomer.PostalCode = src.PostalCode
						,[dwh].DimCustomer.Country = src.Country
						,[dwh].DimCustomer.Territory = src.Territory
						,[dwh].DimCustomer.ContactLastName = src.ContactLastName
						,[dwh].DimCustomer.ContactFirstName = src.ContactFirstName
						,[dwh].DimCustomer.UpdateDate =  GETDATE()			
				FROM	#PrepCustomers src
				WHERE	src.CustomerId = [dwh].DimCustomer.CustomerId
				AND		src.FlagAction = 'U'
	
			--Drop all CTAS table (only use as a temporary table)
			IF OBJECT_ID('tempdb..#PrepCustomers', 'U') IS NOT NULL
				DROP TABLE #PrepCustomers

	END

