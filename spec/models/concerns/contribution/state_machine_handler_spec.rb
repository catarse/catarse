require 'spec_helper'

describe Contribution::StateMachineHandler do
  describe 'state_machine' do
    let(:contribution) { create(:contribution, state: initial_state) }
    let(:initial_state){ 'pending' }

    describe 'initial state' do
      let(:contribution) { Contribution.new }
      it('should be pending') { contribution.pending?.should be_true }
    end

    describe '#pendent' do
      before { contribution.pendent }
      context 'when in confirmed state' do
        let(:initial_state){ 'confirmed' }
        it("should switch to pending state"){ contribution.pending?.should be_true}
      end
    end

    describe '#confirm' do
      before { contribution.confirm }
      it("should switch to confirmed state") { contribution.confirmed?.should be_true }
    end

    describe "#push_to_trash" do
      before { contribution.push_to_trash }
      it("switch to deleted state") { contribution.deleted?.should be_true }
    end

    describe '#waiting' do
      before { contribution.waiting }
      context "when in peding state" do
        it("should switch to waiting_confirmation state") { contribution.waiting_confirmation?.should be_true }
      end
      context 'when in confirmed state' do
        let(:initial_state){ 'confirmed' }
        it("should not switch to waiting_confirmation state") { contribution.waiting_confirmation?.should be_false }
      end
    end

    describe '#cancel' do
      before { contribution.cancel }
      it("should switch to canceled state") { contribution.canceled?.should be_true }
    end

    describe '#request_refund' do
      let(:credits){ contribution.value }
      let(:initial_state){ 'confirmed' }
      let(:contribution_is_credits) { false }
      before do
        ContributionObserver.any_instance.stub(:notify_backoffice)
        contribution.update_attributes({ credits: contribution_is_credits })
        contribution.user.stub(:credits).and_return(credits)
        contribution.request_refund
      end

      subject { contribution.requested_refund? }

      context 'when contribution is confirmed' do
        it('should switch to requested_refund state') { should be_true }
      end

      context 'when contribution is credits' do
        let(:contribution_is_credits) { true }
        it('should not switch to requested_refund state') { should be_false }
      end

      context 'when contribution is not confirmed' do
        let(:initial_state){ 'pending' }
        it('should not switch to requested_refund state') { should be_false }
      end

      context 'when contribution value is above user credits' do
        let(:credits){ contribution.value - 1 }
        it('should not switch to requested_refund state') { should be_false }
      end
    end

    describe '#refund' do
      before do
        contribution.refund
      end

      context 'when contribution is confirmed' do
        let(:initial_state){ 'confirmed' }
        it('should switch to refunded state') { contribution.refunded?.should be_true }
      end

      context 'when contribution is requested refund' do
        let(:initial_state){ 'requested_refund' }
        it('should switch to refunded state') { contribution.refunded?.should be_true }
      end

      context 'when contribution is pending' do
        it('should not switch to refunded state') { contribution.refunded?.should be_false }
      end
    end

    describe "#hide" do
      before do
        contribution.should_receive(:notify_to_contributor).with(:refunded_and_canceled)
        contribution.hide
      end

      context "when contribution is confirmed" do
        let(:initial_state) { 'confirmed' }
        it('should switch to refund_and_canceled state') { contribution.refunded_and_canceled?.should be_true }
      end

      context "when contribution is pending" do
        let(:initial_state) { 'pending' }
        it('should switch to refund_and_canceled state') { contribution.refunded_and_canceled?.should be_true }
      end
    end
  end
end
