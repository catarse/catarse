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

  let(:redbooth_user_atendimento) do
    CatarseSettings[:email_redbooth_atendimento] = 'foo_atendimento@foo.com'
    create(:user, email: CatarseSettings[:email_redbooth_atendimento])
  end

  subject{ contribution }

  before do
    CatarseSettings[:support_forum] = 'http://support.com'
    CatarseSettings[:email_projects] = 'foo@foo.com'
    CatarseSettings[:facebook_url] = 'http://facebook.com/foo'
    CatarseSettings[:blog_url] = 'http://blog.com/foo'
    CatarseSettings[:company_name] = 'Catarse'
  end

  describe "#after_save" do
    let(:project) { build(:project, state: 'approved', online_date: 10.days.from_now) }

    context "when change the online_date" do
      before do
        expect(project).to receive(:remove_scheduled_job).with('ProjectSchedulerWorker')
        expect(ProjectSchedulerWorker).to receive(:perform_at)
      end
      it "should call project scheduler" do
        project.save(validate: false)
      end
    end

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

    context "after creating the project" do
      let(:project) { build(:project) }

      before do
        expect(InactiveDraftWorker).to receive(:perform_at)
      end

      it "should call perform at in inactive draft worker" do
        project.save
      end
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
      redbooth_user_atendimento
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

      it "should not send redbooth_task_project_will_succeed notification" do
        expect(ProjectNotification.where(template_name: 'redbooth_task_project_will_succeed', user: redbooth_user_atendimento, project: project).count).to eq 0
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

      it "should send redbooth_task_project_will_succeed notification" do
        expect(ProjectNotification.where(template_name: 'redbooth_task_project_will_succeed', user: redbooth_user_atendimento, project: project).count).to eq 1
      end
    end

    it "should send project_visible notification" do
      expect(ProjectNotification.where(template_name: 'project_in_waiting_funds', user: project.user, project: project).count).to eq 1
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

    it "should send adm_project_deadline notification" do
      expect(ProjectNotification.where(template_name: 'adm_project_deadline', user: admin_user, project: project).count).to eq 1
    end
    it "should create notification for admin" do
      expect(ProjectNotification.where(template_name: 'redbooth_task', user: redbooth_user, project_id: project.id).count).not_to be_nil
    end
  end

  describe '#from_waiting_funds_to_failed' do
    before do
      admin_user
      project.notify_observers(:from_waiting_funds_to_failed)
    end

    it "should send adm_project_deadline notification" do
      expect(ProjectNotification.where(template_name: 'adm_project_deadline', user: admin_user, project: project).count).to eq 1
    end
  end
end
