# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if User.where("role = ?", User::ADMIN).empty?
  Partner.create!(:partner_identifier => '1', :name => 'Red Robin', :display_name => 'Red Robin', :domain => 'redrobin.com')
  Cause.create!(:cause_identifier => '2001', :name => 'Sewickley Academy', :cause_type => Cause::CAUSE_TYPE, :country => 'US', )
  User.create!(:email => 'jeff@tapdatapp.co', :password => 'MonkeY1984', :password_confirmation => 'MonkeY1984', :role => User::ADMIN)
  User.create!(:email => 'arash@tapdatapp.co', :password => 'MonkeY1984', :password_confirmation => 'MonkeY1984', :role => User::ADMIN)
  User.create!(:email => 'john@kula.com', :password => 'KulaKulaKula', :password_confirmation => 'KulaKulaKula', :role => User::KULA_ADMIN)
  User.create!(:email => 'head@sewickley-academy.com', :cause_id => Cause.first.id, :password => 'MoMoney1984', :password_confirmation => 'MoMoney1984', :role => User::CAUSE)
  User.create!(:email => 'bird@redrobin.com', :partner_id => Partner.first.id, :password => 'BeakBeakBeak', :password_confirmation => 'BeakBeakBeak', :role => User::PARTNER)
  User.create!(:email => 'joe@user.com', :password => 'MonkeY1984', :password_confirmation => 'MonkeY1984')
end
