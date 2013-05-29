require 'spec_helper'

describe NotificationsMailer do
  let(:notification){ create(:notification, notification_type: create(:notification_type, name: 'confirm_backer'), mail_params: {project_name: create(:project).name}, user: create(:user)) }
  subject{ NotificationsMailer.notify(notification) }

  before do
    notification
    ::Configuration['email_contact'] = 'contact@foo.bar'
    ::Configuration['company_name'] = 'Catarse'
    Mail::Message.any_instance.stub(:deliver)
    NotificationsMailer.any_instance.should_receive(:mail).with({
      from: "#{::Configuration[:company_name]} <#{::Configuration[:email_contact]}>",
      to: notification.user.email,
      subject: I18n.t('notifications.confirm_backer.subject', project_name: notification.project.name)
    })
  end

  it("should satisfy expectations"){ subject }
end
