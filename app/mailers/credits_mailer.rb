class CreditsMailer < ActionMailer::Base
  include ERB::Util

  def request_refund_from(backer)
    @backer = backer
    @user = backer.user
    mail(from: "#{@user.name} <#{@user.email}>", to: ::Configuration[:email_payments], subject: I18n.t('credits_mailer.request_refund_from.subject', name: @backer.project.name))
  end
end
