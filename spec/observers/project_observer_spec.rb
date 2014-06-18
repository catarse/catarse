require 'spec_helper'

describe ProjectObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:project) { create(:project, goal: 3000) }
  let(:channel) { create(:channel) }

  subject{ contribution }

  before do
    CatarseSettings[:support_forum] = 'http://support.com'
    CatarseSettings[:email_projects] = 'foo@foo.com'
    CatarseSettings[:facebook_url] = 'http://facebook.com/foo'
    CatarseSettings[:blog_url] = 'http://blog.com/foo'
    CatarseSettings[:company_name] = 'Catarse'
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
  end

  describe "after_save" do
    let(:project) { build(:project, state: 'in_analysis', online_date: 10.days.from_now) }

    context "when change the online_date" do
      before do
        project.should_receive(:remove_scheduled_job).with('ProjectSchedulerWorker')
        ProjectSchedulerWorker.should_receive(:perform_at)
      end

      it { project.save }
    end
  end

  describe "after_create" do
    before do
      ProjectObserver.any_instance.should_receive(:after_create).and_call_original
      project
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, template_name: 'project_received', project_id: project.id).first.should_not be_nil
    end

    context "after creating the project" do
      let(:project) { build(:project) }

      before do
        InactiveDraftWorker.should_receive(:perform_at)
      end

      it "should call perform at in inactive draft worker" do
        project.save
      end
    end
  end

  describe "when project is sent to curator" do
    let(:project) { create(:project, goal: 3000, state: 'draft') }
    let(:user) { create(:user, email: ::CatarseSettings[:email_projects])}

    before do
      user
      project
      project.send_to_analysis!
    end

    it "should create notification for catarse admin" do
      Notification.where(user_id: user.id, template_name: :new_draft_project, project_id: project.id).first.should_not be_nil
    end
  end

  describe "before_save" do
    let(:channel){ create(:channel) }
    let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft')}

    context "when project is approved and belongs to a channel" do
      let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft', channels: [channel])}
      before do
        project.update_attributes state: 'in_analysis'
      end

      it "should call notify using channel data" do
        Notification.should_receive(:notify_once).with(
          :project_visible_channel,
          project.user,
          { project_id: project.id, channel_id: channel.id},
          {
            project: project,
            channel: channel,
            origin_email: channel.email,
            origin_name: channel.name
          }
        )
        project.approve
      end
    end

    context "when project is approved" do
      before do
        project.update_attributes state: 'in_analysis'
        ProjectDownloaderWorker.should_receive(:perform_async).with(project.id).never
      end

      it "should call notify and do not call download_video_thumbnail" do
        Notification.should_receive(:notify_once).with(
          :project_visible,
          project.user,
          { project_id: project.id, channel_id: nil},
          {
            project: project,
            channel: nil,
            origin_email: CatarseSettings[:email_projects],
            origin_name: CatarseSettings[:company_name]
          }
        )
        project.approve
      end
    end

    context "when video_url changes" do
      before do
        ProjectDownloaderWorker.should_receive(:perform_async).with(project.id).at_least(1)
        Notification.should_receive(:notify).never
        Notification.should_receive(:notify_once).never
      end

      it "should call project downloader service and do not call create_notification" do
        project.video_url = 'http://vimeo.com/66698435'
        project.save!
      end
    end
  end

  describe "#notify_owner_that_project_is_waiting_funds" do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user, goal: 100, online_days: -2, state: 'online') }

    before do
      create(:contribution, project: project, value: 200, state: 'confirmed')
      Notification.should_receive(:notify_once).with(
        :project_in_wainting_funds,
        project.user,
        {project_id: project.id, channel_id: project.last_channel.try(:id)},
        {
          project: project,
          origin_email: CatarseSettings[:email_projects]
        }
      )
    end

    it("should notify the project owner"){ project.finish }
  end

  describe "save_dates" do
    context "when project goes from in_analysis to rejected" do
      let(:project){ create(:project, state: 'in_analysis') }
      before do
        project.reject
      end
      it("should save current date"){expect(project.rejected_at).to_not be_nil}
    end

    context "when project goes from in_analysis to draft" do
      let(:project){ create(:project, state: 'in_analysis') }
      before do
        project.push_to_draft
      end
      it("should save current date"){expect(project.sent_to_draft_at).to_not be_nil}
    end

  end

  describe "notify_contributors" do

    context "when project is successful" do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 30, project: project) }

      before do
        contribution
        project.update_attributes state: 'waiting_funds'
        Notification.should_receive(:notify_once).at_least(:once)
        contribution.save!
        project.finish!
      end
      it("should notify the project contributions"){ subject }
    end

    context "when project is unsuccessful" do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 20) }
      before do
        contribution
        project.update_attributes state: 'waiting_funds'
        Notification.should_receive(:notify_once).at_least(:once)
        contribution.save!
        project.finish!
      end
      it("should notify the project contributions and owner"){ subject }
    end

    context "when project is unsuccessful with pending contributions" do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }

      before do
        create(:contribution, project: project, key: 'ABC1', payment_method: 'ABC', payment_token: 'ABC', value: 20, state: 'confirmed')
        create(:contribution, project: project, key: 'ABC2', payment_method: 'ABC', payment_token: 'ABC', value: 20)
        project.update_attributes state: 'waiting_funds'
      end

      before do
        Notification.should_receive(:notify_once).at_least(3)
        project.finish!
      end
      it("should notify the project contributions and owner"){ subject }
    end

  end

  describe '#notify_owner_that_project_is_successful' do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }

    before do
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, template_name: 'project_success', project_id: project.id).first.should_not be_nil
    end
  end

  describe "#notify_owner_that_project_is_online" do
    let(:project) { create(:project, state: 'in_analysis') }

    context "when project don't belong to any channel" do
      before do
        project.approve
      end

      it "should create notification for project owner" do
        Notification.where(user_id: project.user.id, template_name: 'project_visible', project_id: project.id).first.should_not be_nil
      end
    end

    context "when project belong to a channel" do
      before do
        project.channels << channel
        project.approve
      end

      it "should create notification for project owner" do
        Notification.where(user_id: project.user.id, template_name: 'project_visible_channel', project_id: project.id).first.should_not be_nil
      end
    end
  end

  describe "#notify_owner_that_project_is_rejected" do
    let(:project){ create(:project, state: 'in_analysis') }

    context "when project don't belong to any channel" do
      before do
        project.reject
      end
      it "should create notification for project owner" do
        Notification.where(user_id: project.user.id, template_name: 'project_rejected', project_id: project.id).first.should_not be_nil
      end
    end

    context "when project belong to a channel" do
      before do
        project.channels << channel
        project.reject
      end

      it "should create notification for project owner" do
        Notification.where(user_id: project.user.id, template_name: 'project_rejected_channel', project_id: project.id).first.should_not be_nil
      end
    end

  end

  describe "#notify_admin_that_project_reached_deadline" do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }
    let(:user) { create(:user, email: 'foo@foo.com')}
    before do
      CatarseSettings[:email_payments] = 'foo@foo.com'
      CatarseSettings[:email_system] = 'foo2@foo.com'
      user
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it "should create notification for admin" do
      Notification.where(user_id: user.id, template_name: 'adm_project_deadline', project_id: project.id).first.should_not be_nil
    end

  end

end
