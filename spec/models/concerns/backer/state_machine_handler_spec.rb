require 'spec_helper'

describe Backer::StateMachineHandler do
  describe 'state_machine' do
    let(:backer) { create(:backer, state: initial_state) }
    let(:initial_state){ 'pending' }

    describe 'initial state' do
      let(:backer) { Backer.new }
      it('should be pending') { backer.pending?.should be_true }
    end

    describe '#pendent' do
      before { backer.pendent }
      context 'when in confirmed state' do
        let(:initial_state){ 'confirmed' }
        it("should switch to pending state"){ backer.pending?.should be_true}
      end
    end

    describe '#confirm' do
      before { backer.confirm }
      it("should switch to confirmed state") { backer.confirmed?.should be_true }
    end

    describe "#push_to_trash" do
      before { backer.push_to_trash }
      it("switch to deleted state") { backer.deleted?.should be_true }
    end

    describe '#waiting' do
      before { backer.waiting }
      context "when in peding state" do
        it("should switch to waiting_confirmation state") { backer.waiting_confirmation?.should be_true }
      end
      context 'when in confirmed state' do
        let(:initial_state){ 'confirmed' }
        it("should not switch to waiting_confirmation state") { backer.waiting_confirmation?.should be_false }
      end
    end

    describe '#cancel' do
      before { backer.cancel }
      it("should switch to canceled state") { backer.canceled?.should be_true }
    end

    describe '#request_refund' do
      let(:credits){ backer.value }
      let(:initial_state){ 'confirmed' }
      let(:backer_is_credits) { false }
      before do
        BackerObserver.any_instance.stub(:notify_backoffice)
        backer.update_attributes({ credits: backer_is_credits })
        backer.user.stub(:credits).and_return(credits)
        backer.request_refund
      end

      subject { backer.requested_refund? }

      context 'when backer is confirmed' do
        it('should switch to requested_refund state') { should be_true }
      end

      context 'when backer is credits' do
        let(:backer_is_credits) { true }
        it('should not switch to requested_refund state') { should be_false }
      end

      context 'when backer is not confirmed' do
        let(:initial_state){ 'pending' }
        it('should not switch to requested_refund state') { should be_false }
      end

      context 'when backer value is above user credits' do
        let(:credits){ backer.value - 1 }
        it('should not switch to requested_refund state') { should be_false }
      end
    end

    describe '#refund' do
      before do
        backer.refund
      end

      context 'when backer is confirmed' do
        let(:initial_state){ 'confirmed' }
        it('should switch to refunded state') { backer.refunded?.should be_true }
      end

      context 'when backer is requested refund' do
        let(:initial_state){ 'requested_refund' }
        it('should switch to refunded state') { backer.refunded?.should be_true }
      end

      context 'when backer is pending' do
        it('should not switch to refunded state') { backer.refunded?.should be_false }
      end
    end
  end
end
