FactoryGirl.define do
  sequence(:random_email) { |n| Faker::Internet.email }
  sequence(:random_phrase) { |n| Faker::Company.catch_phrase }
  sequence(:random_name) { |n| Faker::Name.name }
  sequence(:random_domain) { |n| Faker::Internet.domain_name }
  sequence(:random_phone) { |n| Faker::PhoneNumber.phone_number }
  sequence(:random_tax_id) { |n| Faker::Company.ein }
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

  factory :distributor do
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
      distributor_kf_rate { Random.rand * 23 + 0.03 }
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
    cause_identifier { generate(:random_phrase) }
    name { generate(:random_name) }
    cause_type { [1,2].sample }
    email { generate(:random_email) }
    phone { generate(:random_phone) }
    fax { generate(:random_phone) }
    tax_id { generate(:random_tax_id) }
    address_1 { generate(:random_street_address) }
    address_2 { generate(:random_secondary_address) }
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
    
    status { Payment::VALID_STATUSES.sample }
    payment_method { Payment::VALID_METHODS.sample }
    amount { Random.rand * 1000 + 1 }
    date { Date.today }
    confirmation { SecureRandom.hex(10) }
    address { generate(:random_street_address) }
    comment { generate(:random_sentences) }
  end
  
  factory :adjustment do
    batch
    
    amount { Random.rand * 1000 + 1 }
    date { Date.today }
    comment { generate(:random_sentences) }
  end
end
