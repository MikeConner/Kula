FactoryGirl.define do
  sequence(:random_email) { |n| Faker::Internet.email }
  sequence(:random_phrase) { |n| Faker::Company.catch_phrase }
  sequence(:random_name) { |n| Faker::Name.name }
  sequence(:random_domain) { |n| Faker::Internet.domain_name }
  sequence(:random_phone) { |n| Faker::PhoneNumber.phone_number }
  sequence(:random_tax_id) { |n| Faker::Company.ein }
  sequence(:random_company) { |n| Faker::Company.name }
  sequence(:random_street_address) { |n| Faker::Address.street_address }
  sequence(:random_secondary_address) { |n| Faker::Address.secondary_address }
  sequence(:random_city) { |n| Faker::Address.city }
  sequence(:random_region) { |n| Faker::Address.state }
  sequence(:random_country_code) { |n| Faker::Address.country_code }
  sequence(:random_postal_code) { |n| Faker::Address.postcode }
  sequence(:random_url) { |n| "http://www." + Faker::Internet.domain_name }
  sequence(:random_sentences) { |n| Faker::Lorem.sentences.join(' ') }
  sequence(:random_latitude) { |n| Faker::Address.latitude }
  sequence(:random_longitude) { |n| Faker::Address.longitude }

  factory :replicated_tx_balance do
    partnerid { FactoryGirl.create(:partner).partner_identifier }
    month 6
    year 2014
    grossamount 100
    discountamount 0
    netamount 100
    kulafees 5
    doneeamount 95
    causeid { FactoryGirl.create(:cause).cause_identifier }
    causename { generate(:random_company) }
    country 'US'
    causetype Cause::CAUSE_TYPE
    created 6.months.ago
  end
  
  factory :cause_transaction do
    partner_identifier { FactoryGirl.create(:partner).partner_identifier }
    cause_identifier { FactoryGirl.create(:cause).cause_id }
    month { Random.rand(12) + 1 }
    year { Random.rand(10) + 2001 }
    gross_amount { Random.rand * 500 }
    donee_amount { Random.rand * 500 }
    calc_kula_fee { Random.rand * 10 }
    calc_foundation_fee { Random.rand * 10 }
    calc_distributor_fee { Random.rand * 10 }
    calc_credit_card_fee { Random.rand * 10 }
  end
 
  factory :global_setting do
    current_period Date.parse('2014-11-01')
  end
  
  factory :distributor do
    distributor_identifier { Random.rand(100000) + 1 }
    name { generate(:random_name) }
    display_name { generate(:random_name) }
  end
  
  factory :kula_fee do
    us_school_rate { Random.rand * 100 + 0.01 }
    us_charity_rate { Random.rand * 100 + 0.01 }
    intl_charity_rate { Random.rand * 100 + 0.01 }
    us_school_kf_rate { Random.rand * 10 + 0.01 }
    us_charity_kf_rate { Random.rand * 10 + 0.01 }
    intl_charity_kf_rate { Random.rand * 10 + 0.01 }
    
    effective_date { 1.week.ago }
    expiration_date { 1.year.from_now }
    
    factory :universal_rate_fee do
      effective_date nil
      expiration_date nil
    end
    
    factory :unbounded_left_fee do
      effective_date nil
    end
    
    factory :unbounded_right_fee do
      expiration_date nil
    end
    
    factory :distributor_fee do
      distributor
      
      distributor_rate { Random.rand * 50 + 0.01 }
    end
  end
  
  factory :partner do
    partner_identifier { Random.rand(10000) }
    name { generate(:random_name) }
    display_name { generate(:random_name) }
    domain { generate(:random_domain) }
    
    factory :partner_with_universal_fee do
      after(:create) do |partner|
        FactoryGirl.create(:universal_rate_fee, :partner => partner)
      end
    end

    factory :partner_with_unbounded_left_fee do
      after(:create) do |partner|
        FactoryGirl.create(:unbounded_left_fee, :partner => partner)
      end
    end

    factory :partner_with_unbounded_right_fee do
      after(:create) do |partner|
        FactoryGirl.create(:unbounded_right_fee, :partner => partner)
      end
    end
    
    factory :partner_with_bounded_fee do
      after(:create) do |partner|
        FactoryGirl.create(:kula_fee, :partner => partner)
      end
    end

    factory :partner_with_fees do
      after(:create) do |partner|
        FactoryGirl.create(:unbounded_left_fee, :partner => partner, :expiration_date => Date.today)
        FactoryGirl.create(:unbounded_right_fee, :partner => partner, :effective_date => Date.tomorrow)
      end
    end
  end
  
  factory :cause do    
    cause_identifier { Random.rand(100000) }
    cause_id { Random.rand(100000).to_s }    
    org_name { generate(:random_name) }
    cause_type { Cause::VALID_TYPES.sample }
    org_email { generate(:random_email) }
    org_phone { generate(:random_phone) }
    org_fax { generate(:random_phone) }
    tax_id { generate(:random_tax_id) }
    address1 { generate(:random_street_address) }
    address2 { generate(:random_secondary_address) }
    address3 { generate(:random_secondary_address) }
    city { generate(:random_city) }
    region { generate(:random_region) }
    country { generate(:random_country_code) }
    postal_code { generate(:random_postal_code) }
    mailing_address { generate(:random_street_address) }
    mailing_city { generate(:random_city) }
    mailing_state { generate(:random_region) }
    mailing_postal_code { generate(:random_postal_code) }
    site_url { generate(:random_url) }
    logo_url { generate(:random_url) }
    latitude { generate(:random_latitude) }
    longitude { generate(:random_longitude) }
    mission { generate(:random_sentences) }
    language { ['en', 'fr', 'de'].sample }
    has_ach_info { [0, 1].sample }
    source_id { Random.rand(100) }
    created { Date.today - 6.months }
    
    factory :populated_cause do
      transient do
        num_transactions 3
        num_payments 3
        num_adjustments 2
        num_balances 2
      end  
    
      after(:create) do |cause, evaluator|
        FactoryGirl.create_list(:cause_transaction, evaluator.num_transactions, :cause_identifier => cause.cause_identifier)
        FactoryGirl.create_list(:payment, evaluator.num_payments, :cause => cause)
        FactoryGirl.create_list(:adjustment, evaluator.num_adjustments, :cause => cause)
        FactoryGirl.create_list(:cause_balance, evaluator.num_balances, :cause => cause)
      end
    end
  end

  factory :user do
    email { generate(:random_email) }
    password { generate(:random_phrase) }   

    factory :cause_user do
      cause
      
      role User::CAUSE
    end 
    
    factory :partner_user do
      partner
      
      role User::PARTNER
    end 
  end
  
  factory :stripe_account do
    cause
    
    token { "tok_" + SecureRandom.hex(12) }
  end
  
  factory :cause_balance do
    partner
    cause
    
    year { 2001 + Random.rand(15) }
    balance_type { CauseBalance::BALANCE_TYPES.sample }
  end
  
  factory :batch do
    partner
    user
    
    name { SecureRandom.hex(5) }
    date { Date.today }
    description { generate(:random_phrase) }
    
    factory :batch_with_payments do
      transient do
        num_payments 10
      end
    
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:payment, evaluator.num_payments, :batch => batch)
      end
    end
    
    factory :batch_with_adjustments do
      transient do
        num_adjustments 2
      end
    
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:adjustment, evaluator.num_adjustments, :batch => batch)
      end
    end
    
    factory :batch_with_adjusted_payments do
      transient do
        num_payments 10
        num_adjustments 2
      end
      
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:payment, evaluator.num_payments, :batch => batch)
        FactoryGirl.create_list(:adjustment, evaluator.num_adjustments, :batch => batch)
      end
    end
  end
  
  factory :payment do
    batch
    cause 
    
    status { Payment::VALID_CHECK_STATUSES.sample }
    payment_method Payment::CHECK
    amount { Random.rand * 1000 + 1 }
    date { Date.today }
    confirmation { SecureRandom.hex(10) }
    address { generate(:random_street_address) }
    comment { generate(:random_sentences) }
    check_num { Random.rand(1000) + 1 }
    month { Random.rand(12) + 1 }
    year { Random.rand(10) + 2001 }
    
    factory :ach_payment do
      payment_method Payment::ACH
      status { Payment::VALID_ACH_STATUSES.sample }      
    end
  end
  
  factory :adjustment do
    batch
    
    amount { Random.rand * 1000 + 1 }
    date { Date.today }
    comment { generate(:random_sentences) }
    month { Random.rand(12) + 1 }
    year { Random.rand(10) + 2001 }    
  end
end
