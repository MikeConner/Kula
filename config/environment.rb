# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'kulacauses.com',
  user_name:            'kulaops@gmail.com',
  password:             '5b1c19bce73fdc94ff96',
  authentication:       'plain',
  enable_starttls_auto: true  
}
