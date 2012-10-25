require 'spec_helper'

describe BackerObserver do
  let(:confirm_backer){ Factory(:notification_type, :name => 'confirm_backer') }
  let(:project_success){ Factory(:notification_type, :name => 'project_success') }
  let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => nil) }
  subject{ backer }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    confirm_backer # It should create the NotificationType before creating the Backer
    project_success
  end

  describe "after_create" do
    before{ Kernel.stubs(:rand).returns(1) }
    its(:key){ should == Digest::MD5.new.update("#{backer.id}###{backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end

  describe "before_save" do

    context "when payment_choice is updated to BoletoBancario" do
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now) }
      before do
        Notification.expects(:create_notification).with(:payment_slip, backer.user, :backer => backer, :project_name => backer.project.name)
        backer.payment_choice = 'BoletoBancario'
        backer.save!
      end
      it("should notify the backer"){ subject }
    end

    context "when project becomes successful" do
      let(:project){ Factory(:project, :can_finish => true, :successful => false, :goal => 20, :finished => false) }
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 20) }
      before do
        project_total = mock()
        project_total.stubs(:pledged).returns(20.0)
        project_total.stubs(:total_backers).returns(1)
        project.stubs(:project_total).returns(project_total)
        backer.project = project
        Notification.expects(:create_notification).with(:project_success, backer.project.user, :project => backer.project)
        backer.save!
      end
      it("should notify the project owner"){ subject }
    end

    context "when project is already successful" do
      let(:project){ Factory(:project, :successful => true, :finished => false) }
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :project => project) }
      before do
        Notification.expects(:create_notification).never
        backer.save!
      end
      it("should not send project_successful notification again"){ subject }
    end

    context "when is not yet confirmed" do
      before do
        Notification.expects(:create_notification).with(:confirm_backer, backer.user, :backer => backer,  :project_name => backer.project.name)
      end
      it("should send confirm_backer notification"){ subject }
      its(:confirmed_at) { should_not be_nil }
    end

    context "when is already confirmed" do
      let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now) }
      before do
        Notification.expects(:create_notification).never
      end

      it("should not send confirm_backer notification again"){ subject }
    end
  end
end
