require 'rails_helper'

RSpec.describe ProjectObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:project) do
    project = create(:project, state: 'draft', goal: 3000)
    create(:reward, project: project)
    project.update_attribute :state, :online
    project
  end

  subject{ contribution }

  before do
    CatarseSettings[:support_forum] = 'http://support.com'
    CatarseSettings[:email_projects] = 'foo@foo.com'
    CatarseSettings[:facebook_url] = 'http://facebook.com/foo'
    CatarseSettings[:blog_url] = 'http://blog.com/foo'
    CatarseSettings[:company_name] = 'Catarse'
  end

  describe "after_save" do
    let(:project) { build(:project, state: 'approved', online_date: 10.days.from_now) }

    context "when change the online_date" do
      before do
        expect(project).to receive(:remove_scheduled_job).with('ProjectSchedulerWorker')
        expect(ProjectSchedulerWorker).to receive(:perform_at)
      end

      it { project.save(validate: false) }
    end
  end

  describe "after_create" do
    before do
      expect_any_instance_of(ProjectObserver).to receive(:after_create).and_call_original
      project
    end

    it "should create notification for project owner" do
      expect(ProjectNotification.where(user_id: project.user.id, template_name: 'project_received', project_id: project.id).first).not_to be_nil
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

  describe "when project is sent to curator" do
    let(:project) do
      project = create(:project, state: 'draft')
      create(:reward, project: project)
      project
    end
    let(:user) { create(:user, email: ::CatarseSettings[:email_projects])}

    before do
      user
      project
      project.send_to_analysis!
    end

    it "should create notification for catarse admin" do
      expect(ProjectNotification.where(user_id: user.id, template_name: :new_draft_project, project_id: project.id).first).not_to be_nil
    end
  end

  describe "before_save" do
    let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft')}

    context "when project is approved" do
      before do
        project.update_attributes state: 'approved'
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id).never
      end

      it "should call notify and do not call download_video_thumbnail" do
        expect(ProjectNotification).to receive(:notify_once).with(
          :project_visible,
          project.user,
          project,
          {
            from_email: CatarseSettings[:email_projects],
            from_name: CatarseSettings[:company_name]
          }
        )
        project.push_to_online
      end
    end

    context "when video_url changes" do
      before do
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id).at_least(1)
        expect(ProjectNotification).to receive(:notify).never
        expect(ProjectNotification).to receive(:notify_once).never
      end

      it "should call project downloader service and do not call create_notification" do
        project.video_url = 'http://vimeo.com/66698435'
        project.save!
      end
    end
  end

  describe "#from_in_analysis_to_approved" do
    let(:project) { create(:project, state: 'in_analysis')}

    context "notify owner when projects is approved" do
      before do
        expect(ProjectNotification).to receive(:notify_once).with(
          :project_approved,
          project.user,
          project,
          {
            from_email: CatarseSettings[:email_projects]
          }
        )
      end

      it { project.approve }
    end
  end

  describe "#notify_owner_that_project_is_waiting_funds" do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user, goal: 100, online_days: 1, online_date: Time.now - 2.days, state: 'online') }

    before do
      create(:contribution, project: project, value: 200, state: 'confirmed')
      expect(ProjectNotification).to receive(:notify_once).with(
        :project_in_waiting_funds,
        project.user,
        project,
        {
          from_email: CatarseSettings[:email_projects]
        }
      )
    end

    it("should notify the project owner"){ project.finish }
  end

  describe "save_dates" do
    let(:project) do
      project = create(:project, state: 'draft')
      create(:reward, project: project)
      project.update_attribute :state, :in_analysis
      project
    end
    context "when project goes from in_analysis to rejected" do
      before do
        project.reject
      end
      it("should save current date"){expect(project.rejected_at).to_not be_nil}
    end

    context "when project goes from in_analysis to draft" do
      before do
        project.push_to_draft
      end
      it("should save current date"){expect(project.sent_to_draft_at).to_not be_nil}
    end

  end

  describe "notify_contributors" do

    context "when project is successful" do
      let(:project){ create(:project, goal: 30, online_days: 1, online_date: Time.now - 8.days, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 30, project: project) }

      before do
        contribution
        project.update_attributes state: 'waiting_funds'
        expect(ProjectNotification).to receive(:notify_once).at_least(:once)
        contribution.save!
        project.finish!
      end
      it("should notify the project contributions"){ subject }
    end

    context "when project is unsuccessful" do
      let(:project){ create(:project, goal: 30, online_days: 1, online_date: Time.now - 8.days, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 20) }
      before do
        contribution
        project.update_attributes state: 'waiting_funds'
        expect(ProjectNotification).to receive(:notify_once).at_least(:once)
        contribution.save!
        project.finish!
      end
      it("should notify the project contributions and owner"){ subject }
    end

    context "when project is unsuccessful with pending contributions" do
      let(:project){ create(:project, goal: 30, online_days: 1, online_date: Time.now - 8.days, state: 'online') }

      before do
        create(:contribution, project: project, key: 'ABC1', payment_method: 'ABC', payment_token: 'ABC', value: 20, state: 'confirmed')
        create(:contribution, project: project, key: 'ABC2', payment_method: 'ABC', payment_token: 'ABC', value: 20)
        project.update_attributes state: 'waiting_funds'
      end

      before do
        expect(ContributionNotification).to receive(:notify_once).at_least(1)
        project.finish!
      end
      it("should notify the project contributions and owner"){ subject }
    end

  end

  describe '#notify_owner_that_project_is_successful' do
    let(:project){ create(:project, goal: 30, online_days: 1, online_date: Time.now - 8.days, state: 'waiting_funds') }

    before do
      allow(project).to receive(:reached_goal?).and_return(true)
      allow(project).to receive(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it "should create notification for project owner" do
      expect(ProjectNotification.where(user_id: project.user.id, template_name: 'project_success', project_id: project.id).first).not_to be_nil
    end
  end

  describe "#notify_owner_that_project_is_online" do
    let(:project) do
      project = create(:project, state: 'draft')
      create(:reward, project: project)
      project.update_attribute :state, :approved
      project
    end

    before do
      project.push_to_online
    end

    it "should create notification for project owner" do
      expect(ProjectNotification.where(user_id: project.user.id, template_name: 'project_visible', project_id: project.id).first).not_to be_nil
    end
  end

  describe "#notify_admin_that_project_reached_deadline" do
    let(:project){ create(:project, goal: 30, online_days: 1, online_date: Time.now - 8.days, state: 'waiting_funds') }
    let(:user) { create(:user, email: 'foo@foo.com')}
    before do
      CatarseSettings[:email_payments] = 'foo@foo.com'
      CatarseSettings[:email_system] = 'foo2@foo.com'
      user
      allow(project).to receive(:reached_goal?).and_return(true)
      allow(project).to receive(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it "should create notification for admin" do
      expect(ProjectNotification.where(user_id: user.id, template_name: 'adm_project_deadline', project_id: project.id).first).not_to be_nil
    end

  end

  describe "#notify_admin_that_project_is_successful" do
    let(:project){ create(:project, goal: 30, online_days: 1, online_date: Time.now - 8.days, state: 'waiting_funds') }
    let(:user) { create(:user, email: 'foo@foo.com')}
    before do
      CatarseSettings[:email_redbooth] = 'foo@foo.com'
      user
      allow(project).to receive(:reached_goal?).and_return(true)
      allow(project).to receive(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it "should create notification for admin" do
      expect(ProjectNotification.where(user_id: user.id, template_name: 'redbooth_task', project_id: project.id).first).not_to be_nil
    end

  end

  #describe "#request_refund_for_failed_project" do
  #  let(:project){ create(:project, state: 'online') }
  #  let(:user){ create(:user) }
  #  let(:contribution) { create(:contribution, state: 'confirmed', payment_method: 'PayPal', project_id: project.id, user_id: user.id, value: 10, credits: false)}
  #  before do
  #    project
  #    user
  #    contribution
  #    project.stub(:should_fail?).and_return(true)
  #    project.stub(:pending_contributions_reached_the_goal?).and_return(false)
  #    project.finish
  #    contribution.reload
  #  end

  #  it "should change contribution state to requested_refund" do
  #    expect(contribution.reload.state).to eq 'requested_refund'
  #  end

  #end

end
