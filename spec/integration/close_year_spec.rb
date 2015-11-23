require 'rake'

describe "Close year" do
  # Seed:
  # 2011 partner/cause/Donee amount total=18
  # 2012 partner/cause/Donee amount total=25
  # 2012 partner/cause/Gross total=75
  # 2013 partner/cause/Donee amount total=35
  # Close 2011, 2012, 2013
  # Rollover(y+1) = Rollover(y) + Total(y)
  #
  # Result:
  # 2012 partner/cause/Donee amount; rollover=18, total=25
  # 2013 partner/cause/Donee amount; rollover=43, total=35
  # 2013 partner/cause/Gross rollover=75, total=75
  # 2014 partner/cause/Donee amount: rollover=78; total=0
  # 2014 partner/cause/Gross rollover=150, total=0
  let(:partner) { FactoryGirl.create(:partner) }
  let(:cause) { FactoryGirl.create(:cause) }
  DA2011 = 18
  DA2012 = 25
  G2012 = 75
  DA2013 = 35
  
  describe "Close year tasks" do
    before do
      CauseBalance.create!(:partner => partner, :cause => cause, :year => 2011, :balance_type => CauseBalance::DONEE_AMOUNT, :total => DA2011)
      CauseBalance.create!(:partner => partner, :cause => cause, :year => 2012, :balance_type => CauseBalance::DONEE_AMOUNT, :total => DA2012)
      CauseBalance.create!(:partner => partner, :cause => cause, :year => 2012, :balance_type => CauseBalance::GROSS, :total => G2012)
      CauseBalance.create!(:partner => partner, :cause => cause, :year => 2013, :balance_type => CauseBalance::DONEE_AMOUNT, :total => DA2013)
      Kula::Application.load_tasks
    end
    
    it "should close each year" do
      expect(CauseBalance.count).to eq(4)

      Rake::Task["db:close_year"].invoke(2011)
      Rake::Task["db:close_year"].reenable
      
      # At this point, we should have a rollover balance in 2012
      keys = {:partner => partner, :cause => cause, :year => 2012, :balance_type => CauseBalance::DONEE_AMOUNT}
      cb = CauseBalance.where(keys).first
      expect(cb.prior_year_rollover).to eq(DA2011)
      expect(cb.total).to eq(DA2012)

      keys = {:partner => partner, :cause => cause, :year => 2012, :balance_type => CauseBalance::GROSS}
      cb = CauseBalance.where(keys).first
      expect(cb.prior_year_rollover).to eq(0)
      expect(cb.total).to eq(G2012)

      Rake::Task["db:close_year"].invoke(2012)
      Rake::Task["db:close_year"].reenable
      
      keys = {:partner => partner, :cause => cause, :year => 2013, :balance_type => CauseBalance::DONEE_AMOUNT}
      cb = CauseBalance.where(keys).first
      expect(cb.prior_year_rollover).to eq(DA2011 + DA2012)
      expect(cb.total).to eq(DA2013)

      keys = {:partner => partner, :cause => cause, :year => 2013, :balance_type => CauseBalance::GROSS}
      cb = CauseBalance.where(keys).first
      expect(cb.prior_year_rollover).to eq(G2012)
      expect(cb.total).to eq(0)

      Rake::Task["db:close_year"].invoke(2013)
      Rake::Task["db:close_year"].reenable
      
      keys = {:partner => partner, :cause => cause, :year => 2014, :balance_type => CauseBalance::DONEE_AMOUNT}
      cb = CauseBalance.where(keys).first
      expect(cb.prior_year_rollover).to eq(DA2011 + DA2012 + DA2013)
      expect(cb.total).to eq(0)

      keys = {:partner => partner, :cause => cause, :year => 2014, :balance_type => CauseBalance::GROSS}
      cb = CauseBalance.where(keys).first
      expect(cb.prior_year_rollover).to eq(G2012)
      expect(cb.total).to eq(0)
    end
  end
end
