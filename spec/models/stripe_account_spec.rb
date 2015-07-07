# == Schema Information
#
# Table name: stripe_accounts
#
#  id         :integer          not null, primary key
#  cause_id   :integer
#  token      :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#

describe StripeAccount do
  let(:cause) { FactoryGirl.create(:cause) }
  let(:stripe) { FactoryGirl.create(:stripe_account, :cause => cause) }
  
  subject { stripe }
  
  it "should respond to everything" do
    expect(stripe).to respond_to(:cause_id)
    expect(stripe).to respond_to(:token)
  end
  
  its(:cause) { should be == cause }
  
  it { should be_valid }
  
  describe "Missing token" do
    before { stripe.token = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Token too long" do
    before { stripe.token = 's'*(StripeAccount::MAX_TOKEN_LEN + 1) }
    
    it { should_not be_valid }
  end
end
