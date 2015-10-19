require 'mysql2'
require 'uri'



class PartnerTransactionSource
  # connect_url should look like;
  # mysql://user:password@localhost/dbname


  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
  end

#connect_hash(connect_url)
  def each
    results = @mysql.query("SELECT pt.*,
	ptcf1.value as points,
    ptcf2.value as user__id,
    ptcf3.value as amount,
    ptcf4.value as currency,
    ptcf5.value as ip_address,
    ptcf6.value as order_description,
    ptcf7.value as result_avs_result,

    ptcf8.value as result_billing_id,
    ptcf9.value as result_code,
    ptcf10.value as result_customer_vault_id,
    ptcf11.value as result_cvv_result,
    ptcf12.value as result_result_code,
    ptcf13.value as result_shipping_id,
    ptcf14.value as result_text,
    ptcf15.value as result_transaction_id,
    ptcf16.value as action_type,
    ptcf17.value as authorization__code,
    ptcf18.value as avs__result,

    ptcf19.value as billing_first_name,

    ptcf20.value as billing_last_name,
    ptcf21.value as billing_postal,
    ptcf22.value as customer__id,
    ptcf23.value as customer__vault_id,
    ptcf24.value as ccv__result,
    ptcf25.value as industry,
    ptcf26.value as ip__address,
    ptcf27.value as order__description,
    ptcf28.value as processor_id,
    ptcf29.value as processor_result_code,
    ptcf30.value as processor_result_text,
    ptcf31.value as result,

    ptcf32.value as result__text,
    ptcf33.value as result__code,
    ptcf34.value as shipping__amount,
    ptcf35.value as tax_amount,
    ptcf36.value as token__id,
    ptcf37.value as transaction__id,
    ptcf38.value as surcharge_amount,
    ptcf39.value as tip_amount,
    ptcf40.value as amount_authorized,
    ptcf41.value as giving_code,
    ptcf42.value as giving_code_email,
    ptcf43.value as giving_code_name,
    ptcf44.value as rr_transaction_id,
    ptcf45.value as cash_value,
    ptcf46.value as client_transaction_id,
    ptcf47.value as transaction_id,
    ptcf48.value as final_balance,
    ptcf49.value as billing_billing__id,
    ptcf50.value as shipping_shipping__id




  FROM kula.partner_transaction pt
	LEFT OUTER JOIN kula.partner_transaction_field ptcf1 on ptcf1.partner_transaction_id = pt.partner_transaction_id and  ptcf1.name = 'points'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf2 on ptcf2.partner_transaction_id = pt.partner_transaction_id and  ptcf2.name = 'user_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf3 on ptcf3.partner_transaction_id = pt.partner_transaction_id and  ptcf3.name = 'amount'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf4 on ptcf4.partner_transaction_id = pt.partner_transaction_id and  ptcf4.name = 'currency'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf5 on ptcf5.partner_transaction_id = pt.partner_transaction_id and  ptcf5.name = 'ip_address'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf6 on ptcf6.partner_transaction_id = pt.partner_transaction_id and  ptcf6.name = 'order_description'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf7 on ptcf7.partner_transaction_id = pt.partner_transaction_id and  ptcf7.name = 'result_avs_result'

	LEFT OUTER JOIN kula.partner_transaction_field ptcf8 on ptcf8.partner_transaction_id = pt.partner_transaction_id and    ptcf8.name = 'result_billing_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf9 on ptcf9.partner_transaction_id = pt.partner_transaction_id and    ptcf9.name = 'result_code'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf10 on ptcf10.partner_transaction_id = pt.partner_transaction_id and  ptcf10.name = 'result_customer_vault_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf11 on ptcf11.partner_transaction_id = pt.partner_transaction_id and  ptcf11.name = 'result_cvv_result'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf12 on ptcf12.partner_transaction_id = pt.partner_transaction_id and  ptcf12.name = 'result_result_code'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf13 on ptcf13.partner_transaction_id = pt.partner_transaction_id and  ptcf13.name = 'result_shipping_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf14 on ptcf14.partner_transaction_id = pt.partner_transaction_id and  ptcf14.name = 'result_text'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf15 on ptcf15.partner_transaction_id = pt.partner_transaction_id and  ptcf15.name = 'result_transaction_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf16 on ptcf16.partner_transaction_id = pt.partner_transaction_id and  ptcf16.name = 'action-type'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf17 on ptcf17.partner_transaction_id = pt.partner_transaction_id and  ptcf17.name = 'authorization-code'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf18 on ptcf18.partner_transaction_id = pt.partner_transaction_id and  ptcf18.name = 'avs-result'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf19 on ptcf19.partner_transaction_id = pt.partner_transaction_id and  ptcf19.name = 'billing.first-name'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf20 on ptcf20.partner_transaction_id = pt.partner_transaction_id and  ptcf20.name = 'billing.last-name'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf21 on ptcf21.partner_transaction_id = pt.partner_transaction_id and  ptcf21.name = 'billing.postal'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf22 on ptcf22.partner_transaction_id = pt.partner_transaction_id and  ptcf22.name = 'customer-id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf23 on ptcf23.partner_transaction_id = pt.partner_transaction_id and  ptcf23.name = 'customer-vault-id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf24 on ptcf24.partner_transaction_id = pt.partner_transaction_id and  ptcf24.name = 'cvv-result'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf25 on ptcf25.partner_transaction_id = pt.partner_transaction_id and  ptcf25.name = 'industry'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf26 on ptcf26.partner_transaction_id = pt.partner_transaction_id and  ptcf26.name = 'ip-address'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf27 on ptcf27.partner_transaction_id = pt.partner_transaction_id and  ptcf27.name = 'order-description'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf28 on ptcf28.partner_transaction_id = pt.partner_transaction_id and  ptcf28.name = 'processor-id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf29 on ptcf29.partner_transaction_id = pt.partner_transaction_id and  ptcf29.name = 'processor-result-code'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf30 on ptcf30.partner_transaction_id = pt.partner_transaction_id and  ptcf30.name = 'processor-result-text'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf31 on ptcf31.partner_transaction_id = pt.partner_transaction_id and  ptcf31.name = 'result'

	LEFT OUTER JOIN kula.partner_transaction_field ptcf32 on ptcf32.partner_transaction_id = pt.partner_transaction_id and  ptcf32.name = 'result-code'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf33 on ptcf33.partner_transaction_id = pt.partner_transaction_id and  ptcf33.name = 'result-text'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf34 on ptcf34.partner_transaction_id = pt.partner_transaction_id and  ptcf34.name = 'shipping-amount'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf35 on ptcf35.partner_transaction_id = pt.partner_transaction_id and  ptcf35.name = 'tax-amount'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf36 on ptcf36.partner_transaction_id = pt.partner_transaction_id and  ptcf36.name = 'token-id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf37 on ptcf37.partner_transaction_id = pt.partner_transaction_id and  ptcf37.name = 'transaction-id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf38 on ptcf38.partner_transaction_id = pt.partner_transaction_id and  ptcf38.name = 'surcharge-amount'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf39 on ptcf39.partner_transaction_id = pt.partner_transaction_id and  ptcf39.name = 'tip-amount'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf40 on ptcf40.partner_transaction_id = pt.partner_transaction_id and  ptcf40.name = 'amount-authorized'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf41 on ptcf41.partner_transaction_id = pt.partner_transaction_id and  ptcf41.name = 'giving-code'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf42 on ptcf42.partner_transaction_id = pt.partner_transaction_id and  ptcf42.name = 'giving-code-email'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf43 on ptcf43.partner_transaction_id = pt.partner_transaction_id and  ptcf43.name = 'giving-code-name'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf44 on ptcf44.partner_transaction_id = pt.partner_transaction_id and  ptcf44.name = 'rr_transaction_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf45 on ptcf45.partner_transaction_id = pt.partner_transaction_id and  ptcf45.name = 'cash_value'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf46 on ptcf46.partner_transaction_id = pt.partner_transaction_id and  ptcf46.name = 'client_transaction_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf47 on ptcf47.partner_transaction_id = pt.partner_transaction_id and  ptcf47.name = 'transaction_id'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf48 on ptcf48.partner_transaction_id = pt.partner_transaction_id and  ptcf48.name = 'final_balance'
	LEFT OUTER JOIN kula.partner_transaction_field ptcf49 on ptcf49.partner_transaction_id = pt.partner_transaction_id and  ptcf49.name = 'billing.billing-id'

	LEFT OUTER JOIN kula.partner_transaction_field ptcf50 on ptcf50.partner_transaction_id = pt.partner_transaction_id and  ptcf50.name = 'shipping.shipping-id'", as: :hash, symbolize_keys: true)
    results.each do |row|

      yield(row)
    end
  end


end
