# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectObserver do
  let(:contribution) { create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:project) do
    project = create(:project, state: 'draft', goal: 3000)
    create(:reward, project: project)
    project.update_attribute :state, :online
    project
  end

  let(:admin_user) do
    CatarseSettings[:email_payments] = 'admin@foo.com'
    create(:user, email: CatarseSettings[:email_payments])
  end

  let(:redbooth_user) do
    CatarseSettings[:email_redbooth] = 'foo@foo.com'
    create(:user, email: CatarseSettings[:email_redbooth])
  end

  let(:zendesk_user_atendimento) do
    CatarseSettings[:email_contact] = 'foo_contato@foo.com'
    create(:user, email: CatarseSettings[:email_contact])
  end

  subject { contribution }

  before do
    CatarseSettings[:support_forum] = 'http://support.com'
    CatarseSettings[:email_projects] = 'foo@foo.com'
    CatarseSettings[:facebook_url] = 'http://facebook.com/foo'
    CatarseSettings[:blog_url] = 'http://blog.com/foo'
    CatarseSettings[:company_name] = 'Catarse'
  end

  describe '#before_save' do
    context 'when video_url changed' do
      let(:project) { create(:project, video_url: 'https://www.youtube.com/watch?v=9QveBbn7t_c', video_embed_url: 'embed_url') }

      it 'should clean embed_url when video_is null' do
        expect(project.video_embed_url.present?).to eq(true)
        project.video_url = nil
        project.save
        expect(project.video_embed_url.present?).to eq(false)
      end
    end
    context 'when project is new' do
      before do
        expect(project).to receive(:update_expires_at)
      end

      let(:project) { build(:project, state: 'draft') }

      it 'should call update_expires_at' do
        project.save(validate: false)
      end
    end

    context 'when project is being updated and online_days does not change' do
      before do
        expect(project).to_not receive(:update_expires_at)
      end

      let!(:project) { create(:project, state: 'draft', expires_at: Date.tomorrow) }

      it 'should not call update_expires_at' do
        project.save(validate: false)
      end
    end

    context 'when expires_at is nil and we have both online_at and online_days' do
      before do
        expect(project).to receive(:update_expires_at)
      end

      let!(:project) { create(:project, state: 'draft', online_days: 60) }

      it 'should not call update_expires_at' do
        project.save(validate: false)
      end
    end
  end

  describe '#after_save' do
    let(:project) { build(:project, state: 'draft') }

    context 'common integration' do
      before do
        expect(project).to receive(:index_on_common)
      end
      it 'should call index on common' do
        project.update_attribute(:name, 'foo bar')
      end
    end


    context 'when we change the video_url' do
      let(:project) { create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft') }
      before do
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id).never
      end
      it 'should call project downloader' do
        project.save(validate: false)
      end
    end
  end

  describe "#from_draft_to_online" do
    context 'expect that update expires_at and audited data' do
      let(:project) { create(:project, state: 'draft') }
      it do
        expect(project).to receive(:update_expires_at).at_least(:once).and_return(true)
        expect(project).to receive(:update_attributes).with(
          published_ip: project.user.current_sign_in_ip,
          audited_user_name: project.user.name,
          audited_user_cpf: project.user.cpf,
          audited_user_phone_number: project.user.phone_number
        ).and_return(true)
        project.push_to_online
      end
    end

    context 'expect call worker to broadcast new project online to followers' do
      let(:project) { create(:project, state: 'draft') }
      it do
        expect(UserBroadcastWorker).to receive(:perform_async).with(follow_id: project.user_id, template_name: 'follow_project_online', project_id: project.id)
        project.push_to_online
      end
    end

    context 'expect call worker to update fb cache' do
      let(:project) { create(:project, state: 'draft') }
      it do
        expect(FacebookScrapeReloadWorker).to receive(:perform_async).with(project.direct_url)
        project.push_to_online
      end
    end

    context 'expect call worker to schedule project metrics storage' do
      let(:project) { create(:project, state: 'draft') }
      it do
        expect(ProjectMetricStorageRefreshWorker).to receive(:perform_in).with(5.seconds, project.id)
        project.push_to_online
      end
    end
  end

  describe '#from_online_to_failed' do
    let(:project) do
      create_project({
        goal: 100,
        online_days: 30,
        state: 'online'
      }, {
        to_state: 'online',
        created_at: 3.days.ago
      })
    end

    let(:contribution_invalid) do
      create(:confirmed_contribution, value: 10, project: project)
    end

    let(:contribution_valid) do
      create(:confirmed_contribution, value: 10, project: project)
    end

    context 'should refund slip into balance' do
      let!(:payment_valid) do
        contribution_valid.payments.first
      end

      let!(:payment_slip) do
        p = contribution_invalid.payments.first
        p.update_column(:payment_method, 'BoletoBancario')
        p
      end

      before do
        Sidekiq::Testing.inline!
        contribution_invalid.user.bank_account.destroy
        project.update_attribute :online_days, 2
        expect(project).not_to receive(:notify_owner).with(:project_canceled)
        expect(DirectRefundWorker).to receive(:perform_async).with(payment_valid.id)
        expect(DirectRefundWorker).to receive(:perform_async).with(payment_slip.id).and_call_original
        expect(BalanceTransaction).to receive(:insert_contribution_refund).with(payment_slip.contribution_id)
      end

      it { project.finish }
    end
  end

  describe 'from_successful_to_rejected' do
    let(:project) do
      create_project({
        goal: 100,
        online_days:5,
        state: 'online'
      }, {
        to_state: 'online',
        created_at: 3.days.ago
      })
    end

    let!(:contribution) do
      create(:confirmed_contribution, value: 150, project: project)
    end

    before do
      #expect(BalanceTransaction).to receive(:insert_project_refund_contributions).with(project.id).and_call_original
      expect(BalanceTransaction).to receive(:insert_contribution_refund).with(contribution.id).and_call_original
      expect(BalanceTransaction).to receive(:insert_successful_project_transactions).with(project.id).and_call_original

      project.update_attribute(:online_days, 1)
      Sidekiq::Testing.inline!

      project.finish

      expect(project).to receive(:notify_owner).with(:project_canceled).and_call_original
      project.reject
    end

    it 'should refund contributons' do
      expect(contribution.payments.last.state).to eq('refunded')
      expect(contribution.balance_transactions.where(event_name: 'contribution_refund').count).to eq(1)
    end

    it 'should remove project owner balance' do
      expect(project.balance_transactions.where(event_name: 'refund_contributions').count).to eq(1)
    end
  end

  describe '#from_waiting_funds_to_successful' do
    before do
      admin_user
      redbooth_user
      project.notify_observers(:from_waiting_funds_to_successful)
    end

    it 'should create notification for admin' do
      expect(ProjectNotification.where(template_name: 'redbooth_task', user: redbooth_user, project_id: project.id).count).to eq(1)
    end

    it 'should create notification for project owner' do
      expect(ProjectNotification.where(template_name: 'project_success', user: project.user, project_id: project.id).count).to eq(5)
    end
  end
end
