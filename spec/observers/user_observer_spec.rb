require 'rails_helper'

RSpec.describe UserObserver do
  describe "after_create" do
    before do
      expect_any_instance_of(UserObserver).to receive(:after_create).and_call_original
    end

    let(:user) { build(:user, newsletter: false) }

    it "send new user registration notification" do
      expect(user).to receive(:notify).with(:new_user_registration)
      expect(SendgridSyncWorker).to_not receive(:perform_async)
      user.save
    end

    it "when user in newsletter" do
      user.newsletter = true
      expect(SendgridSyncWorker).to receive(:perform_async).at_least(:once)
      user.save
    end
  end

  context 'before_save' do
    subject { create(:user, twitter: '@should_be_change') }

    its(:twitter) { should == 'should_be_change' }
  end

  context 'after_save' do
    subject { create(:user, newsletter: false, facebook_link: '') }

    context 'when user change the newsletter option' do
      before do
        expect(SendgridSyncWorker).to receive(:perform_async).with(subject.id)
      end

      it { subject.update_attribute(:newsletter, true) }
    end
  end

end
