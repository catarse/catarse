require 'spec_helper'

describe ProjectObserver do
  let(:confirm_backer){ Factory(:notification_type, :name => 'confirm_backer') }
  let(:project_success){ Factory(:notification_type, :name => 'project_success') }
  let(:backer_successful){ Factory(:notification_type, :name => 'backer_project_successful') }
  let(:backer_unsuccessful){ Factory(:notification_type, :name => 'backer_project_unsuccessful') }
  let(:project_visible){ Factory(:notification_type, :name => 'project_visible') }
  let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => nil) }
  subject{ backer }

  before do
    Notification.unstub(:create_notification)
    confirm_backer
    project_success
    backer_successful
    backer_unsuccessful
  end

  describe "after_create" do
    before{ Kernel.stubs(:rand).returns(1) }
    its(:key){ should == Digest::MD5.new.update("#{backer.id}###{backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end

  describe "before_save" do
    let(:project){ Factory(:project, :visible => false )}
    before do
      Notification.expects(:create_notification).with(:project_visible, project.user, project)
      project.visible = true
      project.save!
    end
  end

  describe "notify_backers" do

   context "when project is successful" do
      let(:project){ Factory(:project, :can_finish => true, :visible => true, :successful => false, :goal => 30, :finished => false, :expires_at => (Time.now - 1.day)) }
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 30, :project => project) }

      before do
        Notification.expects(:create_notification).at_least_once
        backer.save!
        project.finish!
      end
      it("should notify the project backers"){ subject }
    end

    context "when project is unsuccessful" do
      let(:project){ Factory(:project, :can_finish => true, :visible => true, :successful => false, :goal => 30, :finished => false, :expires_at => (Time.now - 1.day)) }
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 20) }
      before do
        Notification.expects(:create_notification).at_least_once
        backer.save!
        project.finish!
      end
      it("should notify the project backers and owner"){ subject }
    end

  end
end
