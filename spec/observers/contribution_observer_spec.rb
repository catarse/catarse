require 'spec_helper'

describe ContributionObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  subject{ contribution }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
  end

  describe "after_create" do
    before{ Kernel.stub(:rand).and_return(1) }
    its(:key){ should == Digest::MD5.new.update("#{contribution.id}###{contribution.created_at}##1").to_s }
  end

  describe "before_save" do
    context "when payment_choice is updated to BoletoBancario" do
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now) }
      before do
        Notification.should_receive(:notify_once).with(:payment_slip, contribution.user, {contribution_id: contribution.id}, contribution: contribution, project: contribution.project)
        contribution.payment_choice = 'BoletoBancario'
        contribution.save!
      end
      it("should notify the contribution"){ subject }
    end

    context "when project reached the goal" do
      let(:project){ create(:project, state: 'failed', goal: 20) }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 20) }
      before do
        project_total = mock()
        project_total.stub(:pledged).and_return(20.0)
        project_total.stub(:total_contributions).and_return(1)
        project.stub(:project_total).and_return(project_total)
        contribution.project = project
        Notification.should_receive(:notify).with(:project_success, contribution.project.user, project: contribution.project)
        contribution.save!
      end
      it("should notify the project owner"){ subject }
    end

    context "when project is already successful" do
      let(:project){ create(:project, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, project: project) }
      before do
        contribution
        project.update_attributes state: 'successful'
        Notification.should_receive(:notify).never
        contribution.save!
      end
      it("should not send project_successful notification again"){ subject }
    end

    context "when is not yet confirmed" do
      context 'notify the contribution' do
        before do
          Notification.should_receive(:notify).at_least(:once).with(:confirm_contribution,
            contribution.user, contribution: contribution,  project_name: contribution.project.name)
        end

        it("should send confirm_contribution notification"){ subject }
        its(:confirmed_at) { should_not be_nil }
      end
    end

    context "when is already confirmed" do
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now) }
      before do
        Notification.should_receive(:notify).never
      end

      it("should not send confirm_contribution notification again"){ subject }
    end
  end

  describe '#notify_backoffice_about_refund' do
    let(:admin){ create(:user) }
    before do
      Configuration[:email_payments] = admin.email
    end

    it "should notify admin upon refund request" do
      contribution.notify_observers :notify_backoffice_about_refund
      expect(Notification.where(template_name: 'refund_request', user_id: admin.id, origin_email: contribution.user.email, origin_name: contribution.user.name).count).to eq 1
    end
  end

  describe '#notify_backoffice_about_canceled' do
    before do
      Configuration[:email_payments] = 'finan@c.me'
    end

    let(:user) { create(:user, email: 'finan@c.me') }

    context "when contribution is confirmed and change to canceled" do
      before do
        contribution.confirm
        Notification.should_receive(:notify_once).with(:contribution_canceled_after_confirmed, user, {contribution_id: contribution.id}, contribution: contribution)
      end

      it { contribution.cancel }
    end

    context "when contribution change to confirmed" do
      before do
        Notification.should_not_receive(:notify).with(:contribution_canceled_after_confirmed)
      end

      it { contribution.confirm }
    end
  end
end
