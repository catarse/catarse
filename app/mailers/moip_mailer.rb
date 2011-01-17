class MoipMailer < ActionMailer::Base
  default :from => "Catarse <system@catarse.me>"

  def payment_received_email(backer, parameters)
    @backer = backer.to_yaml
    @parameters = parameters.to_yaml
    mail(:to => 'diogob@gmail.com', :subject => "Received payment from moip")
  end
  def error_in_payment_email(backer, parameters, exception)
    @backer = backer.to_yaml
    @parameters = parameters.to_yaml
    @ex = exception
    mail(:to => 'diogob@gmail.com', :subject => "Received payment from moip")
  end
end
