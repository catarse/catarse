begin
  ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => 'catarse',
  :password       =>  Configuration.find_by_name('sendgrid').value,
  :domain         => 'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp
rescue
  nil
end
