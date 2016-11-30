require 'rails_helper'

RSpec.describe SendgridSyncWorker do
  let(:user) { create(:user) }
  let(:srmock) do
    double(
      post: double( body: { persisted_recipients: ['xxx'] }.to_json ),
      patch: double( body: { persisted_recipients: ['xxx'] }.to_json ),
      search: double(
        get: double(
          body: {
            recipients: []
          }.to_json
        )
      )
    )
  end


  before do
    CatarseSettings[:sendgrid_mkt_api_key] = 'key'
    Sidekiq::Testing.inline!
    allow(User).to receive(:find).with(user.id).and_return(user)
    allow_any_instance_of(SendgridSyncWorker).to receive(:sendgrid_recipients).and_return(srmock)
  end

  subject { SendgridSyncWorker.new }

  describe 'when user sendgrid recipient id is null' do
    describe 'when user exists on sendgrid recipients' do
      before do
        allow(subject).to receive(:search_recipient).and_return({id: 'xxx'})
        expect(subject).to_not receive(:create_recipient).and_call_original
        expect(user).to receive(:update_column).with(:sendgrid_recipient_id, 'xxx')
      end

      it { subject.perform(user.id) }
    end

    describe 'when user does not exists on sendgrid recipients' do
      before do
        expect(subject).to receive(:find_or_create_recipient).and_call_original
        expect(subject).to receive(:create_recipient).and_call_original
        expect(user).to receive(:update_column).with(:sendgrid_recipient_id, 'xxx')
      end

      it { subject.perform(user.id) }
    end
  end

  describe 'when user sengrid recipient id aleady filled' do
    describe 'just refreshing' do
      before do
        allow(user).to receive(:sendgrid_recipient_id).and_return('xxx')
        expect(subject).to receive(:update_recipient)
      end

      it { subject.perform(user.id) }
    end
  end
end
