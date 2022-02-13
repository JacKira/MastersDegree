USE X5
GO

--DROP TABLE #PreProcTrans

SELECT DISTINCT t.client_id
	   , t.transaction_datetime
	   ,  CONCAT(t.transaction_datetime, t.store_id, t.transaction_id) [chk]
	  , t.purchase_sum
	  , t.product_id
	  , b.brand
	  , l.[level]
	--  , l.[level_name]
	  , s.segment
	  , v.vendor
	  , inv.is_alcohol
	  , inv.is_own_trademark
	  , inv.netto * t.product_quantity [netto]
INTO #PreProcTrans
FROM dbo.X5_Retail_TRANS t
JOIN dbo.X5_Retail_INVENTTABLE inv ON inv.product_id = t.product_id
LEFT JOIN [dbo].[X5_INVENT_TOP_BRAND] b ON b.brand = inv.brand_id
LEFT JOIN [dbo].[X5_INVENT_TOP_SEGMENTS] s ON s.segment = inv.segment_id
LEFT JOIN [dbo].[X5_INVENT_TOP_VENDOR] v ON v.vendor = inv.vendor_id
LEFT JOIN [dbo].[X5_INVENT_TOP_LEVELS] l ON (l.[level] = '1' and l.level_name = inv.level_1)
--										 OR (l.[level] = '2' and l.level_name = inv.level_2)
--										 OR (l.[level] = '3' and l.level_name = inv.level_3)
--										 OR (l.[level] = '4' and l.level_name = inv.level_4)
