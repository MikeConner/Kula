# == Schema Information
#
# Table name: cause_transactions
#
#  id                    :integer          not null, primary key
#  partner_identifier    :integer          not null
#  cause_identifier      :integer          not null
#  month                 :integer          not null
#  year                  :integer          not null
#  gross_amount          :decimal(8, 2)    default(0.0)
#  legacy_net            :decimal(8, 2)    default(0.0)
#  legacy_donee          :decimal(8, 2)    default(0.0)
#  legacy_discounts      :decimal(8, 2)    default(0.0)
#  legacy_fees           :decimal(8, 2)    default(0.0)
#  calc_kula_fee         :decimal(8, 2)    default(0.0)
#  calc_foundation_fee   :decimal(8, 2)    default(0.0)
#  calc_distributor_fee  :decimal(8, 2)    default(0.0)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  calc_credit_card_fee  :decimal(8, 2)    default(0.0)
#  donee_amount          :decimal(8, 2)
#  original_donee_amount :decimal(8, 2)
#

describe CauseTransaction do
  let(:tx) { FactoryGirl.create(:cause_transaction) }
  
  subject { tx }
  
  it "should respond to everything" do
    expect(tx).to respond_to(:partner_identifier)
    expect(tx).to respond_to(:cause_identifier)
    expect(tx).to respond_to(:month)
    expect(tx).to respond_to(:year)
    expect(tx).to respond_to(:gross_amount)
    expect(tx).to respond_to(:legacy_net)
    expect(tx).to respond_to(:legacy_donee)
    expect(tx).to respond_to(:legacy_discounts)
    expect(tx).to respond_to(:legacy_fees)
    expect(tx).to respond_to(:calc_kula_fee)
    expect(tx).to respond_to(:calc_foundation_fee)
    expect(tx).to respond_to(:calc_distributor_fee)
    expect(tx).to respond_to(:calc_credit_card_fee)
    expect(tx).to respond_to(:donee_amount)
  end
  
  it { should be_valid }
  
  describe "Invalid partner_identifier" do
    [0, 'abc', nil].each do |id|
      before { tx.partner_identifier = id }
    
      it { should_not be_valid }
    end
  end

  describe "Invalid cause_identifier" do
    [0, 'abc', nil].each do |id|
      before { tx.cause_identifier = id }
    
      it { should_not be_valid }
    end
  end
  
  describe "Invalid month" do 
    [0, 2.5, 'abc', nil, ' '].each do |m|
      before { tx.month = m }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid year" do 
    [2000, 2012.5, 'abc', nil, ' '].each do |y|
      before { tx.year = y }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid gross_amount" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.gross_amount = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid legacy_net" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.legacy_net = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid legacy_donee" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.legacy_donee = amt }
      
      it { should_not be_valid }
    end
  end
  
  describe "Invalid legacy_discounts" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.legacy_discounts = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid legacy_fees" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.legacy_fees = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid donee_amount" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.donee_amount = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid calc_kula_fee" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.calc_kula_fee = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid calc_foundation_fee" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.calc_foundation_fee = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid calc_distributor_fee" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.calc_distributor_fee = amt }
      
      it { should_not be_valid }
    end
  end

  describe "Invalid calc_credit_card_fee" do 
    [-1, 'abc', nil, ' '].each do |amt|
      before { tx.calc_credit_card_fee = amt }
      
      it { should_not be_valid }
    end
  end
end
