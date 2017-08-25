require 'rails_helper'

RSpec.describe MailMarketingUser, type: :model do
  describe 'after destroy' do
    let(:marketing_user) { create(:mail_marketing_user, user: create(:user)) }

    before do
      expect(SendgridSyncWorker).to receive(:perform_async).with(marketing_user.user_id, marketing_user.mail_marketing_list_id)
    end

    it 'should call sendgrid worker after destroy' do
      marketing_user.destroy
    end
  end
end
