# == Schema Information
#
# Table name: distributors
#
#  distributor_identifier :integer          not null, primary key
#  name                   :string(64)       not null
#  display_name           :string(64)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

describe Distributor do
  let(:distributor) { FactoryGirl.create(:distributor) }
  
  subject { distributor }
  
  it "should respond to everything" do
    expect(distributor).to respond_to(:name)
    expect(distributor).to respond_to(:display_name)
  end
  
  it { should be_valid }
  
  describe "Missing name" do
    before { distributor.name = ' ' }
    
    it { should_not be_valid }
  end
end
