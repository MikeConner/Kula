# == Schema Information
#
# Table name: replicated_causes
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
#

require 'rails_helper'

RSpec.describe ReplicatedCause, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
