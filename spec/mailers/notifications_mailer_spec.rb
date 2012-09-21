require 'spec_helper'

describe NotificationsMailer do
  let(:notification){ Factory(:notification) }
  subject{ NotificationsMailer.notify(notification) }
  its(:from){ should == [I18n.t('site.email.contact')] }
  its(:to){ should == [notification.user.email] }
  its(:subject){ should == notification.email_subject }
end
