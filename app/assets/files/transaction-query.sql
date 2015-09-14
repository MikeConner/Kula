SELECT 
	 
     COALESCE((SELECT distinct batch_partner_id FROM kula.partner_codes where code in (select distinct cut_payee_id from burn_links where burn_balance_transaction_id =  bt.transaction_id and type =2 and batch_partner_id not in (18,19))),0) as distributor,
		bt.transaction_id,
        partner_id, month( bt.created),year( bt.created),

		COALESCE(SUM(bt.amount), 0) AS `Gross contribution Amount`,
        COALESCE(SUM(bl_codes.total_cut_amount), 0) AS `Discounts Amount`,
        COALESCE(SUM(bl_cause_less_codes.total_cut_amount),
                0) AS `Net amount ($)`,
        COALESCE(SUM(bl_kula.total_cut_amount), 0) AS `Kula/Foundation fees ($)`,
        COALESCE(SUM(bl_cause_less_codes_and_kula.total_cut_amount),
                0) AS `Donee amount ($)`,
        
        c.org_name AS `name`,
		c.address1,
		c.address2,
		c.address3,
		c.city,
		c.region,
		c.postal_code,
        c.country AS `Country`,
        c.mailing_address,
        c.mailing_city,
        c.mailing_state,
        c.mailing_postal_code,
		c.type AS 'Cause type',
        c.org_email AS `Organization email`,
		c.org_phone AS 'Organization phone',
		c.org_fax AS 'Organization fax',
        c.tax_id AS `Tax ID`,
        c.has_ach_info AS 'Has ACH Information',
		c.site_url,
		c.logo_url,
		c.latitude,
		c.longitude,
		c.mission,
        c.cause_id AS `Cause ID`
    FROM
        balance_transactions bt
		INNER JOIN causes c 
			ON bt.cause_id = c.cause_id
		INNER JOIN users u 
			ON bt.user_id = u.user_id
		LEFT JOIN (SELECT  burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM burn_links WHERE type = 2 GROUP BY burn_balance_transaction_id) 
			AS bl_codes ON bt.transaction_id = bl_codes.burn_balance_transaction_id
		LEFT JOIN (SELECT  burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM burn_links WHERE type = 4 GROUP BY burn_balance_transaction_id) 
             AS bl_negative_correction_less_codes ON bt.transaction_id = bl_negative_correction_less_codes.burn_balance_transaction_id
		LEFT JOIN (SELECT burn_balance_transaction_id,SUM(cut_amount) AS total_cut_amount FROM burn_links WHERE type IN (5 , 8) GROUP BY burn_balance_transaction_id) 
			AS bl_kula ON bt.transaction_id = bl_kula.burn_balance_transaction_id
		LEFT JOIN (SELECT burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM burn_links WHERE type = 6 GROUP BY burn_balance_transaction_id) 
			AS bl_cause_less_codes ON bt.transaction_id = bl_cause_less_codes.burn_balance_transaction_id
		LEFT JOIN (SELECT burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM burn_links WHERE type = 7 GROUP BY burn_balance_transaction_id) 
			AS bl_cause_less_codes_and_kula ON bt.transaction_id = bl_cause_less_codes_and_kula.burn_balance_transaction_id 
	
    WHERE bt.type = 1 AND bt.status = 1 AND
          (bt.created BETWEEN ##START_DATE AND ##END_DATE)
            AND bt.user_id NOT IN (SELECT  u.user_id FROM users u INNER JOIN partner_user_map pum ON u.user_id = pum.user_id AND pum.partner_id = 24 WHERE                 u.email IN ('rashish@coca-cola.com' , 'ashish.ranjan@me.com',
                    'Prashant.bisht@igate.com',
                    'mkissel@us.ibm.com'))

             AND bt.user_id NOT IN (34413 , 34414)
            AND NOT (bt.user_id = 34371 AND bt.partner_id = 10 AND bt.created = '2013-06-26 00:05:29')
            AND NOT (bt.user_id = 34356 AND bt.partner_id = 10 AND bt.created = '2013-06-26 01:15:07')
            AND NOT (bt.user_id = 34371 AND bt.partner_id = 10 AND bt.created = '2013-06-26 22:41:33')
            AND NOT (bt.user_id = 34356 AND bt.partner_id = 10 AND bt.created = '2013-11-27 23:24:48')
            
     GROUP BY year( bt.created), month( bt.created), bt.partner_id,  c.cause_id, distributor
    ORDER BY c.org_name