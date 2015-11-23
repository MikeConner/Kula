# == Schema Information
#
# Table name: adjustments
#
#  id         :integer          not null, primary key
#  batch_id   :integer
#  amount     :decimal(8, 2)    not null
#  date       :datetime
#  comment    :text
#  created_at :datetime
#  updated_at :datetime
#  cause_id   :integer
#  month      :integer          not null
#  year       :integer          not null
#

describe Adjustment do
  let(:batch) { FactoryGirl.create(:batch) }
  let(:cause) { FactoryGirl.create(:cause) }
  let(:adjustment) { FactoryGirl.create(:adjustment, :batch => batch, :cause => cause) }
  
  subject { adjustment }
  
  it "should respond to everything" do
    expect(adjustment).to respond_to(:batch_id)
    expect(adjustment).to respond_to(:cause_id)
    expect(adjustment).to respond_to(:amount)
    expect(adjustment).to respond_to(:date)
    expect(adjustment).to respond_to(:comment)
    expect(adjustment).to respond_to(:month)
    expect(adjustment).to respond_to(:year)
    expect(adjustment).to respond_to(:partner)
  end
  
  its(:batch) { should be == batch }
  its(:cause) { should be == cause }
  its(:partner) { should be == batch.partner }
  
  it { should be_valid }
  
  describe "Invalid amount" do
    ['abc', nil, ' '].each do |a|
      before { adjustment.amount = a }
      
      it { should_not be_valid }
    end
  end  
  
  describe "Invalid month" do 
    [0, 2.5, 'abc', nil, ' '].each do |m|
      before { adjustment.month = m }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid year" do 
    [2000, 2012.5, 'abc', nil, ' '].each do |y|
      before { adjustment.year = y }
      
      it { should_not be_valid }
    end
  end
end
