require 'spec_helper'

describe BackerObserver do
  let(:project_owner_backer_confirmed){ create(:notification_type, name: 'project_owner_backer_confirmed') }
  let(:confirm_backer){ create(:notification_type, name: 'confirm_backer') }
  let(:project_success){ create(:notification_type, name: 'project_success') }
  let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  subject{ backer }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    confirm_backer # It should create the NotificationType before creating the Backer
    project_success
    project_owner_backer_confirmed
  end

  describe "after_create" do
    before{ Kernel.stub(:rand).and_return(1) }
    its(:key){ should == Digest::MD5.new.update("#{backer.id}###{backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end
  
  describe "before_save" do

    context "when we change backer data" do
      let(:user){ create(:user, {
        address_street: 'old', 
        address_number: 'old', 
        address_neighbourhood: 'old', 
        address_zip_code: 'old',
        address_city: 'old',
        address_state: 'old',
        phone_number: 'old',
        cpf: 'old'
      }) }
      subject{ user }
      before do
        create(:backer, {
          address_street: 'new', 
          address_number: 'new', 
          address_neighbourhood: 'new', 
          address_zip_code: 'new',
          address_city: 'new',
          address_state: 'new',
          address_phone_number: 'new',
          payer_document: 'new',
          user: user
        })
      end

      its(:address_street){ should == 'new' }
      its(:address_number){ should == 'new' }
      its(:address_neighbourhood){ should == 'new' }
      its(:address_zip_code){ should == 'new' }
      its(:address_city){ should == 'new' }
      its(:address_state){ should == 'new' }
      its(:phone_number){ should == 'new' }
      its(:cpf){ should == 'new' }
    end

    context "when payment_choice is updated to BoletoBancario" do
      let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now) }
      before do
        Notification.should_receive(:create_notification).with(:payment_slip, backer.user, backer: backer, project_name: backer.project.name)
        backer.payment_choice = 'BoletoBancario'
        backer.save!
      end
      it("should notify the backer"){ subject }
    end

    context "when project reached the goal" do
      let(:project){ create(:project, state: 'failed', goal: 20) }
      let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 20) }
      before do
        project_total = mock()
        project_total.stub(:pledged).and_return(20.0)
        project_total.stub(:total_backers).and_return(1)
        project.stub(:project_total).and_return(project_total)
        backer.project = project
        Notification.should_receive(:create_notification).with(:project_success, backer.project.user, project: backer.project)
        backer.save!
      end
      it("should notify the project owner"){ subject }
    end

    context "when project is already successful" do
      let(:project){ create(:project, state: 'online') }
      let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, project: project) }
      before do
        backer
        project.update_attributes state: 'successful'
        Notification.should_receive(:create_notification).never
        backer.save!
      end
      it("should not send project_successful notification again"){ subject }
    end

    context "when is not yet confirmed" do
      context 'notify the backer' do
        before do
          Notification.should_receive(:create_notification).at_least(:once).with(:confirm_backer, 
            backer.user, backer: backer,  project_name: backer.project.name)
        end
        
        it("should send confirm_backer notification"){ subject }
        its(:confirmed_at) { should_not be_nil }
      end
      
      context 'notify project owner about this backer' do
        before do
          Notification.should_receive(:create_notification).at_least(:once).with(:project_owner_backer_confirmed, 
            backer.project.user, backer: backer, project_name: backer.project.name)
        end

        it("should send project_owner_backer_confirmed notification"){ subject }
        its(:confirmed_at) { should_not be_nil }        
      end
    end        

    context "when is already confirmed" do
      let(:backer){ create(:backer, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now) }
      before do
        Notification.should_receive(:create_notification).never
      end

      it("should not send confirm_backer notification again"){ subject }
    end
  end

  describe '.notify_backoffice_about_canceled' do
    before do
      Configuration[:email_payments] = 'finan@c.me'
    end

    let(:backer) { create(:backer) }
    let(:user) { create(:user, email: 'finan@c.me') }

    context "when backer is confirmed and change to canceled" do
      before do
        backer.confirm
        Notification.should_receive(:create_notification_once).with(:backer_canceled_after_confirmed, user, {backer_id: backer.id}, backer: backer)
      end

      it { backer.cancel }
    end

    context "when backer change to confirmed" do
      before do
        Notification.should_not_receive(:create_notification).with(:backer_canceled_after_confirmed)
      end

      it { backer.confirm }
    end
  end
end
