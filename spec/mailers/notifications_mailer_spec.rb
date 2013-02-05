require 'spec_helper'

describe NotificationsMailer do
  let(:notification){ Factory(:notification, :notification_type => Factory(:notification_type, :name => 'confirm_backer'), :mail_params => {:project_name => Factory(:project).name}, :user => Factory(:user)) }
  subject{ NotificationsMailer.notify(notification) }

  before do
    ::Configuration['email_contact'] = 'contact@foo.bar'
    ::Configuration['company_name'] = 'Catarse'
    Mail::Message.any_instance.stubs(:deliver)
    NotificationsMailer.any_instance.expects(:mail).at_least_once.with({
      :from => "#{Configuration[:company_name]} <#{Configuration[:email_contact]}>",
      :to => notification.user.email,
      :subject => I18n.t('notifications.confirm_backer.subject', :project_name => notification.project.name),
      :template_name => 'confirm_backer'
    })
  end

  it("should satisfy expectations"){ subject }
end
