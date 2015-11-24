require 'rake'

describe "Stepwise import" do
  let(:partner) { FactoryGirl.create(:partner) }
  let(:cause) { FactoryGirl.create(:cause) }
    
  describe "test deletion (universal)" do
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
    
    it "should delete all cause transactions (but not payments)" do
      expect(CauseTransaction.count).to eq(10)
      expect(CauseBalance.count).to eq(12)
      
      Rake::Task["db:stepwise_import_transactions"].invoke
      Rake::Task["db:stepwise_import_transactions"].reenable
      
      # Invoking with no arguments should delete everything except payments and adjustments
      expect(CauseTransaction.count).to eq(0)
      expect(CauseBalance.count).to be >= 2
    end
  end

  describe "test deletion (annual)" do
    let(:test_year) { 2014 }
    let(:wrong_year) { 2013 }
    
    before do
      allow(CauseTransaction).to receive(:query_step1).and_return(nil)
      allow(CauseTransaction).to receive(:query_step2).and_return(nil)
      allow(CauseTransaction).to receive(:query_step3).and_return(nil)
      allow(CauseTransaction).to receive(:query_current_date).and_return('SELECT DISTINCT created FROM replicated_tx_balances ORDER BY created LIMIT 1')
      allow(CauseTransaction).to receive(:query_latest_date).and_return('SELECT DISTINCT created FROM replicated_tx_balances ORDER BY created DESC LIMIT 1')
      
      FactoryGirl.create_list(:cause_transaction, 10, :year => test_year)
      FactoryGirl.create_list(:cause_balance, 10, :year => test_year)
      FactoryGirl.create_list(:cause_transaction, 2, :year => wrong_year)
      FactoryGirl.create_list(:cause_balance, 2, :year => wrong_year)
      FactoryGirl.create(:cause_balance, :balance_type => CauseBalance::PAYMENT, :year => wrong_year)      
      FactoryGirl.create(:cause_balance, :balance_type => CauseBalance::ADJUSTMENT, :year => wrong_year)  
      FactoryGirl.create_list(:replicated_tx_balance, 10)    
      Kula::Application.load_tasks
    end
    
    it "should delete all cause transactions (but not payments)" do
      expect(CauseTransaction.count).to eq(12)
      expect(CauseBalance.count).to eq(14)
      expect(CauseBalance.where(:year => test_year).count).to eq(10)
      expect(CauseBalance.where(:year => wrong_year).count).to eq(4)
      
      Rake::Task["db:stepwise_import_transactions"].invoke(0,test_year)
      Rake::Task["db:stepwise_import_transactions"].reenable
      
      # Invoking with no arguments should delete everything except payments and adjustments
      expect(CauseTransaction.count).to eq(2)
      expect(CauseBalance.count).to be >= 4
      CauseTransaction.all.each do |ct|
        expect(ct.year).to eq(wrong_year)
      end
      CauseBalance.all.each do |cb|
        test = (wrong_year == cb.year) || ([CauseBalance::PAYMENT, CauseBalance::ADJUSTMENT].include?(cb.balance_type))
        expect(test).to be true
      end
    end
  end

  describe "test deletion (partner, all time)" do
    let(:wrong_partner) { FactoryGirl.create(:partner) }
    
    before do
      allow(CauseTransaction).to receive(:query_step1).and_return(nil)
      allow(CauseTransaction).to receive(:query_step2).and_return(nil)
      allow(CauseTransaction).to receive(:query_step3).and_return(nil)
      allow(CauseTransaction).to receive(:query_current_date).and_return('SELECT DISTINCT created FROM replicated_tx_balances ORDER BY created LIMIT 1')
      allow(CauseTransaction).to receive(:query_latest_date).and_return('SELECT DISTINCT created FROM replicated_tx_balances ORDER BY created DESC LIMIT 1')
      
      FactoryGirl.create_list(:cause_transaction, 10, :partner_identifier => partner.partner_identifier )
      FactoryGirl.create_list(:cause_balance, 10, :partner => partner)
      FactoryGirl.create_list(:cause_transaction, 2, :partner_identifier => wrong_partner.partner_identifier )
      FactoryGirl.create_list(:cause_balance, 2, :partner => wrong_partner)
      FactoryGirl.create(:cause_balance, :balance_type => CauseBalance::PAYMENT)      
      FactoryGirl.create(:cause_balance, :balance_type => CauseBalance::ADJUSTMENT)  
      FactoryGirl.create_list(:replicated_tx_balance, 10)    
      Kula::Application.load_tasks
    end
    
    it "should delete all cause transactions" do
      expect(CauseTransaction.count).to eq(12)
      expect(CauseBalance.count).to eq(14)
      
      Rake::Task["db:stepwise_import_transactions"].invoke(partner.partner_identifier)
      Rake::Task["db:stepwise_import_transactions"].reenable
      
      # Invoking with no arguments should delete everything except payments and adjustments
      expect(CauseTransaction.count).to eq(2)
      expect(CauseBalance.count).to be >= 4
      CauseTransaction.all.each do |ct|
        expect(ct.partner_identifier).to eq(wrong_partner.partner_identifier)
      end
      CauseBalance.all.each do |cb|
        test = (partner.partner_identifier != cb.partner_id) || ([CauseBalance::PAYMENT, CauseBalance::ADJUSTMENT].include?(cb.balance_type))
        expect(test).to be true
      end
    end
  end
end
