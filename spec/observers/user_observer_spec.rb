require 'rails_helper'

RSpec.describe UserObserver do

  describe "after_create" do
    before do
      expect_any_instance_of(UserObserver).to receive(:after_create).and_call_original
    end

    let(:user) { build(:user) }

    it "send new user registration notification" do
      expect(user).to receive(:notify).with(:new_user_registration)
      user.save
    end
  end

  context 'before_save' do
    subject { create(:user, twitter: '@should_be_change') }

    its(:twitter) { should == 'should_be_change' }
  end
end
