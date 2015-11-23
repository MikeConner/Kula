require 'rake'

describe "Stepwise import" do
  let(:partner) { FactoryGirl.create(:partner) }
  let(:cause) { FactoryGirl.create(:cause) }
    
  describe "test deletion" do
    before do
      allow(CauseTransaction).to receive(:query_step1).and_return(nil)
      allow(CauseTransaction).to receive(:query_step2).and_return(nil)
      allow(CauseTransaction).to receive(:query_step3).and_return(nil)
      allow(CauseTransaction).to receive(:query_current_date).and_return('SELECT DISTINCT created FROM replicated_tx_balances ORDER BY created LIMIT 1')
      allow(CauseTransaction).to receive(:query_latest_date).and_return('SELECT DISTINCT created FROM replicated_tx_balances ORDER BY created DESC LIMIT 1')
      
      FactoryGirl.create_list(:cause_transaction, 10)
      FactoryGirl.create_list(:cause_balance, 10)
      FactoryGirl.create(:cause_balance, :balance_type => CauseBalance::PAYMENT)      
      FactoryGirl.create(:cause_balance, :balance_type => CauseBalance::ADJUSTMENT)  
      FactoryGirl.create_list(:replicated_tx_balance, 10)    
      Kula::Application.load_tasks
    end
    
    it "should delete all cause transactions" do
      expect(CauseTransaction.count).to eq(10)
      expect(CauseBalance.count).to eq(12)
      
      Rake::Task["db:stepwise_import_transactions"].invoke
      Rake::Task["db:stepwise_import_transactions"].reenable
      
      # Invoking with no arguments should delete everything except payments and adjustments
      expect(CauseTransaction.count).to eq(0)
      expect(CauseBalance.count).to be >= 2
    end
  end
end
