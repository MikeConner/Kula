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
  let(:fee) { FactoryGirl.create(:kula_fee, :partner => partner) }
  let(:universal) { FactoryGirl.create(:universal_rate_fee) }
  let(:unbounded_left) { FactoryGirl.create(:unbounded_left_fee) }
  let(:unbounded_right) { FactoryGirl.create(:unbounded_right_fee) }
  
  subject { fee }
  
  it "should respond to everything" do
    expect(fee).to respond_to(:partner)
    expect(fee).to respond_to(:distributor_rate)
    expect(fee).to respond_to(:us_school_rate)
    expect(fee).to respond_to(:us_charity_rate)
    expect(fee).to respond_to(:intl_charity_rate)
    expect(fee).to respond_to(:us_school_kf_rate)
    expect(fee).to respond_to(:us_charity_kf_rate)
    expect(fee).to respond_to(:intl_charity_kf_rate)
    expect(fee).to respond_to(:effective_date)
    expect(fee).to respond_to(:expiration_date)
    expect(fee).to respond_to(:universal?)
    expect(fee).to respond_to(:unbounded_left?)
    expect(fee).to respond_to(:unbounded_right?)
  end
  
  it { should be_valid }
  its(:partner) { should be == partner }
  
  it "should show categories" do
    expect(universal.universal?).to be true
    expect(universal.unbounded_left?).to be true
    expect(universal.unbounded_right?).to be true
    expect(unbounded_left.unbounded_left?).to be true
    expect(unbounded_left.unbounded_right?).to be false
    expect(unbounded_right.unbounded_right?).to be true
    expect(unbounded_right.unbounded_left?).to be false
  end  
end
