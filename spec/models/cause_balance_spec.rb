# == Schema Information
#
# Table name: cause_balances
#
#  id                  :integer          not null, primary key
#  partner_id          :integer          not null
#  cause_id            :integer          not null
#  year                :integer          not null
#  balance_type        :string(16)
#  jan                 :decimal(8, 2)    default(0.0), not null
#  feb                 :decimal(8, 2)    default(0.0), not null
#  mar                 :decimal(8, 2)    default(0.0), not null
#  apr                 :decimal(8, 2)    default(0.0), not null
#  may                 :decimal(8, 2)    default(0.0), not null
#  jun                 :decimal(8, 2)    default(0.0), not null
#  jul                 :decimal(8, 2)    default(0.0), not null
#  aug                 :decimal(8, 2)    default(0.0), not null
#  sep                 :decimal(8, 2)    default(0.0), not null
#  oct                 :decimal(8, 2)    default(0.0), not null
#  nov                 :decimal(8, 2)    default(0.0), not null
#  dec                 :decimal(8, 2)    default(0.0), not null
#  total               :decimal(8, 2)    default(0.0), not null
#  created_at          :datetime
#  updated_at          :datetime
#  prior_year_rollover :decimal(8, 2)    default(0.0), not null
#

describe CauseBalance do
  let(:partner) { FactoryGirl.create(:partner) }
  let(:cause) { FactoryGirl.create(:cause) }
  let(:balance) { FactoryGirl.create(:cause_balance, :partner => partner, :cause => cause, :balance_type => CauseBalance::DONEE_AMOUNT) }
  
  subject { balance }
  
  it "should respond to everything" do
    expect(balance).to respond_to(:partner_id)
    expect(balance).to respond_to(:cause_id)
    expect(balance).to respond_to(:year)
    expect(balance).to respond_to(:balance_type)
    expect(balance).to respond_to(:jan)
    expect(balance).to respond_to(:feb)
    expect(balance).to respond_to(:mar)
    expect(balance).to respond_to(:apr)
    expect(balance).to respond_to(:may)
    expect(balance).to respond_to(:jun)
    expect(balance).to respond_to(:jul)
    expect(balance).to respond_to(:aug)
    expect(balance).to respond_to(:sep)
    expect(balance).to respond_to(:oct)
    expect(balance).to respond_to(:nov)
    expect(balance).to respond_to(:dec)
    expect(balance).to respond_to(:total)
    expect(balance).to respond_to(:prior_year_rollover)
  end
  
  its(:partner) { should be == partner }
  its(:cause) { should be == cause }
  
  it { should be_valid }
  
  describe "Invalid year" do
    [2000, 1985, -2, 2010.5, 'abc', ' '].each do |y|
      before { balance.year = y }
      
      it { should_not be_valid }
    end
  end
  
  describe "Payment is negative" do
    let(:balance) { FactoryGirl.create(:cause_balance, :partner => partner, :cause => cause, :balance_type => CauseBalance::PAYMENT, :total => -20.5) }

    it { should be_valid }
  end

  describe "Adjustment can be negative" do
    let(:balance) { FactoryGirl.create(:cause_balance, :partner => partner, :cause => cause, :balance_type => CauseBalance::ADJUSTMENT, :total => -20.5) }

    it { should be_valid }
  end

  describe "should fail" do
    CauseBalance::BALANCE_TYPES.each do |bt|
      next if (CauseBalance::ADJUSTMENT == bt) or (CauseBalance::PAYMENT == bt)
      
      before do
        balance.balance_type = bt
        balance.total = -Random.rand(100) - 2.5
      end
      
      it { should_not be_valid }
    end
  end
   
  describe "Missing balance_type" do
    before { balance.balance_type = ' ' }
    
    it { should_not be_valid }
  end

  describe "Invalid balance_type" do
    before { balance.balance_type = 'Not a type' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid jan" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.jan = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid feb" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.feb = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid mar" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.mar = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid apr" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.apr = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid may" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.may = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid jun" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.jun = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid jul" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.jul = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid aug" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.aug = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid sep" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.sep = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid oct" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.oct = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid nov" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.nov = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid dec" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.dec = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid total" do
    [-1, 'abc', ' ', nil].each do |val|
      before { balance.total = val }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid rollover" do
    before { balance.prior_year_rollover = 'abc' }
    
    it { should_not be_valid }
  end

  describe "Rollover can be negative" do
    before { balance.prior_year_rollover = -100.26 }
    
    it { should be_valid }
  end
end
