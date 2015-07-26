# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  batch_id       :integer
#  status         :string(16)
#  amount         :decimal(8, 2)    not null
#  date           :datetime
#  confirmation   :string(255)
#  payment_method :string(8)
#  address        :string(255)
#  comment        :text(65535)
#  created_at     :datetime
#  updated_at     :datetime
#  cause_id       :integer
#

describe Payment do
  let(:batch) { FactoryGirl.create(:batch) }
  let(:cause) { FactoryGirl.create(:cause) }
  let(:payment) { FactoryGirl.create(:payment, :batch => batch, :cause => cause) }
  
  subject { payment }
  
  it "should respond to everything" do
    expect(payment).to respond_to(:batch_id)
    expect(payment).to respond_to(:cause_id)
    expect(payment).to respond_to(:status)
    expect(payment).to respond_to(:amount)
    expect(payment).to respond_to(:date)
    expect(payment).to respond_to(:confirmation)
    expect(payment).to respond_to(:payment_method)
    expect(payment).to respond_to(:address)
    expect(payment).to respond_to(:comment)
  end
  
  its(:batch) { should be == batch }
  its(:cause) { should be == cause }
  
  it { should be_valid }
  
  describe "Invalid status" do
    [nil, 'fish'].each do |s|
      before { payment.status = s }
      
      it { should_not be_valid }
    end
  end
  
  describe "Invalid amount" do
    [0, -2, 'abc', nil, ' '].each do |a|
      before { payment.amount = a }
      
      it { should_not be_valid }
    end
  end
  
  describe "Invalid method" do
    [nil, ' ', 'Not a method'].each do |m|
      before { payment.payment_method = m }
      
      it { should_not be_valid }
    end
  end
end
