# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendgridSyncWorker do
  let(:user) { create(:user) }
  before(:all) do
    @newsletter_list ||= create(:mail_marketing_list, provider: 'sendgrid', label: 'newsletter', list_id: 'xsb')
    CatarseSettings[:sendgrid_newsletter_list_id] = @newsletter_list.list_id
  end
  let(:srmock) do
    double(
      post: double(body: { persisted_recipients: ['xxx'] }.to_json),
      patch: double(body: { persisted_recipients: ['xxx'] }.to_json),
      search: double(
        get: double(
          body: {
            recipients: []
          }.to_json
        )
      )
    )
  end


  let!(:another_campaign) do
    MailMarketingList.create(
      provider: 'sendgrid',
      list_id: 'xsb2',
      label: 'another_campaign'
    )
  end

  before do
    CatarseSettings[:sendgrid_mkt_api_key] = 'key'
    Sidekiq::Testing.inline!
    allow(User).to receive(:find).with(user.id).and_return(user)
    allow_any_instance_of(SendgridSyncWorker).to receive(:sendgrid_recipients).and_return(srmock)
  end


  subject { SendgridSyncWorker.new }

  describe 'when user is deleting some list' do
    let!(:mail_marketing_user_alone) { create(:mail_marketing_user, user: user, last_sync_at: nil)}
    let(:marketing_user) { create(:mail_marketing_user) }
    let(:user) { marketing_user.user }
    before do
      expect(subject).not_to receive(:put_on_list)
      expect(subject).to receive(:remove_from_list)
        .with(marketing_user.mail_marketing_list.list_id)
    end

    it 'should only remove from list' do
      subject.perform(marketing_user.user_id, marketing_user.mail_marketing_list_id)
    end
  end

  describe 'when user sendgrid recipient id is null' do
    let!(:mail_marketing_user_alone) { create(:mail_marketing_user, user: user, last_sync_at: nil)}
    context 'when user exists on sendgrid recipients' do
      before do
        allow(subject).to receive(:search_recipient).and_return('xxx')
        expect(subject).to_not receive(:create_recipient).and_call_original
        expect(user).to receive(:update_column).with(:sendgrid_recipient_id, 'xxx')
      end

      it { subject.perform(user.id) }
    end

    context 'when user does not exists on sendgrid recipients' do
      before do
        expect(subject).to receive(:find_or_create_recipient).and_call_original
        expect(subject).to receive(:create_recipient).and_call_original
        expect(user).to receive(:update_column).with(:sendgrid_recipient_id, 'xxx')
      end

      it { subject.perform(user.id) }
    end
  end

  describe 'when user sendgrid recipient id aleady filled' do
    let!(:mail_marketing_user_alone) { create(:mail_marketing_user, user: user, last_sync_at: nil)}
    context 'just refreshing' do
      before do
        allow(user).to receive(:sendgrid_recipient_id).and_return('xxx')
        expect(subject).to receive(:update_recipient)
      end

      it { subject.perform(user.id) }
    end
  end

  describe 'manipulating lists' do
    context 'when user want receive newsletter' do
      before do
        create(:mail_marketing_user, user: user, mail_marketing_list: @newsletter_list)
        expect(subject).to receive(:put_on_list).with(@newsletter_list.list_id)
      end

      it { subject.perform(user.id) }
    end

    context 'when user dont want receive newsletter' do
      before do
        @mmu = create(:mail_marketing_user, user: user, mail_marketing_list: @newsletter_list)
        expect(subject).to receive(:remove_from_list).with(@newsletter_list.list_id)
      end

      it { subject.perform(user.id, @mmu.mail_marketing_list_id) }
    end
  end
end
