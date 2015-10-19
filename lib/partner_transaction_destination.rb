require 'pg'

class PartnerTransactionDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    #TODO - Insert Cause Statement
    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_partner_transaction(
            partner_transaction_id, balance_transaction_id, partner_id, user_id,
            status, created, last_modified, points, user__id, amount, currency,
            ip_address, order_description, result_avs_result, result_billing_id,
            result_code, result_customer_vault_id, result_cvv_result, result_result_code,
            result_shipping_id, result_text, result_transaction_id, action_type,
            authorization__code, avs__result, billing_first_name, billing_last_name,
            billing_postal, customer__id, customer__vault_id, ccv__result,
            industry, ip__address, order__description, processor_id, processor_result_code,
            processor_result_text, result, result__text, result__code, shipping__amount,
            tax_amount, token__id, transaction__id, surcharge_amount, tip_amount,
            amount_authorized, giving_code, giving_code_email, giving_code_name,
            rr_transaction_id, cash_value, client_transaction_id, transaction_id,
            final_balance, billing_billing__id, shipping_shipping__id)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,
$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,
$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57);
   ')




    #INSERT INTO replicated_causes(cause_id, org_name) VALUES ($1, $2)
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:partner_transaction_id], row[:balance_transaction_id],  row[:partner_id], row[:user_id],  row[:status],  row[:created], row[:last_modified],      row[:points],  row[:user__id],   row[:amount],  row[:currency],      row[:ip_address],      row[:order_description],      row[:result_avs_result],
      row[:result_billing_id],  row[:result_code], row[:result_customer_vault_id], row[:result_cvv_result],row[:result_result_code],row[:result_shipping_id],    row[:result_text],  row[:result_transaction_id],  row[:action_type],
      row[:authorization__code], row[:avs__result], row[:billing_first_name], row[:billing_last_name], row[:billing_postal], row[:customer__id], row[:customer__vault_id], row[:ccv__result],
      row[:industry], row[:ip__address], row[:order__description], row[:processor_id], row[:processor_result_code], row[:processor_result_text], row[:result], row[:result__text], row[:result__code], row[:shipping__amount],
      row[:tax_amount],
      row[:token__id],
      row[:transaction__id],
      row[:surcharge_amount],
      row[:tip_amount],
      row[:amount_authorized],
      row[:giving_code],
      row[:giving_code_email],
      row[:giving_code_name],
      row[:rr_transaction_id],
      row[:cash_value],
      row[:client_transaction_id],
      row[:transaction_id],
      row[:final_balance],
      row[:billing_billing__id],
      row[:shipping_shipping__id],




     ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for  partner transaction ID: #{row[:partner_transaction_id]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end
