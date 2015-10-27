class UserMailer < ApplicationMailer  
  def test_email
    @name = 'Jeff'
    
    mail(:to => 'endymionjkb@gmail.com', :subject => 'Test')
  end
end
