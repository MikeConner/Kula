# == Schema Information
#
# Table name: kula_fees
#
#  id                     :integer          not null, primary key
#  partner_identifier     :integer
#  effective_date         :date
#  expiration_date        :date
#  created_at             :datetime
#  updated_at             :datetime
#  us_school_rate         :decimal(6, 4)    default(0.0)
#  us_charity_rate        :decimal(6, 4)    default(0.0)
#  intl_charity_rate      :decimal(6, 4)    default(0.0)
#  us_school_kf_rate      :decimal(6, 4)    default(0.0)
#  us_charity_kf_rate     :decimal(6, 4)    default(0.0)
#  intl_charity_kf_rate   :decimal(6, 4)    default(0.0)
#  distributor_rate       :decimal(6, 4)    default(0.0)
#  distributor_identifier :integer
#  mcr_cc_rate            :decimal(6, 4)    default(0.0)
#

describe KulaFee do
  let(:partner) { FactoryGirl.create(:partner) }
  let(:distributor) { FactoryGirl.create(:distributor) }
  let(:fee) { FactoryGirl.create(:kula_fee, :partner => partner) }
  let(:dist_fee) { FactoryGirl.create(:kula_fee, :partner => partner, :distributor => distributor) }
  
  let(:universal) { FactoryGirl.create(:universal_rate_fee) }
  let(:unbounded_left) { FactoryGirl.create(:unbounded_left_fee) }
  let(:unbounded_right) { FactoryGirl.create(:unbounded_right_fee) }
  
  subject { fee }
  
  it "should respond to everything" do
    expect(fee).to respond_to(:partner)
    expect(fee).to respond_to(:distributor_rate)
    expect(fee).to respond_to(:distributor_identifier)
    expect(fee).to respond_to(:us_school_rate)
    expect(fee).to respond_to(:us_charity_rate)
    expect(fee).to respond_to(:intl_charity_rate)
    expect(fee).to respond_to(:us_school_kf_rate)
    expect(fee).to respond_to(:us_charity_kf_rate)
    expect(fee).to respond_to(:intl_charity_kf_rate)
    expect(fee).to respond_to(:mcr_cc_rate)
    expect(fee).to respond_to(:effective_date)
    expect(fee).to respond_to(:expiration_date)
    expect(fee).to respond_to(:universal?)
    expect(fee).to respond_to(:unbounded_left?)
    expect(fee).to respond_to(:unbounded_right?)
  end

  its(:partner) { should be == partner }

  it "should match distributors" do
    expect(dist_fee.distributor).to be == distributor
  end  
  
  it { should be_valid }
  
  it "should show categories" do
    expect(universal.universal?).to be true
    expect(universal.unbounded_left?).to be true
    expect(universal.unbounded_right?).to be true
    expect(unbounded_left.unbounded_left?).to be true
    expect(unbounded_left.unbounded_right?).to be false
    expect(unbounded_right.unbounded_right?).to be true
    expect(unbounded_right.unbounded_left?).to be false
  end  

  describe "Invalid distributor rate" do
    before { fee.distributor_rate = -2 }
    
    it { should_not be_valid }
  end
  
  describe "Invalid mcr_cc rate" do
    before { fee.mcr_cc_rate = -2 }
    
    it { should_not be_valid }
  end
  
  describe "Invalid us school rate" do
    before { fee.us_school_rate = -2 }
    
    it { should_not be_valid }
  end

  describe "Invalid us charity rate" do
    before { fee.us_charity_rate = -2 }
    
    it { should_not be_valid }
  end

  describe "Invalid intl charity rate" do
    before { fee.intl_charity_rate = -2 }
    
    it { should_not be_valid }
  end

  describe "Invalid us school kf rate" do
    before { fee.us_school_kf_rate = -2 }
    
    it { should_not be_valid }
  end

  describe "Invalid us charity kf rate" do
    before { fee.us_charity_kf_rate = -2 }
    
    it { should_not be_valid }
  end

  describe "Invalid intl charity kf rate" do
    before { fee.intl_charity_kf_rate = -2 }
    
    it { should_not be_valid }
  end
end
