# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if User.where("role = ?", User::ADMIN).empty?
  #Partner.create!(:partner_identifier => '1', :name => 'Red Robin', :display_name => 'Red Robin', :domain => 'redrobin.com')
  #Cause.create!(:cause_identifier => '2001', :name => 'Sewickley Academy', :cause_type => Cause::CAUSE_TYPE, :country => 'US', )
  User.create!(:email => 'jeff@tapdatapp.co', :password => 'MonkeY1984', :password_confirmation => 'MonkeY1984', :role => User::ADMIN)
  User.create!(:email => 'arash@tapdatapp.co', :password => 'MonkeY1984', :password_confirmation => 'MonkeY1984', :role => User::ADMIN)
  User.create!(:email => 'john@kula.com', :password => 'KulaKulaKula', :password_confirmation => 'KulaKulaKula', :role => User::KULA_ADMIN)
  User.create!(:email => 'head@sewickley-academy.com', :cause_id => Cause.first.id, :password => 'MoMoney1984', :password_confirmation => 'MoMoney1984', :role => User::CAUSE)
  User.create!(:email => 'bird@redrobin.com', :partner_id => Partner.first.id, :password => 'BeakBeakBeak', :password_confirmation => 'BeakBeakBeak', :role => User::PARTNER)
  User.create!(:email => 'joe@user.com', :password => 'MonkeY1984', :password_confirmation => 'MonkeY1984')
end

Partner.destroy_all
Distributor.destroy_all

milepoint = Partner.create!(:partner_identifier => 10, :name => 'Milepoint, LLC (Reseller Agreement)', :display_name => 'Milepoint', :domain => 'milepoint.com')
jetBlue = Partner.create!(:partner_identifier => 11, :name => 'JetBlue Airways (Services Agreement)', :display_name => 'JetBlue', :domain => 'jetblue.com')
kula = Partner.create!(:partner_identifier => 12, :name => 'Kula', :display_name => 'Kula', :domain => 'kula.com')
kellogg = Partner.create!(:partner_identifier => 14, :name => 'Kellogg Company (Prog Ptnr Agreement)', :display_name => 'Kellogg', :domain => 'kellogg.com')
redRobin = Partner.create!(:partner_identifier => 22, :name => 'Red Robin', :display_name => 'Red Robin', :domain => 'redrobin.com')
coke = Partner.create!(:partner_identifier => 24, :name => 'My Coke Rewards', :display_name => 'Coke Rewards', :domain => 'mcr.com')

connexions = Distributor.create!(:distributor_identifier => 16, :name => 'Connexions', :display_name => 'Connexions')
g2g = Distributor.create!(:distributor_identifier => 17, :name => 'G2G', :display_name => 'G2G')
globogym = Distributor.create!(:distributor_identifier => 20, :name => 'Globoforce', :display_name => 'Globoforce')
regis = Distributor.create!(:distributor_identifier => 23, :name => 'Regis University', :display_name => 'Regis')
tanzer = Distributor.create!(:distributor_identifier => 25, :name => 'Stephen Tanzer (Various)', :display_name => 'Tanzer')

# Fees
jetBlue.kula_fees.create!(:us_charity_rate => 0.1, :us_charity_kf_rate => 0.0225, :intl_charity_rate => 0.125, :intl_charity_kf_rate => 0.06)
kellogg.kula_fees.create!(:us_charity_rate => 0.09, :us_charity_kf_rate => 0.01, :us_school_rate => 0.1, :us_school_kf_rate => 0.0225, :intl_charity_rate => 0.09, :intl_charity_kf_rate => 0.01)
milepoint.kula_fees.create!(:us_charity_rate => 0.1, :us_charity_kf_rate => 0.0225, :intl_charity_rate => 0.125, :intl_charity_kf_rate => 0.06)
redRobin.kula_fees.create!(:us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025)
kula.kula_fees.create(:us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025, :intl_charity_rate => 0.125, :intl_charity_kf_rate => 0.06)
kula.kula_fees.create(:distributor_identifier => 16, :distributor_rate => 0.125, :expiration_date => Date.parse('2015-04-30'), :us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025, :intl_charity_rate => 0.1, :intl_charity_kf_rate => 0.025)
kula.kula_fees.create(:distributor_identifier => 16, :distributor_rate => 0.035, :effective_date => Date.parse('2015-05-01'), :us_charity_rate => 0.06, :us_charity_kf_rate => 0.03, :us_school_rate => 0.06, :us_school_kf_rate => 0.03, :intl_charity_rate => 0.06, :intl_charity_kf_rate => 0.03)
kula.kula_fees.create(:distributor_identifier => 17, :distributor_rate => 0, :us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025, :intl_charity_rate => 0.1, :intl_charity_kf_rate => 0.025)
kula.kula_fees.create(:distributor_identifier => 20, :distributor_rate => 0.1, :us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025, :intl_charity_rate => 0.1, :intl_charity_kf_rate => 0.025)
kula.kula_fees.create(:distributor_identifier => 23, :distributor_rate => 0, :us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025, :intl_charity_rate => 0.1, :intl_charity_kf_rate => 0.025)
kula.kula_fees.create(:distributor_identifier => 25, :distributor_rate => 0, :us_charity_rate => 0.1, :us_charity_kf_rate => 0.025, :us_school_rate => 0.1, :us_school_kf_rate => 0.025, :intl_charity_rate => 0.1, :intl_charity_kf_rate => 0.025)
