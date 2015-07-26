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
#  latitude            :decimal(10, )
#  longitude           :decimal(10, )
#  mission             :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#

class Cause < ActiveRecord::Base
  include ApplicationHelper
  
  self.primary_key = 'cause_identifier'
  
  CAUSE_TYPE = 1
  SCHOOL_TYPE = 2
  VALID_TYPES = [CAUSE_TYPE, SCHOOL_TYPE]
  
  MAX_COUNTRY_LEN = 2 
  MAX_SMALL = 16
  MAX_MEDIUM = 64
  MAX_LARGE = 128
  
  has_many :cause_balances, :dependent => :restrict_with_exception

  validates_presence_of :name, :cause_type, :country
  validates_inclusion_of :has_ach_info, :in => [true, false]
  validates_inclusion_of :cause_type, :in => VALID_TYPES
  validates :country, :length => { :maximum => MAX_COUNTRY_LEN }
  # NOTE: Apparently emails are not unique!
  validates :email, :format => { :with => EMAIL_REGEX },
                    :allow_blank => true
  validates :postal_code, :mailing_postal_code, :length => { :maximum => MAX_SMALL }, :allow_nil => true
  validates :phone, :fax, :tax_id, :city, :region, :mailing_city, :mailing_state, :length => { :maximum => MAX_MEDIUM }, :allow_nil => true
  validates :address_1, :address_2, :address_3, :mailing_address, :length => { :maximum => MAX_LARGE }, :allow_nil => true
end
