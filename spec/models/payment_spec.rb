# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  batch_id       :integer
#  status         :string(16)       default("Outstanding"), not null
#  amount         :decimal(8, 2)    not null
#  date           :datetime
#  confirmation   :string(255)
#  payment_method :string(8)        default("Check"), not null
#  address        :string(255)
#  comment        :text
#  created_at     :datetime
#  updated_at     :datetime
#  cause_id       :integer          not null
#  check_num      :integer          not null
#  month          :integer          not null
#  year           :integer          not null
#

describe Payment do
  let(:batch) { FactoryGirl.create(:batch) }
  let(:cause) { FactoryGirl.create(:cause) }
  let(:payment) { FactoryGirl.create(:payment, :batch => batch, :cause => cause) }
  let(:ach_payment) { FactoryGirl.create(:ach_payment) }
  
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
    expect(payment).to respond_to(:check_payment?)
    expect(payment).to respond_to(:ach_payment?)
    expect(payment).to respond_to(:deleted?)
  end
  
  its(:batch) { should be == batch }
  its(:cause) { should be == cause }
  its(:partner) { should be == batch.partner }
    
  it { should be_valid }
  
  describe "Invalid status (check)" do
    [nil, 'fish', Payment::RETURNED].each do |s|
      before { payment.status = s }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid status (ach)" do
    [nil, 'fish', Payment::CANCELLED, Payment::VOID].each do |s|
      before { ach_payment.status = s }
      
      it "shouldn't be valid" do
        expect(ach_payment).to_not be_valid
      end
    end
  end

  describe "Deleted status" do
    before do
      payment.status = Payment::DELETED
      ach_payment.status = Payment::DELETED
    end
    
    it { should be_valid }
    
    it "should delete ach too" do
      ach_payment.should be_valid
    end
  end
  
  describe "Invalid payment method" do
    before { payment.payment_method = 'Not a method' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid amount" do
    [0, -2, 'abc', nil, ' '].each do |a|
      before { payment.amount = a }
      
      it { should_not be_valid }
    end
  end
  
  describe "Missing check_num" do
    before { payment.check_num = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid method" do
    [nil, ' ', 'Not a method'].each do |m|
      before { payment.payment_method = m }
      
      it { should_not be_valid }
    end
  end
  
  describe "Invalid month" do 
    [0, 2.5, 'abc', nil, ' '].each do |m|
      before { payment.month = m }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid year" do 
    [2000, 2012.5, 'abc', nil, ' '].each do |y|
      before { payment.year = y }
      
      it { should_not be_valid }
    end
  end  
end
