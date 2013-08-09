require 'spec_helper'

describe ProjectObserver do
  let(:new_draft_project){ create(:notification_type, name: 'new_draft_project') }
  let(:confirm_backer){ create(:notification_type, name: 'confirm_backer') }
  let(:project_received){ create(:notification_type, name: 'project_received') }
  let(:project_in_wainting_funds){ create(:notification_type, name: 'project_in_wainting_funds') }
  let(:adm_project_deadline){ create(:notification_type, name: 'adm_project_deadline') }
  let(:project_success){ create(:notification_type, name: 'project_success') }
  let(:backer_successful){ create(:notification_type, name: 'backer_project_successful') }
  let(:backer_unsuccessful){ create(:notification_type, name: 'backer_project_unsuccessful') }
  let(:pending_backer_unsuccessful){ create(:notification_type, name: 'pending_backer_project_unsuccessful') }
  let(:project_visible){ create(:notification_type, name: 'project_visible') }
  let(:project_rejected){ create(:notification_type, name: 'project_rejected') }
  let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:project) { create(:project, goal: 3000) }

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
      ProjectObserver.any_instance.should_receive(:after_create).and_call_original
      ::Configuration[:facebook_url] = 'http://facebook.com'
      ::Configuration[:blog_url] = 'http://blog.com'
      ::Configuration[:company_name] = 'Catarse'
      ::Configuration[:email_projects] = 'foo@foo.com'
      user
      project
    end
    let(:user) { create(:user, email: ::Configuration[:email_projects])}

    it "should create notification for catarse admin" do
      Notification.where(user_id: user.id, notification_type_id: new_draft_project.id, project_id: project.id).first.should_not be_nil
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, notification_type_id: project_received.id, project_id: project.id).first.should_not be_nil
    end
  end

  describe "before_save" do
    let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft')}
    context "when project is approved" do
      before do
        project.should_receive(:download_video_thumbnail).never
        project.should_receive(:update_video_embed_url).never
      end

      it "should call create_notification and do not call download_video_thumbnail" do
        Notification.should_receive(:create_notification_once).with(:project_visible, project.user, {project_id: project.id}, {project: project})
        project.approve
      end
    end

    context "when video_url changes" do
      before do
        project.should_receive(:download_video_thumbnail)
        project.should_receive(:update_video_embed_url)
        Notification.should_receive(:create_notification).never
        Notification.should_receive(:create_notification_once).never
      end

      it "should call download_video_thumbnail and do not call create_notification" do
        project.video_url = 'http://vimeo.com/66698435'
        project.save!
      end
    end
  end

  describe "#notify_owner_that_project_is_waiting_funds" do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user, goal: 100, online_days: -2, state: 'online') }

    before do
      create(:backer, project: project, value: 200, state: 'confirmed')
      Notification.should_receive(:create_notification_once).with(:project_in_wainting_funds, project.user, {project_id: project.id}, {project: project})
    end

    it("should notify the project owner"){ project.finish }
  end

  describe "sync with mailchimp" do
    before do
      Configuration[:mailchimp_successful_projects_list] = 'OwnerListId'
      Configuration[:mailchimp_failed_projects_list] = 'UnsuccesfulListId'
    end

    let(:user) { create(:user) }
    let(:project) { create(:project, online_days: -7, goal: 10, state: 'online', user: user) }

    context 'when project is successful' do
      before do
        create(:backer, value: 15, state: 'confirmed', project: project)
        project.update_attributes state: 'waiting_funds'
      end

      it 'subscribe project owner to successful projects mailchimp list' do
        CatarseMailchimp::API.should_receive(:subscribe).with({ EMAIL: user.email, FNAME: user.name,
          CITY: user.address_city, STATE: user.address_state }, 'OwnerListId')
      end

      after { project.finish }
    end

    context 'when project is unsuccesful' do
      it 'subscribe project owner to failed projects mailchimp list' do
        CatarseMailchimp::API.should_receive(:subscribe).with({ EMAIL: user.email, FNAME: user.name,
          CITY: user.address_city, STATE: user.address_state }, 'UnsuccesfulListId')
      end

      after { project.finish }
    end
  end

  describe "notify_backers" do

    context "when project is successful" do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }
      let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 30, project: project) }

      before do
        backer
        project.update_attributes state: 'waiting_funds'
        Notification.should_receive(:create_notification_once).at_least(:once)
        backer.save!
        project.finish!
      end
      it("should notify the project backers"){ subject }
    end

    context "when project is unsuccessful" do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }
      let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 20) }
      before do
        backer
        project.update_attributes state: 'waiting_funds'
        Notification.should_receive(:create_notification_once).at_least(:once)
        backer.save!
        project.finish!
      end
      it("should notify the project backers and owner"){ subject }
    end

    context "when project is unsuccessful with pending backers" do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }

      before do
        create(:backer, project: project, key: 'ABC1', payment_method: 'ABC', payment_token: 'ABC', value: 20, state: 'confirmed')
        create(:backer, project: project, key: 'ABC2', payment_method: 'ABC', payment_token: 'ABC', value: 20)
        project.update_attributes state: 'waiting_funds'
      end

      before do
        Notification.should_receive(:create_notification_once).at_least(3)
        project.finish!
      end
      it("should notify the project backers and owner"){ subject }
    end

  end

  describe '#notify_owner_that_project_is_successful' do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }

    before do
      ::Configuration[:facebook_url] = 'http://facebook.com/foo'
      ::Configuration[:blog_url] = 'http://blog.com/foo'
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      project_success
      project.finish
    end

    it "should create notification for project owner" do
      Notification.where(user_id: project.user.id, notification_type_id: project_success.id, project_id: project.id).first.should_not be_nil
    end
  end

  describe "#notify_owner_that_project_is_rejected" do
    let(:project){ create(:project, state: 'draft') }
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

  describe "#notify_admin_that_project_reached_deadline" do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }
    let(:user) { create(:user, email: 'foo@foo.com')}
    before do
      ::Configuration[:email_payments] = 'foo@foo.com'
      ::Configuration[:email_system] = 'foo2@foo.com'
      user
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      adm_project_deadline
      Project.finish_projects!
    end

    it "should create notification for admin" do
      Notification.where(user_id: user.id, notification_type_id: adm_project_deadline.id, project_id: project.id).first.should_not be_nil
    end

  end

end
