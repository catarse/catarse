class CreditsMailer < ActionMailer::Base
  include ERB::Util
  default :from => "Catarse <system@catarse.me>"

  def request_refund_from(backer)
    @backer = backer
    @user = backer.user
    mail(:to => 'financeiro@catarse.me', :subject => t('credits_mailer.request_refund_from.subject', :name => @user.name))
  end
end
