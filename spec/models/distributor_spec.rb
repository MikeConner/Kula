# == Schema Information
#
# Table name: distributors
#
#  id           :integer          not null, primary key
#  partner_id   :integer
#  name         :string(64)       not null
#  display_name :string(64)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

describe Distributor do
  let(:partner) { FactoryGirl.create(:partner) }
  let(:distributor) { FactoryGirl.create(:distributor, :partner => partner) }
  
  subject { distributor }
  
  it "should respond to everything" do
    expect(distributor).to respond_to(:partner)
    expect(distributor).to respond_to(:name)
    expect(distributor).to respond_to(:display_name)
  end
  
  it { should be_valid }
  its(:partner) { should be == partner }  
end