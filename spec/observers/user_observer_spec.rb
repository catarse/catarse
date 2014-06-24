require 'spec_helper'

describe UserObserver do

  describe "after_create" do
    before do
      UserObserver.any_instance.should_receive(:after_create).and_call_original
      Notification.unstub(:notify_once)
    end

    let(:user) { create(:user) }

    it "send new user registration notification" do
      Notification.should_receive(:notify).with(:new_user_registration, user)
    end
  end

  context 'before_save' do
    subject { create(:user, twitter: '@should_be_change') }

    its(:twitter) { should == 'should_be_change' }
  end
end
