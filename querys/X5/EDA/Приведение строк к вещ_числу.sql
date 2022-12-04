/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
SELECT TOP (1000) [client_id]
      ,[transaction_id]
      ,[transaction_datetime]
      ,[regular_points_received]
      ,[express_points_received]
      ,[regular_points_spent]
      ,[express_points_spent]
      ,[purchase_sum]
      ,[store_id]
      ,[product_id]
      ,[product_quantity]
      ,[trn_sum_from_iss]
      ,[trn_sum_from_red]
  FROM [X5_RETAIL].[dbo].[X5_Retail_TRANS]

  UPDATE  [X5_RETAIL].[dbo].[X5_Retail_TRANS]
  SET --regular_points_received = REPLACE(REPLACE(regular_points_received, ',', '.'), ' ', '')
	--, express_points_received = REPLACE(REPLACE(express_points_received, ',', '.'), ' ', '')
	--, [regular_points_spent] = REPLACE(REPLACE([regular_points_spent], ',', '.'), ' ', '')
	--, [express_points_spent] = REPLACE(REPLACE([express_points_spent], ',', '.'), ' ', '')
	--, [purchase_sum] = REPLACE(REPLACE([purchase_sum], ',', '.'), ' ', '')
	--, 
	[product_quantity] = REPLACE(REPLACE([product_quantity], ',', '.'), ' ', '')
	--, [trn_sum_from_iss] = REPLACE(CASE [trn_sum_from_iss] WHEN '' THEN NULL ELSE REPLACE([trn_sum_from_iss], ',', '.') END, ' ', '')
	--, [trn_sum_from_red] = REPLACE(CASE [trn_sum_from_red] WHEN '' THEN NULL ELSE REPLACE([trn_sum_from_red], ',', '.') END, ' ', '')


	--ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	--ALTER COLUMN regular_points_received float;

	--ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	--ALTER COLUMN express_points_received float;

	--ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	--ALTER COLUMN [regular_points_spent] float;

	--ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	--ALTER COLUMN [express_points_spent] float;

	--ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	--ALTER COLUMN [purchase_sum] float;

	ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	ALTER COLUMN [product_quantity] float;

	ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	ALTER COLUMN [trn_sum_from_iss] float;

	ALTER TABLE [X5_RETAIL].[dbo].[X5_Retail_TRANS]
	ALTER COLUMN [trn_sum_from_red] float;