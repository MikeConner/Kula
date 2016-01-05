# == Schema Information
#
# Table name: causes
#
#  cause_id                     :string(64)       not null, primary key
#  source_id                    :integer          not null
#  source_cause_id              :string(64)
#  mcr_school_id                :integer
#  enhanced_date                :datetime
#  unenhanced_cause_id          :string(64)
#  tax_id                       :string(64)
#  cause_type                   :integer          default(1), not null
#  has_ach_info                 :integer          default(0), not null
#  k8                           :integer          default(0), not null
#  org_name                     :string(255)      not null
#  old_org_name                 :string(255)
#  org_contact_first_name       :string(64)
#  old_org_contact_first_name   :string(64)
#  org_contact_last_name        :string(64)
#  old_org_contact_last_name    :string(64)
#  org_contact_email            :string(255)
#  old_org_contact_email        :string(255)
#  mcr_role                     :string(50)
#  mcr_user_level               :string(25)
#  org_email                    :string(255)
#  org_phone                    :string(64)
#  old_org_phone                :string(64)
#  org_fax                      :string(64)
#  mission                      :text
#  additional_description       :text
#  description                  :text
#  address1                     :string(128)
#  old_address1                 :string(128)
#  address2                     :string(128)
#  address3                     :string(128)
#  latitude                     :float
#  longitude                    :float
#  city                         :string(64)
#  old_city                     :string(64)
#  region                       :string(64)
#  old_region                   :string(64)
#  country                      :string(2)        not null
#  postal_code                  :string(16)
#  old_postal_code              :string(16)
#  mailing_address              :string(128)
#  mailing_city                 :string(64)
#  mailing_state                :string(64)
#  mailing_postal_code          :string(16)
#  site_url                     :string(255)
#  old_site_url                 :string(255)
#  logo_url                     :string(255)
#  logo_small_url               :string(255)
#  image_url                    :string(255)
#  video_url                    :string(255)
#  facebook_url                 :string(255)
#  newsletter_url               :string(255)
#  photos_url                   :string(255)
#  twitter_username             :string(16)
#  school_grades_desc           :string(255)
#  school_student_range_cd_desc :string(255)
#  ethnic_african_american_pct  :integer
#  ethnic_asian_american_pct    :integer
#  ethnic_hispanic_american_pct :integer
#  ethnic_native_american_pct   :integer
#  ethnic_caucasian_pct         :integer
#  keywords                     :text
#  countries_operation          :text
#  language                     :string(8)        not null
#  donation_5                   :string(128)
#  donation_10                  :string(128)
#  donation_25                  :string(128)
#  donation_50                  :string(128)
#  donation_100                 :string(128)
#  is_prison_school             :integer          default(0)
#  views                        :integer          default(0), not null
#  donations                    :integer          default(0), not null
#  comment_count                :integer          default(0), not null
#  favorite_count               :integer          default(0), not null
#  share_count                  :integer          default(0), not null
#  mcr_net_points               :integer
#  status                       :integer
#  donatable_status             :integer          default(1)
#  mcr_status                   :integer
#  payment_first_name           :string(64)
#  payment_last_name            :string(64)
#  payment_email                :string(255)
#  payment_currency             :string(3)
#  payment_address1             :string(128)
#  old_payment_address1         :string(128)
#  payment_address2             :string(128)
#  old_payment_address2         :string(128)
#  bank_routing_number          :string(16)
#  bank_account_number          :string(32)
#  iban                         :string(34)
#  paypal_email                 :string(255)
#  cached                       :integer          default(0)
#  updated                      :datetime
#  old_updated                  :datetime
#  created                      :datetime         not null
#  latitude_longitude_point     :point
#  cause_identifier             :integer          not null
#

require 'rails_helper'

describe Cause do
  let(:cause) { FactoryGirl.create(:cause) }
  #let(:populated_cause) { FactoryGirl.create(:populated_cause) }
  
  subject { cause }
  
  it "should respond to everything" do
    expect(cause).to respond_to(:cause_id)
    expect(cause).to respond_to(:source_id)
    expect(cause).to respond_to(:source_cause_id)
    expect(cause).to respond_to(:mcr_school_id)
    expect(cause).to respond_to(:enhanced_date)
    expect(cause).to respond_to(:unenhanced_cause_id)
    expect(cause).to respond_to(:tax_id)
    expect(cause).to respond_to(:cause_type)
    expect(cause).to respond_to(:has_eft_bank_info)
    expect(cause).to respond_to(:k8)
    expect(cause).to respond_to(:org_name)
    expect(cause).to respond_to(:old_org_name)
    expect(cause).to respond_to(:org_contact_first_name)
    expect(cause).to respond_to(:old_org_contact_first_name)
    expect(cause).to respond_to(:org_contact_last_name)
    expect(cause).to respond_to(:old_org_contact_last_name)
    expect(cause).to respond_to(:org_contact_email)
    expect(cause).to respond_to(:old_org_contact_email)
    expect(cause).to respond_to(:mcr_role)
    expect(cause).to respond_to(:mcr_user_level)
    expect(cause).to respond_to(:org_email)
    expect(cause).to respond_to(:org_phone)
    expect(cause).to respond_to(:old_org_phone)
    expect(cause).to respond_to(:org_fax)
    expect(cause).to respond_to(:mission)
    expect(cause).to respond_to(:additional_description)
    expect(cause).to respond_to(:description)
    expect(cause).to respond_to(:address1)
    expect(cause).to respond_to(:old_address1)
    expect(cause).to respond_to(:address2)
    expect(cause).to respond_to(:address3)
    expect(cause).to respond_to(:latitude)
    expect(cause).to respond_to(:longitude)
    expect(cause).to respond_to(:city)
    expect(cause).to respond_to(:old_city)
    expect(cause).to respond_to(:region)
    expect(cause).to respond_to(:old_region)
    expect(cause).to respond_to(:country)
    expect(cause).to respond_to(:postal_code)
    expect(cause).to respond_to(:old_postal_code)
    expect(cause).to respond_to(:mailing_address)
    expect(cause).to respond_to(:mailing_city)
    expect(cause).to respond_to(:mailing_state)
    expect(cause).to respond_to(:mailing_postal_code)
    expect(cause).to respond_to(:site_url)
    expect(cause).to respond_to(:old_site_url)
    expect(cause).to respond_to(:logo_url)
    expect(cause).to respond_to(:logo_small_url)
    expect(cause).to respond_to(:image_url)
    expect(cause).to respond_to(:video_url)
    expect(cause).to respond_to(:facebook_url)
    expect(cause).to respond_to(:newsletter_url)
    expect(cause).to respond_to(:photos_url)
    expect(cause).to respond_to(:twitter_username)
    expect(cause).to respond_to(:school_grades_desc)
    expect(cause).to respond_to(:school_student_range_cd_desc)
    expect(cause).to respond_to(:ethnic_african_american_pct)
    expect(cause).to respond_to(:ethnic_asian_american_pct)
    expect(cause).to respond_to(:ethnic_hispanic_american_pct)
    expect(cause).to respond_to(:ethnic_native_american_pct)
    expect(cause).to respond_to(:ethnic_caucasian_pct)
    expect(cause).to respond_to(:keywords)
    expect(cause).to respond_to(:countries_operation)
    expect(cause).to respond_to(:language)
    expect(cause).to respond_to(:donation_5)
    expect(cause).to respond_to(:donation_10)
    expect(cause).to respond_to(:donation_25)
    expect(cause).to respond_to(:donation_50)
    expect(cause).to respond_to(:donation_100)
    expect(cause).to respond_to(:is_prison_school)
    expect(cause).to respond_to(:views)
    expect(cause).to respond_to(:donations)
    expect(cause).to respond_to(:comment_count)
    expect(cause).to respond_to(:favorite_count)
    expect(cause).to respond_to(:share_count)
    expect(cause).to respond_to(:mcr_net_points)
    expect(cause).to respond_to(:status)
    expect(cause).to respond_to(:donatable_status)
    expect(cause).to respond_to(:mcr_status)
    expect(cause).to respond_to(:payment_first_name)
    expect(cause).to respond_to(:payment_last_name)
    expect(cause).to respond_to(:payment_email)
    expect(cause).to respond_to(:payment_currency)
    expect(cause).to respond_to(:payment_address1)
    expect(cause).to respond_to(:old_payment_address1)
    expect(cause).to respond_to(:payment_address2)
    expect(cause).to respond_to(:old_payment_address2)
    expect(cause).to respond_to(:bank_routing_number)
    expect(cause).to respond_to(:bank_account_number)
    expect(cause).to respond_to(:iban)
    expect(cause).to respond_to(:paypal_email)
    expect(cause).to respond_to(:cached)
    expect(cause).to respond_to(:updated)
    expect(cause).to respond_to(:old_updated)
    expect(cause).to respond_to(:created)
    expect(cause).to respond_to(:latitude_longitude_point)
    expect(cause).to respond_to(:cause_identifier)    
    expect(cause).to respond_to(:school?)    
    expect(cause).to respond_to(:international?)    
  end
  
  it { should be_valid }
  
  describe "Missing source_id" do
    before { cause.source_id = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing cause_type" do
    before { cause.cause_type = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing has_eft_bank_info" do
    before { cause.has_eft_bank_info = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing org_name" do
    before { cause.org_name = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing country" do
    before { cause.country = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing language" do
    before { cause.language = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing views" do
    before { cause.views = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing donations" do
    before { cause.donations = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing comment_count" do
    before { cause.comment_count = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing favorite_count" do
    before { cause.favorite_count = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing share_count" do
    before { cause.share_count = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing created" do
    before { cause.created = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Missing cause_identifier" do
    before { cause.cause_identifier = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid ach info" do
    before { cause.has_eft_bank_info = 6 }
    
    it { should_not be_valid }
  end

  describe "Invalid type" do
    before { cause.cause_type = 'abc' }
    
    it { should_not be_valid }
  end

  describe "Country too long" do
    before { cause.country = 'c'*(Cause::MAX_COUNTRY_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "Postal code too long" do
    before { cause.postal_code = 'p'*(Cause::MAX_SMALL + 1) }
    
    it { should_not be_valid }
  end  

  describe "Mailing postal code too long" do
    before { cause.mailing_postal_code = 'p'*(Cause::MAX_SMALL + 1) }
    
    it { should_not be_valid }
  end  

  describe "Phone too long" do
    before { cause.org_phone = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "Fax too long" do
    before { cause.org_fax = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "Tax id too long" do
    before { cause.tax_id = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "City too long" do
    before { cause.city = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "Region too long" do
    before { cause.region = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "Mailing city too long" do
    before { cause.mailing_city = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "Mailing state too long" do
    before { cause.mailing_state = 'p'*(Cause::MAX_MEDIUM + 1) }
    
    it { should_not be_valid }
  end  

  describe "Address1 too long" do
    before { cause.address1 = 'p'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end  

  describe "Address2 too long" do
    before { cause.address2 = 'p'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end  

  describe "Address3 too long" do
    before { cause.address3 = 'p'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end  

  describe "mailing address too long" do
    before { cause.mailing_address = 'p'*(Cause::MAX_LARGE + 1) }
    
    it { should_not be_valid }
  end  
end
