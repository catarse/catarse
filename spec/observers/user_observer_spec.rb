require 'spec_helper'

describe UserObserver do

  describe "after_create" do
    before do
      UserObserver.any_instance.should_receive(:after_create).and_call_original
    end

    let(:user) { build(:user) }

    it "send new user registration notification" do
      user.should_receive(:notify).with(:new_user_registration)
      user.save
    end
  end

  context 'before_save' do
    subject { create(:user, twitter: '@should_be_change') }

    its(:twitter) { should == 'should_be_change' }
  end
end
