# encoding:utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailMarketingUsersController, type: :controller do
  describe '#subscribe' do
    let!(:mail_list) { create(:mail_marketing_list) }
    before do
      request.env["HTTP_REFERER"] = 'http://foo.bar'
      allow(controller).to receive(:sendgrid_api).and_return(double(client: true))
      allow(controller).to receive(:push_to_sendgrid).and_return(true)
    end
    context 'when email is on user database' do
      let!(:user) { create(:user, email: 'foo@bar.com') }
      before do
        expect(SendgridSyncWorker).to receive(:perform_async).with(user.id)
        get :subscribe, locale: 'pt', EMAIL: "foo@bar.com", list_id: mail_list.list_id
      end

      it 'should insert mail_marketing_users to user' do
        expect(user.mail_marketing_users.count).to eq(1)
      end

      it 'should subscribe and redirect back' do
        expect(response).to be_redirect
      end
    end

    context 'when email is not in user database' do
      let(:mail_list) { create(:mail_marketing_list) }
      before do
        expect(controller).to receive(:push_to_sendgrid).with("foo@bar.com", mail_list)
      end

      it "should subscribe only on sendgrid" do
        get :subscribe, locale: 'pt', EMAIL: "foo@bar.com", list_id: mail_list.list_id
      end
    end

    context 'using invalid email' do
      before do
        expect(SendgridSyncWorker).not_to receive(:perform_async)
        get :subscribe, locale: 'pt', EMAIL: "foobar.com", list_id: mail_list.list_id
      end

      it 'should do nothing' do
        expect(response).to be_redirect
      end
    end
  end

  describe '#unsubscribe' do
    context 'with invalid token' do
      before do
        expect(SendgridSyncWorker).not_to receive(:perform_async)
        get :unsubscribe, locale: 'pt', unsubcribe_token: SecureRandom.uuid
      end

      it 'should not found' do
        expect(response.code).to eq("404")
      end
    end

    context 'with valid token' do
      let!(:mail_marketing_user) { create(:mail_marketing_user, unsubcribe_token: SecureRandom.uuid ) }
      before do
        expect(SendgridSyncWorker).to receive(:perform_async).with(mail_marketing_user.user_id, mail_marketing_user.mail_marketing_list_id)
        get :unsubscribe, locale: 'pt', unsubcribe_token: mail_marketing_user.unsubcribe_token
      end

      it 'should delete mail marketing user' do
        expect(MailMarketingUser.count).to eq(0)
      end

      it 'should redirect to root' do
        expect(response).to be_redirect
      end
    end
  end
end
