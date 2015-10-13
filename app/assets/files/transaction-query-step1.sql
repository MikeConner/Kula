SELECT 
        partner_id as PartnerId, Extract(MONTH from bt.created) as Month, Extract( Year from bt.created) as Year,
        COALESCE(SUM(bt.amount),0) as GrossAmount,
        COALESCE(SUM(bl_codes.total_cut_amount),0) AS DiscountAmount,
        COALESCE(SUM(bl_cause_less_codes.total_cut_amount),0) AS NetAmount,
	COALESCE(SUM(bl_kula.total_cut_amount),0)  AS KulaFees,
	COALESCE(SUM(bl_cause_less_codes_and_kula.total_cut_amount),0) AS DoneeAmount,
        c.cause_id AS CauseId,
		c.org_name as CauseName,

		c.country AS Country,
		c.type as CauseType 
    FROM
        replicated_balance_transactions bt
        
		INNER JOIN replicated_causes c 
			ON bt.cause_id = c.cause_id
 
		LEFT JOIN (SELECT  burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 2 GROUP BY burn_balance_transaction_id) 
			AS bl_codes ON bt.transaction_id = bl_codes.burn_balance_transaction_id
		LEFT JOIN (SELECT  burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 4 GROUP BY burn_balance_transaction_id) 
             AS bl_negative_correction_less_codes ON bt.transaction_id = bl_negative_correction_less_codes.burn_balance_transaction_id
		LEFT JOIN (SELECT burn_balance_transaction_id,SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type IN (5 , 8) GROUP BY burn_balance_transaction_id) 
			AS bl_kula ON bt.transaction_id = bl_kula.burn_balance_transaction_id
		LEFT JOIN (SELECT burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 6 GROUP BY burn_balance_transaction_id) 
			AS bl_cause_less_codes ON bt.transaction_id = bl_cause_less_codes.burn_balance_transaction_id
		LEFT JOIN (SELECT burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 7 GROUP BY burn_balance_transaction_id) 
			AS bl_cause_less_codes_and_kula ON bt.transaction_id = bl_cause_less_codes_and_kula.burn_balance_transaction_id 
	
    WHERE bt.type = 1 AND bt.status = 1 
            AND bt.user_id NOT IN (34156,96194,34161,34162,74812, 34413 , 34414) AND
            (bt.created BETWEEN ##START_DATE AND ##END_DATE)
            ##PARTNER_CLAUSE
            
            AND NOT (bt.user_id = 34371 AND bt.partner_id = 10 AND bt.created = '2013-06-26 00:05:29')
            AND NOT (bt.user_id = 34356 AND bt.partner_id = 10 AND bt.created = '2013-06-26 01:15:07')
            AND NOT (bt.user_id = 34371 AND bt.partner_id = 10 AND bt.created = '2013-06-26 22:41:33')
            AND NOT (bt.user_id = 34356 AND bt.partner_id = 10 AND bt.created = '2013-11-27 23:24:48')
GROUP BY Extract(MONTH from bt.created)  , Extract( Year from bt.created), partner_id, c.cause_id
