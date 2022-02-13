USE X5
GO

--DROP TABLE #PreProcTrans

SELECT DISTINCT t.client_id
	   , t.transaction_datetime
	   ,  CONCAT(t.transaction_datetime, t.store_id, t.transaction_id) [chk]
	  , t.purchase_sum
	  , t.product_id
	  , b.brand
	--  , l.[level]
	  , l.[level_name]
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


--DROP TABLE #ChkStat

SELECT DISTINCT client_id
	   , transaction_datetime
	   ,  [chk]
	   , MAX(purchase_sum) [Amount]
	   , MAX(purchase_sum) /  cast(count(product_id) as float)  [MeanItemCost]
	   , SUM(CASE WHEN COALESCE(brand, '-') = '4da2dc345f' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_1_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = 'ab230258e9' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_2_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = '' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_3_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = '037a833d06' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_4_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = '8281de6bcb' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_5_BRAND]
		,   SUM(CASE WHEN COALESCE([level_name], '-') = 'e344ab2e71' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_1_level]
		,   SUM(CASE WHEN COALESCE([level_name], '-') = 'c3d3a8e8c6' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_2_level]
		,   SUM(CASE WHEN COALESCE([level_name], '-') = 'ec62ce61e3' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_3_level]
		,   SUM(CASE WHEN COALESCE([level_name], '-') = '' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_4_level]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 105 then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_1_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 230 then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_2_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 18 then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_3_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 1 then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_4_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 9 then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_5_segment]	
	  	,   SUM(CASE WHEN COALESCE([vendor], '-') = '43acd80c1a' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_1_vendor]	
		,   SUM(CASE WHEN COALESCE([vendor], '-') = 'e6af81215a' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_2_vendor]
		,   SUM(CASE WHEN COALESCE([vendor], '-') = '6bc8b3c476' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_3_vendor]
		,   SUM(CASE WHEN COALESCE([vendor], '-') = '63243765ed' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_4_vendor]
		,    SUM(CASE WHEN COALESCE([vendor], '-') = 'bf8fc0055c' then 1
					else 0
			end) / cast(count(product_id) as float) [TOP_5_vendor]
	  , sum(is_alcohol) / cast(count(product_id) as float) [Alcohol_in_chk] 
	  , sum(is_own_trademark) / cast(count(product_id) as float) [CTM_in_chk]
	  , sum([netto]) [netto]
	  , DATEDIFF(dd, LAG(transaction_datetime) OVER(PARTITION BY client_id ORDER BY transaction_datetime ASC),  transaction_datetime) [Days_between_chk]
INTO #ChkStat
FROM #PreProcTrans t
GROUP BY client_id
	   , transaction_datetime
	   ,  [chk]


DECLARE @end_dt datetime;

SET @end_dt = (SELECT MAX(t.transaction_datetime) FROM #ChkStat t);

SELECT client_id
		, CAST(AVG(s.Amount) AS float) [MeanChk]
		, CAST(AVG(s.MeanItemCost) AS float) [MeanItemCost]
		, COUNT(DISTINCT chk) [Chks]
		, DATEDIFF(dd, MAX(S.transaction_datetime), @end_dt) [last_chk_ago]
		, CAST(AVG(TOP_1_BRAND) AS float) [Mean_TOP_1_BRAND]
		, CAST(AVG(TOP_2_BRAND) AS float) [Mean_TOP_2_BRAND]
		, CAST(AVG(TOP_3_BRAND) AS float) [Mean_TOP_3_BRAND]
		, CAST(AVG(TOP_4_BRAND) AS float) [Mean_TOP_4_BRAND]
		, CAST(AVG(TOP_5_BRAND) AS float) [Mean_TOP_5_BRAND]
		, CAST(AVG(TOP_1_vendor) AS float) [Mean_TOP_1_VENDOR]
		, CAST(AVG(TOP_2_vendor) AS float) [Mean_TOP_2_VENDOR]
		, CAST(AVG(TOP_3_vendor) AS float) [Mean_TOP_3_VENDOR]
		, CAST(AVG(TOP_4_vendor) AS float) [Mean_TOP_4_VENDOR]
		, CAST(AVG(TOP_5_vendor) AS float) [Mean_TOP_5_VENDOR]
		, CAST(AVG(TOP_1_segment) AS float) [Mean_TOP_1_SEG]
		, CAST(AVG(TOP_2_segment) AS float) [Mean_TOP_2_SEG]
		, CAST(AVG(TOP_3_segment) AS float) [Mean_TOP_3_SEG]
		, CAST(AVG(TOP_4_segment) AS float) [Mean_TOP_4_SEG]
		, CAST(AVG(TOP_5_segment) AS float) [Mean_TOP_5_SEG]
		, CAST(AVG(TOP_1_level) AS float) [Mean_TOP_1_LVL]
		, CAST(AVG(TOP_2_level) AS float) [Mean_TOP_2_LVL]
		, CAST(AVG(TOP_3_level) AS float) [Mean_TOP_3_LVL]
		, CAST(AVG(TOP_4_level) AS float) [Mean_TOP_4_LVL]
		, CAST(AVG(Alcohol_in_chk) AS float) [Mean_alc]
		, CAST(AVG(CTM_in_chk) AS float) [Mean_CTM]
		, CAST(AVG(netto) AS float) [Mean_netto]
		, CAST(AVG([Days_between_chk]) AS float) [Mean_diffs]		
INTO #ClientsStat
FROM #ChkStat s
GROUP BY client_id




DECLARE @start_dt datetime;

SET @start_dt = (SELECT Min(t.transaction_datetime) FROM #ChkStat t);


SELECT DISTINCT s.*
		, c.age	 
		, (CASE WHEN cast(c.first_redeem_date as date) >= @start_dt then 1
			   WHEN ((cast(c.first_redeem_date as date) < @start_dt)
				AND (cast(c.first_redeem_date as date) <> '1900-01-01')) THEN 2
			   ELSE 0
			END) [NewComerFlag]
		, (CASE WHEN gender = 'F' THEN 0
			   WHEN gender = 'M' THEN 1
			   ELSE -1
		  END) [Gender]
		
INTO dbo.X5_DATA_SET
FROM X5_Retail_CLIENTS c
LEFT JOIN #ClientsStat s ON s.client_id = c.client_id


DROP TABLE #ClientsStat
DROP TABLE #ChkStat
DROP TABLE #PreProcTrans



