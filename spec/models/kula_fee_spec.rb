# == Schema Information
#
# Table name: kula_fees
#
#  id              :integer          not null, primary key
#  partner_id      :integer
#  kula_rate       :decimal(6, 3)    not null
#  effective_date  :date
#  expiration_date :date
#  created_at      :datetime
#  updated_at      :datetime
#  discount_rate   :decimal(6, 3)    not null
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
    expect(fee).to respond_to(:rate)
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
