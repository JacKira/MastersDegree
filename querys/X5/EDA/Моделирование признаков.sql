USE X5_RETAIL
GO





--SELECT TOP(1000) *
--FROM dbo.X5_Retail_TRANS t
--DROP TABLE #PreProcTrans

SELECT DISTINCT t.client_id
	   , t.transaction_datetime
	   ,  CONCAT(t.transaction_datetime, t.store_id, t.transaction_id) [chk]
	  , CASE WHEN DENSE_RANK() OVER(PARTITION BY t.client_id
						, CONCAT(t.transaction_datetime, t.store_id, t.transaction_id)
						ORDER BY t.product_id) = 1 THEN  t.purchase_sum END purchase_sum
	  , CASE WHEN DENSE_RANK() OVER(PARTITION BY t.client_id
						, CONCAT(t.transaction_datetime, t.store_id, t.transaction_id)
						ORDER BY t.product_id) = 1 THEN  regular_points_received END regular_points_received
	  , CASE WHEN DENSE_RANK() OVER(PARTITION BY t.client_id
						, CONCAT(t.transaction_datetime, t.store_id, t.transaction_id)
						ORDER BY t.product_id) = 1 THEN  express_points_received END express_points_received
	  , CASE WHEN DENSE_RANK() OVER(PARTITION BY t.client_id
						, CONCAT(t.transaction_datetime, t.store_id, t.transaction_id)
						ORDER BY t.product_id) = 1 THEN  regular_points_spent END regular_points_spent
	  , CASE WHEN DENSE_RANK() OVER(PARTITION BY t.client_id
						, CONCAT(t.transaction_datetime, t.store_id, t.transaction_id)
						ORDER BY t.product_id) = 1 THEN  express_points_spent END express_points_spent 
	  , trn_sum_from_iss LINEAMOUNT
	  , t.product_id
	  , b.brand
	  , s.segment
	  , inv.is_alcohol
	  , inv.is_own_trademark
	  --, inv.netto * t.product_quantity [netto]
INTO #PreProcTrans
FROM dbo.X5_Retail_TRANS t
JOIN dbo.X5_Retail_INVENTTABLE inv ON inv.product_id = t.product_id
LEFT JOIN [dbo].[X5_INVENT_TOP_BRAND] b ON b.brand = inv.brand_id
LEFT JOIN [dbo].[X5_INVENT_TOP_SEGMENTS] s ON s.segment = inv.segment_id

ALTER TABLE #PreProcTrans
ALTER COLUMN segment float
--DROP TABLE #ChkStat

SELECT DISTINCT client_id
	   , transaction_datetime
	   ,  [chk]
	   , SUM(purchase_sum) [Amount]
	   , SUM(regular_points_received) regular_points_received
	   , SUM(express_points_received) express_points_received
	   , ABS(SUM(regular_points_spent)) regular_points_spent
	   , ABS(SUM(express_points_spent )) express_points_spent 

	   ,  ABS(SUM(regular_points_spent) + SUM(express_points_spent))  Total_bonus_spent
	   , CASE WHEN (SUM(regular_points_spent) + SUM(express_points_spent))  <> 0 THEN SUM(purchase_sum) ELSE 0 END Amount_When_Spent
	   , max(CASE WHEN (coalesce(regular_points_spent, 0) + coalesce(express_points_spent, 0) ) <> 0 THEN 1 ELSE 0  END) Purch_When_Spent
	   , cast(count(product_id) as float) ITEMS
	   , SUM(CASE WHEN COALESCE(brand, '-') = '4da2dc345f' then 1
					else 0
			end) * 1.0 / cast(count(product_id) as float) [TOP_1_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = 'ab230258e9' then 1
					else 0
			end) * 1.0 / cast(count(product_id) as float) [TOP_2_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = '' then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_3_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = '037a833d06' then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_4_BRAND]
	   ,  SUM(CASE WHEN COALESCE(brand, '-') = '8281de6bcb' then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_5_BRAND]
		
		,   SUM(CASE WHEN COALESCE([segment], 0) = 105 then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_1_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 230 then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_2_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 18 then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_3_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 1 then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_4_segment]
		,   SUM(CASE WHEN COALESCE([segment], 0) = 9 then 1
					else 0
			end) * 1.0/ cast(count(product_id) as float) [TOP_5_segment]	
	  	
	  , sum(is_alcohol) * 1.0/ cast(count(product_id) as float) [Alcohol_in_chk] 
	  , sum(is_own_trademark) * 1.0/ cast(count(product_id) as float) [CTM_in_chk]
	  --, sum([netto]) [netto]
	  , DATEDIFF(dd, LAG(transaction_datetime) OVER(PARTITION BY client_id ORDER BY transaction_datetime ASC),  transaction_datetime) [Days_between_chk]
INTO #ChkStat
FROM #PreProcTrans t
GROUP BY client_id
	   , transaction_datetime
	   ,  [chk]



DECLARE @end_dt datetime = (SELECT MAX(t.transaction_datetime) FROM dbo.X5_Retail_TRANS t);


SELECT client_id
	   , SUM(regular_points_received) regular_points_received
	   , SUM(express_points_received) express_points_received
	   , SUM(regular_points_spent) regular_points_spent
	   , SUM(express_points_spent ) express_points_spent 
		
       , SUM(regular_points_received) - SUM(regular_points_spent) regular_balance
	   , SUM(express_points_received) - SUM(express_points_spent ) express_balance
	   , sum(Amount) Total_Amount
	   , sum(coalesce(Amount_When_SPent, 0)) Amount_BonusDiscount_purchs
	   , SUM(Total_bonus_spent) * 1.0 /  sum(coalesce(Total_bonus_spent, 0) + coalesce(Amount_When_SPent, 0) + 1e-12) BonusDiscount
	   
		, CAST(AVG(s.Amount) AS float) [MeanChk]

	  , AVG(regular_points_received) avg_regular_points_received
	   , AVG(express_points_received) avg_express_points_received
	   , AVG(regular_points_spent) avg_regular_points_spent
	   , AVG(express_points_spent ) avg_express_points_spent 


	  
		, CAST(sum(amount) *1.0 / sum(ITEMS) AS float) [MeanItemCost]
		, COUNT(DISTINCT chk) [Chks]
		, sum(Purch_When_Spent) * 1.0 / COUNT(DISTINCT chk) Part_BonusDiscount_purchs
		, sum(Purch_When_Spent) cnt_BonusDiscount_purchs

		, DATEDIFF(dd, MAX(S.transaction_datetime), @end_dt) [last_chk_ago]
		, CAST(AVG(TOP_1_BRAND) AS float) [Mean_TOP_1_BRAND]
		, CAST(AVG(TOP_2_BRAND) AS float) [Mean_TOP_2_BRAND]
		, CAST(AVG(TOP_3_BRAND) AS float) [Mean_TOP_3_BRAND]
		, CAST(AVG(TOP_4_BRAND) AS float) [Mean_TOP_4_BRAND]
		, CAST(AVG(TOP_5_BRAND) AS float) [Mean_TOP_5_BRAND]
		, CAST(AVG(TOP_1_segment) AS float) [Mean_TOP_1_SEG]
		, CAST(AVG(TOP_2_segment) AS float) [Mean_TOP_2_SEG]
		, CAST(AVG(TOP_3_segment) AS float) [Mean_TOP_3_SEG]
		, CAST(AVG(TOP_4_segment) AS float) [Mean_TOP_4_SEG]
		, CAST(AVG(TOP_5_segment) AS float) [Mean_TOP_5_SEG]
		, CAST(AVG(CASE WHEN Alcohol_in_chk > 0 THEN Alcohol_in_chk END) AS float) [Mean_alc]
		, CAST(AVG(CASE WHEN CTM_in_chk > 0 THEN CTM_in_chk END) AS float) [Mean_CTM]
		, COUNT(DISTINCT CASE WHEN Alcohol_in_chk > 0 THEN chk END) * 1.0 / COUNT(DISTINCT chk) [Part_alc_purchs]
		, COUNT(DISTINCT CASE WHEN CTM_in_chk > 0 THEN chk END) * 1.0 / COUNT(DISTINCT chk) [PArt_CTM_purchs]
		, COUNT(DISTINCT CASE WHEN Alcohol_in_chk > 0 THEN chk END)  [cnt_alc_purchs]
		, COUNT(DISTINCT CASE WHEN CTM_in_chk > 0 THEN chk END)  [cnt_CTM_purchs]
			--, CAST(AVG(netto) AS float) [Mean_netto]
		, CAST(AVG([Days_between_chk]) AS float) [Mean_diffs]	
		, min(transaction_datetime) first_order_date
INTO #ClientsStat
FROM #ChkStat s
GROUP BY client_id





SELECT DISTINCT s.*
		, c.age	 
		, (CASE WHEN cast(c.first_redeem_date as date) = first_order_date then 1
			   WHEN (cast(c.first_redeem_date as date) > first_order_date) THEN 2
			   ELSE 0
			END) [LoveBonuses]
		, (CASE WHEN gender = 'F' THEN 0
			   WHEN gender = 'M' THEN 1
			   ELSE -1
		  END) [Gender]
		
INTO dbo.X5_DATA_SET
FROM X5_Retail_CLIENTS c
LEFT JOIN #ClientsStat s ON s.client_id = c.client_id


DROP TABLE #ClientsStat
--DROP TABLE #ChkStat
--DROP TABLE #PreProcTrans
--DROP TABLE X5_RETAIL.dbo.X5_DATA_SET


