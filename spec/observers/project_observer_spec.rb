require 'spec_helper'

describe ProjectObserver do
  let(:new_draft_project){ FactoryGirl.create(:notification_type, :name => 'new_draft_project') }
  let(:confirm_backer){ FactoryGirl.create(:notification_type, :name => 'confirm_backer') }
  let(:project_received){ FactoryGirl.create(:notification_type, :name => 'project_received') }
  let(:project_success){ FactoryGirl.create(:notification_type, :name => 'project_success') }
  let(:backer_successful){ FactoryGirl.create(:notification_type, :name => 'backer_project_successful') }
  let(:backer_unsuccessful){ FactoryGirl.create(:notification_type, :name => 'backer_project_unsuccessful') }
  let(:pending_backer_unsuccessful){ FactoryGirl.create(:notification_type, :name => 'pending_backer_project_unsuccessful') }  
  let(:project_visible){ FactoryGirl.create(:notification_type, :name => 'project_visible') }
  let(:project_rejected){ FactoryGirl.create(:notification_type, :name => 'project_rejected') }
  let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => nil) }
  let(:project) { FactoryGirl.create(:project, goal: 3000) }

  subject{ backer }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    new_draft_project
    project_received
    confirm_backer
    project_success
    backer_successful
    backer_unsuccessful
  end

  describe "after_create" do
    before do
      ProjectObserver.any_instance.unstub(:after_create)
      ::Configuration[:facebook_url] = 'http://facebook.com'
      ::Configuration[:blog_url] = 'http://blog.com'
      ::Configuration[:company_name] = 'Catarse'
      user
      project
    end
    let(:user) { FactoryGirl.create(:user, email: ::Configuration[:email_projects])}

    it "should create notification for catarse admin" do
      Notification.where(user_id: user.id, notification_type_id: new_draft_project.id, project_id: project.id).first.should_not be_nil
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, notification_type_id: project_received.id, project_id: project.id).first.should_not be_nil
    end
  end

  describe "before_save" do
    let(:project){ FactoryGirl.create(:project, :video_url => 'http://vimeo.com/11198435')}
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
      let(:project){ FactoryGirl.create(:project, :can_finish => true, :goal => 30, :online_days => -7, :state => 'waiting_funds') }
      let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 30, :project => project) }

      before do
        Notification.expects(:create_notification_once).at_least_once
        backer.save!
        project.finish!
      end
      it("should notify the project backers"){ subject }
    end

    context "when project is unsuccessful" do
      let(:project){ FactoryGirl.create(:project, :goal => 30, :online_days => -7, :state => 'waiting_funds') }
      let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 20) }
      before do
        Notification.expects(:create_notification_once).at_least_once
        backer.save!
        project.finish!
      end
      it("should notify the project backers and owner"){ subject }
    end
    
    context "when project is unsuccessful with pending backers" do
      let(:project){ FactoryGirl.create(:project, :goal => 30, :online_days => -7, :state => 'waiting_funds') }

      before do
        FactoryGirl.create(:backer, project: project, key: 'ABC1', payment_method: 'ABC', payment_token: 'ABC', value: 20, confirmed: true)
        FactoryGirl.create(:backer, project: project, key: 'ABC2', payment_method: 'ABC', payment_token: 'ABC', value: 20, confirmed: false)
      end

      before do
        Notification.expects(:create_notification_once).at_least(3)
        project.finish!
      end
      it("should notify the project backers and owner"){ subject }      
    end

  end

  describe '#notify_owner_that_project_is_successful' do
    let(:project){ FactoryGirl.create(:project, :goal => 30, :online_days => -7, :state => 'waiting_funds') }

    before do
      ::Configuration[:facebook_url] = 'http://facebook.com/foo'
      ::Configuration[:blog_url] = 'http://blog.com/foo'
      project.stubs(:reached_goal?).returns(true)
      project.stubs(:in_time_to_wait?).returns(false)
      project_success
      project.finish
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, notification_type_id: project_success.id, project_id: project.id).first.should_not be_nil
    end
  end

  describe "#notify_owner_that_project_is_rejected" do
    before do
      ::Configuration[:facebook_url] = 'http://facebook.com/foo'
      ::Configuration[:blog_url] = 'http://blog.com/foo'
      project_rejected
      project.reject
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, notification_type_id: project_rejected.id, project_id: project.id).first.should_not be_nil
    end

  end
end
