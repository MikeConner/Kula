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
#

describe Adjustment do
  let(:batch) { FactoryGirl.create(:batch) }
  let(:adjustment) { FactoryGirl.create(:adjustment, :batch => batch) }
  
  subject { adjustment }
  
  it "should respond to everything" do
    expect(adjustment).to respond_to(:batch_id)
    expect(adjustment).to respond_to(:amount)
    expect(adjustment).to respond_to(:date)
    expect(adjustment).to respond_to(:comment)
  end
  
  its(:batch) { should be == batch }
  
  it { should be_valid }
  
  describe "Invalid amount" do
    ['abc', nil, ' '].each do |a|
      before { adjustment.amount = a }
      
      it { should_not be_valid }
    end
  end  
end
