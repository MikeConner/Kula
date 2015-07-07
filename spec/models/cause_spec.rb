# == Schema Information
#
# Table name: causes
#
#  cause_identifier    :string(64)       not null, primary key
#  name                :string(255)      not null
#  cause_type          :integer          not null
#  has_ach_info        :boolean          default(FALSE), not null
#  email               :string(255)
#  phone               :string(64)
#  fax                 :string(64)
#  tax_id              :string(64)
#  address_1           :string(128)
#  address_2           :string(128)
#  address_3           :string(128)
#  city                :string(64)
#  region              :string(64)
#  country             :string(2)        not null
#  postal_code         :string(16)
#  mailing_address     :string(128)
#  mailing_city        :string(64)
#  mailing_state       :string(64)
#  mailing_postal_code :string(16)
#  site_url            :string(255)
#  logo_url            :string(255)
#  latitude            :integer
#  longitude           :integer
#  mission             :text
#  created_at          :datetime
#  updated_at          :datetime
#

describe Cause do
  let(:cause) { FactoryGirl.create(:cause) }
  
  subject { cause }
  
  it "should respond to everything" do
    expect(cause).to respond_to(:cause_identifier)
    expect(cause).to respond_to(:name)
    expect(cause).to respond_to(:cause_type)
    expect(cause).to respond_to(:has_ach_info)
    expect(cause).to respond_to(:email)
    expect(cause).to respond_to(:phone)
    expect(cause).to respond_to(:fax)
    expect(cause).to respond_to(:tax_id)
    expect(cause).to respond_to(:address_1)
    expect(cause).to respond_to(:address_2)
    expect(cause).to respond_to(:address_3)
    expect(cause).to respond_to(:city)
    expect(cause).to respond_to(:region)
    expect(cause).to respond_to(:country)
    expect(cause).to respond_to(:postal_code)
    expect(cause).to respond_to(:mailing_address)
    expect(cause).to respond_to(:mailing_city)
    expect(cause).to respond_to(:mailing_state)
    expect(cause).to respond_to(:mailing_postal_code)
    expect(cause).to respond_to(:site_url)
    expect(cause).to respond_to(:logo_url)
    expect(cause).to respond_to(:latitude)
    expect(cause).to respond_to(:longitude)
    expect(cause).to respond_to(:mission)
  end
  
  it { should be_valid }

  describe "Missing name" do
    before { cause.name = ' ' }
    
    it { should_not be_valid }
  end

  describe "Missing cause type" do
    before { cause.cause_type = ' ' }
    
    it { should_not be_valid }
  end

  describe "Missing country" do
    before { cause.country = ' ' }
    
    it { should_not be_valid }
  end
  
  it "should default to no ach" do
    expect(cause.has_ach_info).to be false
  end

  describe "valid types" do
    Cause::VALID_TYPES.each do |t|
      before { cause.cause_type = t }
      
      it { should be_valid }
    end
  end
  
  describe "Invalid types" do 
    [-2, 0.5, 'abc', nil].each do |t|
      before { cause.cause_type = t }
      
      it { should_not be_valid }
    end
  end

  describe "Country too long" do
    before { cause.country = 'c'*(Cause::MAX_COUNTRY_LEN + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing email" do
    before { cause.email = ' ' }
    
    it { should be_valid }
  end
  
  describe "Valid emails" do
    ApplicationHelper::VALID_EMAILS.each do |email|
      before { cause.email = email }
      
      it { should be_valid }
    end
  end

  describe "Invalid emails" do
    ApplicationHelper::INVALID_EMAILS.each do |email|
      before { cause.email = email }
      
      it { should_not be_valid }
    end
  end
  
  describe "Missing postal code" do
    before { cause.postal_code = nil }
    
    it { should be_valid }
  end
  
  describe "Postal code too long" do
    before { cause.postal_code = 'c'*(Cause::MAX_SMALL + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing mailing postal code" do
    before { cause.mailing_postal_code = nil }
    
    it { should be_valid }
  end
  
  describe "Mailing postal code too long" do
    before { cause.mailing_postal_code = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing phone" do
    before { cause.phone = nil }
    
    it { should be_valid }
  end
  
  describe "Phone too long" do
    before { cause.phone = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing fax" do
    before { cause.fax = nil }
    
    it { should be_valid }
  end
  
  describe "Fax too long" do
    before { cause.fax = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing tax id" do
    before { cause.tax_id = nil }
    
    it { should be_valid }
  end
  
  describe "Tax id too long" do
    before { cause.tax_id = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing City" do
    before { cause.city = nil }
    
    it { should be_valid }
  end
  
  describe "City too long" do
    before { cause.city = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing Region" do
    before { cause.region = nil }
    
    it { should be_valid }
  end
  
  describe "Region too long" do
    before { cause.region = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing Mailing city" do
    before { cause.mailing_city = nil }
    
    it { should be_valid }
  end
  
  describe "Mailing city too long" do
    before { cause.mailing_city = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing Mailing state" do
    before { cause.mailing_state = nil }
    
    it { should be_valid }
  end
  
  describe "Mailing state too long" do
    before { cause.mailing_state = 'c'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing address1" do
    before { cause.address_1 = nil }
    
    it { should be_valid }
  end
  
  describe "Address1 too long" do
    before { cause.address_1 = 'c'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing address2" do
    before { cause.address_2 = nil }
    
    it { should be_valid }
  end
  
  describe "Address2 too long" do
    before { cause.address_2 = 'c'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing address3" do
    before { cause.address_3 = nil }
    
    it { should be_valid }
  end
  
  describe "Address3 too long" do
    before { cause.address_3 = 'c'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing mailing address" do
    before { cause.mailing_address = nil }
    
    it { should be_valid }
  end
  
  describe "Mailing address too long" do
    before { cause.mailing_address = 'c'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end
end
