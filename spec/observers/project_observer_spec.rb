require 'rails_helper'

RSpec.describe ProjectObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
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

  subject{ contribution }

  before do
    CatarseSettings[:support_forum] = 'http://support.com'
    CatarseSettings[:email_projects] = 'foo@foo.com'
    CatarseSettings[:facebook_url] = 'http://facebook.com/foo'
    CatarseSettings[:blog_url] = 'http://blog.com/foo'
    CatarseSettings[:company_name] = 'Catarse'
  end

  describe "#before_save" do
    context "when project is not online" do
      let(:project) { build(:project, state: 'approved', online_date: nil) }
      before do
        expect(project.expires_at).to eq nil
      end
      it "should update expires_at" do
        project.save(validate: false)
      end
    end
  end

  describe "#after_save" do
    let(:project) { build(:project, state: 'approved') }
    context "when we change the video_url" do
      let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft')}
      before do
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id).never
      end
      it "should call project downloader" do
        project.save(validate: false)
      end
    end
  end

  describe "#after_create" do
    before do
      expect_any_instance_of(ProjectObserver).to receive(:after_create).and_call_original
      project
    end

    it "should create notification for project owner" do
      expect(ProjectNotification.where(user_id: project.user.id, template_name: 'project_received', project_id: project.id).count).to eq 1
    end
  end

  describe "#from_draft_to_in_analysis" do
    before do
      @user = create(:user, email: ::CatarseSettings[:email_projects])
      @project = project = create(:project, state: 'draft')
      create(:reward, project: project)
      project.notify_observers(:from_draft_to_in_analysis)
    end

    it "should create notification for catarse admin" do
      expect(ProjectNotification.where(user_id: @user.id, template_name: :new_draft_project, project_id: @project.id).count).to eq 1
    end
  end

  describe "#from_approved_to_online" do
    before do
      project.notify_observers(:from_approved_to_online)
    end

    context "should fill expires_at" do
      it { expect(project.expires_at).to be_present }
    end

    it "should send project_visible notification" do
      expect(ProjectNotification.where(template_name: 'project_visible', user: project.user, project: project).count).to eq 1
    end
  end

  describe "#from_in_analysis_to_approved" do
    before do
      project.notify_observers(:from_in_analysis_to_approved)
    end

    it "should send project_visible notification" do
      expect(ProjectNotification.where(template_name: 'project_approved', user: project.user, project: project).count).to eq 1
    end
  end

  describe "#from_online_to_waiting_funds" do
    before do
      zendesk_user_atendimento
      project.notify_observers(:from_online_to_waiting_funds)
    end

    context "when project has not reached goal" do
      let(:project) do
        project = create(:project, state: 'draft', goal: 3000)
        create(:reward, project: project)
        project.update_attribute :state, :online
        allow(project).to receive(:reached_goal?).and_return(false)
        project
      end

      it "should not send project_will_succeed notification" do
        expect(ProjectNotification.where(template_name: 'project_will_succeed', user: zendesk_user_atendimento, project: project).count).to eq 0
      end
    end

    context "when project has reached goal" do
      let(:project) do
        project = create(:project, state: 'draft', goal: 3000)
        create(:reward, project: project)
        project.update_attribute :state, :online
        allow(project).to receive(:reached_goal?).and_return(true)
        project
      end

      it "should send project_will_succeed notification" do
        expect(ProjectNotification.where(template_name: 'project_will_succeed', user: zendesk_user_atendimento, project: project).count).to eq 1
      end
    end

    it "should send project_visible notification" do
      expect(ProjectNotification.where(template_name: 'project_in_waiting_funds', user: project.user, project: project).count).to eq 1
    end
  end

  describe "#from_online_to_failed" do
    let(:project) do
      create(:project, {
        goal: 100,
        online_date: 3.days.ago,
        online_days: 30,
        state: 'online'
      })
    end

    let(:contribution_invalid) do
      create(:confirmed_contribution, value: 10, project: project)
    end

    let(:contribution_valid) do
      create(:confirmed_contribution, value: 10, project: project)
    end

    context "not request refund to invalid bank_account slip payment" do
      let(:payment_valid) do
        contribution_valid.payments.first
      end

      let(:payment_invalid) do
        p = contribution_invalid.payments.first
        p.update_column(:payment_method, 'BoletoBancario')
        p
      end

      before do
        Sidekiq::Testing.inline!
        payment_valid
        payment_invalid
        contribution_invalid.user.bank_account.destroy
        project.update_attribute :online_days, 1
        expect(DirectRefundWorker).to receive(:perform_async).with(payment_valid.id)
        expect(DirectRefundWorker).to_not receive(:perform_async).with(payment_invalid.id)
      end

      it { project.finish }
    end
  end

  describe '#from_waiting_funds_to_successful' do
    before do
      admin_user
      redbooth_user
      project.notify_observers(:from_waiting_funds_to_successful)
    end

    it "should send project_visible notification" do
      expect(ProjectNotification.where(template_name: 'project_success', user: project.user, project: project).count).to eq 1
    end

    it "should create notification for admin" do
      expect(ProjectNotification.where(template_name: 'redbooth_task', user: redbooth_user, project_id: project.id).count).not_to be_nil
    end
  end
end
