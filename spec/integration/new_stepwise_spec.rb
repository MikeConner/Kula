require 'rake'

describe "New Stepwise import" do
  let(:query1_results) { Rails.application.assets.find_asset('query_step1.csv').filename }
  let(:query2_results) { Rails.application.assets.find_asset('query_step2.csv').filename }
  let(:query3_results) { Rails.application.assets.find_asset('query_step3.csv').filename }
  let(:kula_fees_file) { Rails.application.assets.find_asset('kula_fees.csv').filename }
  let(:kula) { FactoryGirl.create(:kula_partner) }
  
  describe "Step 1" do
    before do
      # Set up kula fees
      
      first = true
      CSV.foreach(query1_results) do |tx|
        if first
          first = false
          next
        end
        
        cid = tx[8].to_i
        month = tx[1].to_i
        year = tx[2].to_i

        # distributor is always nil
        fee = kula.current_kula_rate(nil, Date.parse("#{year}-#{month}-01"))

        unless fee.nil?
          gross = tx[3].to_f
          usa = 'US' == tx[10].strip
          cause_type = tx[11].to_i
          cause_name = tx[9]

          fees = calculate_fees(fee, cause_type, gross, usa)

          CauseTransaction.create!({:partner_identifier => partner_id,
                                    :cause_identifier => cid,
                                    :month => month,
                                    :year => year,
                                    :gross_amount => gross,
                                    :legacy_net => tx[5].to_f,
                                    :legacy_donee => tx[7].to_f,
                                    :legacy_discounts => tx[4].to_f,
                                    :legacy_fees => tx[6].to_f,
                                    :donee_amount => gross - fees[:calc_kula_fee] - fees[:calc_foundation_fee],
                                    :calc_kula_fee => fees[:calc_kula_fee],
                                    :calc_foundation_fee => fees[:calc_foundation_fee],
                                    :calc_distributor_fee => 0,
                                    :calc_credit_card_fee => 0})
        end
      end
    end
    
    it "should work" do
      expect(@results.count).to eq(255)
    end
  end
end
