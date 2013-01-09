require 'spec_helper'

describe ProjectObserver do
  let(:new_draft_project){ Factory(:notification_type, :name => 'new_draft_project') }
  let(:confirm_backer){ Factory(:notification_type, :name => 'confirm_backer') }
  let(:project_success){ Factory(:notification_type, :name => 'project_success') }
  let(:backer_successful){ Factory(:notification_type, :name => 'backer_project_successful') }
  let(:backer_unsuccessful){ Factory(:notification_type, :name => 'backer_project_unsuccessful') }
  let(:project_visible){ Factory(:notification_type, :name => 'project_visible') }
  let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => nil) }
  subject{ backer }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    new_draft_project
    confirm_backer
    project_success
    backer_successful
    backer_unsuccessful
  end

  describe "after_create" do
    before { ProjectObserver.any_instance.unstub(:after_create) }
    let(:project) { Factory(:project) }
    let(:user) { Factory(:user, id: Configuration[:email_projects])}

    it "should call create_notification" do
      Notification.expects(:create_notification_once).with(:new_draft_project, project.user, {project_id: project.id}, {project: project})
      project.save!
    end
  end

  describe "before_save" do
    let(:project){ Factory(:project, :video_url => 'http://vimeo.com/11198435')}
    context "when project is approved" do
      before do
        project.expects(:download_video_thumbnail).never
      end

      it "should call create_notification and do not call download_video_thumbnail" do
        Notification.expects(:create_notification_once).with(:project_visible, project.user, {project_id: project.id}, {:project => project})
        project.approve
      end
    end

    context "when video_url changes" do
      before do
        project.expects(:download_video_thumbnail)
        Notification.expects(:create_notification).never
        Notification.expects(:create_notification_once).never
      end

      it "should call download_video_thumbnail and do not call create_notification" do
        project.video_url = 'http://vimeo.com/66698435'
        project.save!
      end
    end
  end

  describe "notify_backers" do

    context "when project is successful" do
      let(:project){ Factory(:project, :can_finish => true, :goal => 30, :online_days => -7, :state => 'waiting_funds') }
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 30, :project => project) }

      before do
        Notification.expects(:create_notification_once).at_least_once
        backer.save!
        project.finish!
      end
      it("should notify the project backers"){ subject }
    end

    context "when project is unsuccessful" do
      let(:project){ Factory(:project, :goal => 30, :online_days => -7, :state => 'waiting_funds') }
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 20) }
      before do
        Notification.expects(:create_notification_once).at_least_once
        backer.save!
        project.finish!
      end
      it("should notify the project backers and owner"){ subject }
    end

  end
end
