class CreditsMailer < ActionMailer::Base
  include ERB::Util

  def request_refund_from(backer)
    @backer = backer
    @user = backer.user
    mail(:from => "#{I18n.t('site.name')} <#{I18n.t('site.email.system')}>", :to => I18n.t('site.email.payments'), :subject => I18n.t('credits_mailer.request_refund_from.subject', :name => @user.name))
  end
end
