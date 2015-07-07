# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  role                   :string(16)
#  partner_id             :integer
#  cause_id               :integer
#

describe User do
  let(:user) { FactoryGirl.create(:user) }
  
  subject { user }
  
  it "should respond to everything" do
    expect(user).to respond_to(:email)
    expect(user).to respond_to(:role)
    expect(user).to respond_to(:partner?)
    expect(user).to respond_to(:cause?)
  end
  
  describe "Partner user" do
    let(:partner) { FactoryGirl.create(:partner) }
    let(:user) { FactoryGirl.create(:partner_user, :partner => partner) }
    
    it "should be a partner" do
      expect(user.partner?).to be true
      expect(User.partners.count).to eq(1)
      expect(User.partners.ids.include?(user.id)).to be true
    end
    
    its(:partner) { should be == partner }
    
    describe "Inconsistent partner role" do
      before { user.role = nil }
      
      it { should_not be_valid }
    end
    
    describe "Inconsistent partner id" do
      before { user.partner_id = nil }
      
      it { should_not be_valid }
    end
  end
end
