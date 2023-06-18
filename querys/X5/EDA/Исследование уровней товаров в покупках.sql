USE X5_RETAIL
GO


SELECT  * 
		,  ROW_NUMBER() OVER(PARTITION BY [level]										  
							ORDER BY [qty] DESC) [Number]
INTO dbo.X5_INVENT_TOP_LEVELS
FROM(
		SELECT TOP(5) '1' [level]
						, inv.level_1 [level_name]
						, SUM(t.product_quantity) [qty]
		FROM dbo.X5_Retail_INVENTTABLE inv
		JOIN dbo.X5_Retail_TRANS t ON t.product_id = inv.product_id
		GROUP BY inv.level_1
		ORDER BY [qty] DESC

		UNION ALL

		SELECT TOP(5) '2' [level], inv.level_2 [level_name], SUM(t.product_quantity) [qty]
		FROM dbo.X5_Retail_INVENTTABLE inv
		JOIN dbo.X5_Retail_TRANS t ON t.product_id = inv.product_id
		GROUP BY inv.level_2
		ORDER BY [qty] DESC

		UNION ALL

		SELECT TOP(5) '3' [level], inv.level_3 [level_name], SUM(t.product_quantity) [qty]
		FROM dbo.X5_Retail_INVENTTABLE inv
		JOIN dbo.X5_Retail_TRANS t ON t.product_id = inv.product_id
		GROUP BY inv.level_3
		ORDER BY [qty] DESC

		UNION ALL

		SELECT TOP(5) '4' [level], inv.level_4 [level_name], SUM(t.product_quantity) [qty]
		FROM dbo.X5_Retail_INVENTTABLE inv
		JOIN dbo.X5_Retail_TRANS t ON t.product_id = inv.product_id
		GROUP BY inv.level_4
		ORDER BY [qty] DESC
) T

