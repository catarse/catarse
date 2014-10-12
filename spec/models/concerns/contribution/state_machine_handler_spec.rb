require 'rails_helper'

RSpec.describe Contribution::StateMachineHandler, type: :model do
  describe 'state_machine' do
    let(:contribution) { create(:contribution, state: initial_state) }
    let(:initial_state){ 'pending' }

    describe 'initial state' do
      let(:contribution) { Contribution.new }
      it('should be pending') { expect(contribution.pending?).to eq(true) }
    end

    describe '#pendent' do
      before { contribution.pendent }
      context 'when in confirmed state' do
        let(:initial_state){ 'confirmed' }
        it("should switch to pending state"){ expect(contribution.pending?).to eq(true)}
      end
    end

    describe '#invalid' do
      before { contribution.invalid}
      context 'when in confirmed state' do
        it("should switch to invalid payment state"){ expect(contribution.invalid_payment?).to eq(true)}
        it("should fill invalid_payment_at") { expect(contribution.invalid_payment_at).not_to be_nil }
      end
    end

    describe '#confirm' do
      before { contribution.confirm }
      it("should switch to confirmed state") { expect(contribution.confirmed?).to eq(true) }
      it("should fill confirmed_at") { expect(contribution.confirmed_at).not_to be_nil }
    end

    describe "#push_to_trash" do
      before { contribution.push_to_trash }
      it("switch to deleted state") { expect(contribution.deleted?).to eq(true) }
      it("should fill deleted_at") { expect(contribution.deleted_at).not_to be_nil }
    end

    describe '#waiting' do
      before { contribution.waiting }
      context "when in peding state" do
        it("should switch to waiting_confirmation state") { expect(contribution.waiting_confirmation?).to eq(true) }
        it("should fill waiting_confirmation_at") { expect(contribution.waiting_confirmation_at).not_to be_nil }
      end
      context 'when in confirmed state' do
        let(:initial_state){ 'confirmed' }
        it("should not switch to waiting_confirmation state") { expect(contribution.waiting_confirmation?).to eq(false) }
      end
    end

    describe '#cancel' do
      before { contribution.cancel }
      it("should switch to canceled state") { expect(contribution.canceled?).to eq(true) }
      it("should fill canceled_at") { expect(contribution.canceled_at).not_to be_nil }
    end

    describe '#request_refund' do
      let(:credits){ contribution.value }
      let(:initial_state){ 'confirmed' }
      let(:contribution_is_credits) { false }
      before do
        contribution.update_attributes({ credits: contribution_is_credits })
        allow(contribution.user).to receive(:credits).and_return(credits)
        contribution.request_refund
      end

      subject { contribution.requested_refund? }

      context 'when contribution is confirmed' do
        it('should switch to requested_refund state') { is_expected.to eq(true) }
        it("should fill requested_refund_at") { expect(contribution.requested_refund_at).not_to be_nil }
      end

      context 'when contribution is credits' do
        let(:contribution_is_credits) { true }
        it('should not switch to requested_refund state') { is_expected.to eq(false) }
      end

      context 'when contribution is not confirmed' do
        let(:initial_state){ 'pending' }
        it('should not switch to requested_refund state') { is_expected.to eq(false) }
      end

      context 'when contribution value is above user credits' do
        let(:credits){ contribution.value - 1 }
        it('should not switch to requested_refund state') { is_expected.to eq(false) }
      end
    end

    describe '#refund' do
      before do
        contribution.refund
      end

      context 'when contribution is confirmed' do
        let(:initial_state){ 'confirmed' }
        it('should switch to refunded state') { expect(contribution.refunded?).to eq(true) }
        it("should fill refunded_at") { expect(contribution.refunded_at).not_to be_nil }
      end

      context 'when contribution is requested refund' do
        let(:initial_state){ 'requested_refund' }
        it('should switch to refunded state') { expect(contribution.refunded?).to eq(true) }
      end

      context 'when contribution is pending' do
        it('should not switch to refunded state') { expect(contribution.refunded?).to eq(false) }
      end
    end

    describe "#hide" do
      before do
        expect(contribution).to receive(:notify_to_contributor).with(:refunded_and_canceled)
        contribution.hide
      end

      context "when contribution is confirmed" do
        let(:initial_state) { 'confirmed' }
        it('should switch to refund_and_canceled state') { expect(contribution.refunded_and_canceled?).to eq(true) }
        it("should fill refunded_and_canceled_at") { expect(contribution.refunded_and_canceled_at).not_to be_nil }
      end

      context "when contribution is pending" do
        let(:initial_state) { 'pending' }
        it('should switch to refund_and_canceled state') { expect(contribution.refunded_and_canceled?).to eq(true) }
      end
    end
  end
end
