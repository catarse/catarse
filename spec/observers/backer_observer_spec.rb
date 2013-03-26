require 'spec_helper'

describe BackerObserver do
  let(:project_owner_backer_confirmed){ FactoryGirl.create(:notification_type, :name => 'project_owner_backer_confirmed') }
  let(:confirm_backer){ FactoryGirl.create(:notification_type, :name => 'confirm_backer') }
  let(:project_success){ FactoryGirl.create(:notification_type, :name => 'project_success') }
  let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => nil) }
  subject{ backer }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    confirm_backer # It should create the NotificationType before creating the Backer
    project_success
    project_owner_backer_confirmed
  end

  describe "after_create" do
    before{ Kernel.stubs(:rand).returns(1) }
    its(:key){ should == Digest::MD5.new.update("#{backer.id}###{backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end
  
  describe "before_save" do

    context "when payment_choice is updated to BoletoBancario" do
      let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now) }
      before do
        Notification.expects(:create_notification).with(:payment_slip, backer.user, :backer => backer, :project_name => backer.project.name)
        backer.payment_choice = 'BoletoBancario'
        backer.save!
      end
      it("should notify the backer"){ subject }
    end

    context "when project reached the goal" do
      let(:project){ FactoryGirl.create(:project, :can_finish => true, :successful => false, :goal => 20, :finished => false) }
      let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :value => 20) }
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
      let(:project){ FactoryGirl.create(:project, :successful => true, :finished => false) }
      let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now, :project => project) }
      before do
        Notification.expects(:create_notification).never
        backer.save!
      end
      it("should not send project_successful notification again"){ subject }
    end

    context "when is not yet confirmed" do
      context 'notify the backer' do
        before do
          Notification.expects(:create_notification).at_least_once.with(:confirm_backer, 
            backer.user, :backer => backer,  :project_name => backer.project.name)
        end
        
        it("should send confirm_backer notification"){ subject }
        its(:confirmed_at) { should_not be_nil }
      end
      
      context 'notify project owner about this backer' do
        before do
          Notification.expects(:create_notification).at_least_once.with(:project_owner_backer_confirmed, 
            backer.project.user, :backer => backer, :project_name => backer.project.name)
        end

        it("should send project_owner_backer_confirmed notification"){ subject }
        its(:confirmed_at) { should_not be_nil }        
      end
    end        

    context "when is already confirmed" do
      let(:backer){ FactoryGirl.create(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => Time.now) }
      before do
        Notification.expects(:create_notification).never
      end

      it("should not send confirm_backer notification again"){ subject }
    end
  end
end
