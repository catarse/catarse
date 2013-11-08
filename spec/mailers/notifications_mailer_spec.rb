require 'spec_helper'

describe NotificationsMailer do
  let(:notification){ create(:notification, template_name: 'template', user: create(:user), origin_name: 'Catarse', origin_email: 'contact@foo.bar') }
  subject{ NotificationsMailer.notify(notification) }

  before do
    notification
    Mail::Message.any_instance.stub(:deliver)
    NotificationsMailer.any_instance.should_receive(:mail).with({
      from: "Catarse <contact@foo.bar>",
      to: notification.user.email,
      subject: '',
      template_name: 'template'
    })
  end

  it("should satisfy expectations"){ subject }
end
