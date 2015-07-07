# == Schema Information
#
# Table name: partners
#
#  partner_identifier :integer          not null, primary key
#  name               :string(64)       not null
#  display_name       :string(64)       not null
#  domain             :string(64)       not null
#  currency           :string(3)        default("USD"), not null
#  created_at         :datetime
#  updated_at         :datetime
#

describe Partner do
  let(:partner) { FactoryGirl.create(:partner) }
  
  subject { partner }
  
  it "should respond to everything" do
    expect(partner).to respond_to(:partner_identifier)
    expect(partner).to respond_to(:name)
    expect(partner).to respond_to(:display_name)
    expect(partner).to respond_to(:domain)
    expect(partner).to respond_to(:currency)
  end
  
  it { should be_valid }

  describe "Missing id" do
    before { partner.partner_identifier = ' ' }
    
    it { should_not be_valid }
  end  

  describe "Duplicate id" do
    before do
      @partner = partner.dup
      @partner.partner_identifier = partner.partner_identifier
    end
    
    it "should not allow dups" do
      expect { @partner.save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end  

  describe "Missing name" do
    before { partner.name = ' ' }
    
    it { should_not be_valid }
  end  

  describe "Missing display_name" do
    before { partner.display_name = ' ' }
    
    it { should_not be_valid }
  end  

  describe "Missing domain" do
    before { partner.domain = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Name too long" do
    before { partner.name = 'n'*(Partner::MAX_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end  

  describe "Display name too long" do
    before { partner.display_name = 'n'*(Partner::MAX_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end  

  describe "Domain too long" do
    before { partner.domain = 'n'*(Partner::MAX_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end  

  describe "Currency too long" do
    before { partner.currency = 'n'*(Partner::MAX_CURRENCY_LEN + 1) }
    
    it { should_not be_valid }
  end  
  
  describe "Inconsistent fees" do
    before do
      partner.kula_fees.create!(:effective_date => nil, :expiration_date => 1.week.from_now, :rate => 0.05) 
      partner.kula_fees.create!(:effective_date => Date.today, :expiration_date => 1.year.from_now, :rate => 0.1)
    end
    
    it "should not allow new one" do
      expect(partner.kula_fees.count).to eq(2)
      expect(partner).to_not be_valid
    end
  end
  
  describe "partner with universal" do
    let(:partner) { FactoryGirl.create(:partner_with_universal_fee) }
    
    before { @fee = partner.kula_fees.first }
    
    it "should be consistent" do
      expect(@fee).to be_valid
      expect(partner.current_rate).to eq(@fee.rate)
      expect(@fee.valid_on?(10.years.from_now)).to be true
    end
  end

  describe "partner with unbounded left" do
    let(:partner) { FactoryGirl.create(:partner_with_unbounded_left_fee) }
    
    before { @fee = partner.kula_fees.first }
    
    it "should be consistent" do
      expect(@fee).to be_valid
      expect(partner.current_rate).to eq(@fee.rate)
      expect(@fee.valid_on?(10.years.ago)).to be true
      expect(@fee.valid_on?(10.years.from_now)).to be false
    end
  end

  describe "partner with unbounded right" do
    let(:partner) { FactoryGirl.create(:partner_with_unbounded_right_fee) }
    
    before { @fee = partner.kula_fees.first }
    
    it "should be consistent" do
      expect(@fee).to be_valid
      expect(partner.current_rate).to eq(@fee.rate)
      expect(@fee.valid_on?(10.years.ago)).to be false
      expect(@fee.valid_on?(10.years.from_now)).to be true
    end
  end

  describe "partner with bounded fee" do
    let(:partner) { FactoryGirl.create(:partner_with_bounded_fee) }
    
    before { @fee = partner.kula_fees.first }
    
    it "should be consistent" do
      expect(@fee).to be_valid
      expect(partner.current_rate).to eq(@fee.rate)
      expect(@fee.valid_on?(10.years.ago)).to be false
      expect(@fee.valid_on?(10.years.from_now)).to be false
      expect(@fee.valid_on?(Date.today)).to be true
    end
  end

  describe "partner with multiple fees" do
    let(:partner) { FactoryGirl.create(:partner_with_fees) }
    
    before do
      @old_fee = partner.kula_fees.first
      @new_fee = partner.kula_fees.last
    end
    
    it "should be consistent" do
      expect(partner.kula_fees.count).to eq(2)
      expect(@old_fee).to be_valid
      expect(@new_fee).to be_valid
      expect(partner.current_rate).to eq(@old_fee.rate)
      expect(@old_fee.valid_on?(10.years.ago)).to be true
      expect(@new_fee.valid_on?(10.years.from_now)).to be true
      expect(@new_fee.valid_on?(10.years.from_now)).to be true
      expect(@new_fee.valid_on?(10.years.ago)).to be false
      expect(@old_fee.valid_on?(Date.today)).to be true
      expect(@new_fee.valid_on?(Date.today)).to be false
      expect(@old_fee.valid_on?(Date.tomorrow)).to be false
      expect(@new_fee.valid_on?(Date.tomorrow)).to be true
    end
    
    describe "destroy" do
      before { partner.destroy }
      
      it "should be gone" do
        expect(KulaFee.count).to eq(0)
      end
    end
  end
end
