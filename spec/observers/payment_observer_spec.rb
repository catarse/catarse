require 'rails_helper'

RSpec.describe ContributionObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  subject{ contribution }

  describe "after_create" do
    before{ allow(Kernel).to receive(:rand).and_return(1) }
    its(:key){ should == Digest::MD5.new.update("#{contribution.id}###{contribution.created_at}##1").to_s }

    context "after create the contribution" do
      let(:contribution) { build(:contribution) }

      before do
        expect(PendingContributionWorker).to receive(:perform_at)
      end

      it "should call perform at in pending contribution worker" do
        contribution.save
      end
    end
  end

  describe "after_save" do
    context "when payment_choice is updated to BoletoBancario" do
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now) }
      before do
        expect(ContributionNotification).to receive(:notify_once).with(:payment_slip, contribution.user, contribution, {})
        contribution.payment_choice = 'BoletoBancario'
        contribution.save!
      end
      it("should notify the contribution"){ subject }
    end
  end

  describe "before_save" do
    context "when is not yet confirmed" do
      context 'notify the contribution' do
        subject { build(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }

        before do
          expect(ContributionNotification).
            to receive(:notify).
            at_least(:once).
            with(:confirm_contribution, subject.user, subject, {})
        end

        it("should send confirm_contribution notification"){ subject.save }
        its(:confirmed_at) do
          subject.save
          should_not be_nil
        end
      end
    end

    context "when is already confirmed" do
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now) }
      before do
        expect(ContributionNotification).to receive(:notify).never
      end

      it("should not send confirm_contribution notification again"){ subject }
    end
  end

  describe "#from_requested_refund_to_refunded" do
    context "when contribution is made with credit card" do
      before do
        contribution.update_attributes(payment_choice: 'CartaoDeCredito', payment_method: 'MoIP')
        contribution.notify_observers :from_requested_refund_to_refunded
      end

      it "should notify contributor about refund" do
        expect(ContributionNotification.where(template_name: 'refund_completed_credit_card', user_id: contribution.user.id).count).to eq 1
      end
    end

    context "when contribution is made with boleto" do
      before do
        contribution.update_attributes(payment_choice: 'BoletoBancario', payment_method: 'MoIP')
        contribution.notify_observers :from_requested_refund_to_refunded
      end

      it "should notify contributor about refund" do
        expect(ContributionNotification.where(template_name: 'refund_completed_slip', user_id: contribution.user.id).count).to eq 1
      end
    end
  end

  describe '#from_confirmed_to_requested_refund' do
    let(:admin){ create(:user) }
    before do
      CatarseSettings[:email_payments] = admin.email
      allow(contribution).to receive(:can_do_refund?).and_return(true)
    end

    context "when contribution is made with credit card" do
      before do
        contribution.update_attributes(payment_choice: 'CartaoDeCredito', payment_method: 'MoIP')
        expect(contribution).to receive(:direct_refund)
        contribution.notify_observers :from_confirmed_to_requested_refund
      end

      it "should notify admin upon refund request" do
        expect(ContributionNotification.where(template_name: 'refund_request', user_id: admin.id, from_email: contribution.user.email, from_name: contribution.user.name).count).to eq 1
      end
    end

    context "when contribution is made with boleto" do
      context "via MoIP" do
        before do
          contribution.update_attributes(payment_choice: 'BoletoBancario', payment_method: 'MoIP')
          expect(contribution).to receive(:direct_refund)
          contribution.notify_observers :from_confirmed_to_requested_refund
        end

        it "should notify admin upon refund request" do
          expect(ContributionNotification.where(template_name: 'refund_request', user_id: admin.id, from_email: contribution.user.email, from_name: contribution.user.name).count).to eq 1
        end
      end

      context "via PagarMe" do
        before do
          contribution.update_attributes(payment_choice: 'BoletoBancario', payment_method: 'Pagarme')
          expect(contribution).to receive(:direct_refund)
          contribution.notify_observers :from_confirmed_to_requested_refund
        end

        it "should notify admin and contributor upon refund request" do
          expect(ContributionNotification.where(template_name: 'refund_request', user_id: admin.id, from_email: contribution.user.email, from_name: contribution.user.name).count).to eq 1
          expect(ContributionNotification.where(template_name: 'requested_refund_slip', user_id: contribution.user.id).count).to eq 0
        end
      end
    end
  end

  describe '#from_confirmed_to_canceled' do
    before do
      CatarseSettings[:email_payments] = 'finan@c.me'
    end

    let(:user_finan) { create(:user, email: 'finan@c.me') }

    context "when contribution is confirmed and change to canceled" do
      before do
        contribution.confirm

        expect(ContributionNotification).to receive(:notify_once).with(
          :contribution_canceled_after_confirmed,
          user_finan,
          contribution,
          {}
        )

        expect(ContributionNotification).to receive(:notify_once).with(
          :contribution_canceled,
          contribution.user,
          contribution,
          {}
        )
      end

      it { contribution.cancel }
    end

    context "when contribution is made with Boleto and canceled" do
      before do
        contribution.update_attributes payment_choice: 'BoletoBancario'
        contribution.confirm

        expect(ContributionNotification).not_to receive(:notify).with(:contribution_canceled_after_confirmed, anything)

        expect(ContributionNotification).to receive(:notify_once).with(
          :contribution_canceled_slip,
          contribution.user,
          contribution,
          {}
        )
      end

      it { contribution.cancel }
    end

    context "when contribution change to confirmed" do
      before do
        expect(ContributionNotification).not_to receive(:notify).with(:contribution_canceled_after_confirmed, anything)
      end

      it { contribution.confirm }
    end
  end
end
