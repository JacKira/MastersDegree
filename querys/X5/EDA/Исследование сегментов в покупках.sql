
SELECT  * 
		,  ROW_NUMBER() OVER(PARTITION BY 1										  
							ORDER BY [qty] DESC) [Number]
INTO dbo.X5_INVENT_TOP_SEGMENTS
FROM(
		SELECT TOP(5) inv.segment_id [segment]
						, SUM(t.product_quantity) [qty]
		FROM dbo.X5_Retail_INVENTTABLE inv
		JOIN dbo.X5_Retail_TRANS t ON t.product_id = inv.product_id
		GROUP BY inv.segment_id
		ORDER BY [qty] DESC
	) T
		ORDER BY [NUMBER]