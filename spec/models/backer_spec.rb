require 'spec_helper'

describe Backer do
  let(:user){ create(:user) }
  let(:failed_project){ create(:project, state: 'online') }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:unfinished_project_backer){ create(:backer, state: 'confirmed', user: user, project: unfinished_project) }
  let(:sucessful_project_backer){ create(:backer, state: 'confirmed', user: user, project: successful_project) }
  let(:not_confirmed_backer){ create(:backer, user: user, project: unfinished_project) }
  let(:valid_refund){ create(:backer, state: 'confirmed', user: user, project: failed_project) }


  describe "Associations" do
    it { should have_many(:payment_notifications) }
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should belong_to(:reward) }
  end

  describe "Validations" do
    it{ should validate_presence_of(:project) }
    it{ should validate_presence_of(:user) }
    it{ should validate_presence_of(:value) }
    it{ should_not allow_value(9.99).for(:value) }
    it{ should allow_value(10).for(:value) }
    it{ should allow_value(20).for(:value) }
  end

  describe ".between_values" do
    let(:start_at) { 10 }
    let(:ends_at) { 20 }
    subject { Backer.between_values(start_at, ends_at) }
    before do
      create(:backer, value: 10)
      create(:backer, value: 15)
      create(:backer, value: 20)
      create(:backer, value: 21)
    end
    it { should have(3).itens }
  end

  describe ".not_deleted" do
    before do
      2.times { create(:backer, state: 'pending') }
      3.times { create(:backer, state: 'confirmed') }
      5.times { create(:backer, state: 'deleted') }
    end

    subject { Backer.not_deleted }

    it("should return only the backers that is not deleted") do
      subject.should have(5).itens
    end
  end

  describe ".by_state" do
    before do
      2.times { create(:backer, state: 'confirmed') }
      create(:backer, state: 'waiting_confirmation')
      create(:backer, state: 'canceled')
    end

    it "should return all confirmed backers" do
      Backer.by_state('confirmed').should have(2).itens
    end

    it "should return all waiting confirmation backers" do
      Backer.by_state('waiting_confirmation').should have(1).itens
    end

    it "should return all canceled backers" do
      Backer.by_state('canceled').should have(1).itens
    end
  end

  describe ".can_cancel" do
    subject { Backer.can_cancel}

    context "when backer is in time to wait the confirmation" do
      before do
        create(:backer, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
      end
      it { should have(0).item }
    end

    context "when backer is by bank transfer and is passed the confirmation time" do
      before do
        create(:backer, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 2.weekdays_ago)
        create(:backer, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 0.weekdays_ago)
      end
      it { should have(1).item }
    end

    context "when we have backers that is passed the confirmation time" do
      before do
        create(:backer, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
        create(:backer, state: 'waiting_confirmation', created_at: 6.weekdays_ago)
      end
      it { should have(1).itens }
    end
  end

  describe "#project_should_be_online" do
    subject{ backer }
    context "when project is draft" do
      let(:backer){ build(:backer, project: create(:project, state: 'draft')) }
      it{ should_not be_valid }
    end
    context "when project is waiting_funds" do
      let(:backer){ build(:backer, project: create(:project, state: 'waiting_funds')) }
      it{ should_not be_valid }
    end
    context "when project is successful" do
      let(:backer){ build(:backer, project: create(:project, state: 'successful')) }
      it{ should_not be_valid }
    end
    context "when project is online" do
      let(:backer){ build(:backer, project: unfinished_project) }
      it{ should be_valid }
    end
    context "when project is failed" do
      let(:backer){ build(:backer, project: create(:project, state: 'failed')) }
      it{ should_not be_valid }
    end
  end

  describe "#should_not_back_if_maximum_backers_been_reached" do
    let(:reward){ create(:reward, maximum_backers: 1) }
    let(:backer){ build(:backer, reward: reward, project: reward.project) }
    subject{ backer }
    context "when backers count is lower than maximum_backers" do
      it{ should be_valid }
    end
    context "when backers count is equal than maximum_backers" do
      before{ create(:backer, reward: reward, project: reward.project, state: 'confirmed') }
      it{ should_not be_valid }
    end
  end

  describe "#reward_must_be_from_project" do
    let(:backer){ build(:backer, reward: reward, project: unfinished_project) }
    subject{ backer }
    context "when reward is from the same project" do
      let(:reward){ create(:reward, project: unfinished_project) }
      it{ should be_valid }
    end
    context "when reward is not from the same project" do
      let(:reward){ create(:reward) }
      it{ should_not be_valid }
    end
  end

  describe "#value_must_be_at_least_rewards_value" do
    let(:reward){ create(:reward, minimum_value: 500) }
    let(:backer){ build(:backer, reward: reward, project: reward.project, value: value) }
    subject{ backer }
    context "when value is lower than reward minimum value" do
      let(:value){ 499.99 }
      it{ should_not be_valid }
    end
    context "when value is equal than reward minimum value" do
      let(:value){ 500.00 }
      it{ should be_valid }
    end
    context "when value is greater than reward minimum value" do
      let(:value){ 500.01 }
      it{ should be_valid }
    end
  end

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
      before do
        BackerObserver.any_instance.stub(:notify_backoffice)
        backer.request_refund
      end

      context 'when backer is confirmed' do
        let(:initial_state){ 'confirmed' }
        it('should switch to requested_refund state') { backer.requested_refund?.should be_true }
      end

      context 'when backer is not confirmed' do
        it('should not switch to requested_refund state') { backer.requested_refund?.should be_false }
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


  describe '.pending_to_refund' do
    subject { Backer.pending_to_refund }

    context 'when backer as requested refund' do
      before do
        create(:backer, state: 'confirmed')
        create(:backer, state: 'refunded')
        create(:backer, state: 'requested_refund')
      end

      it { should have(1).item }
    end
  end

  describe '.in_time_to_confirm' do
    subject { Backer.in_time_to_confirm}

    context 'when we have backers in waiting confirmation' do
      before do
        create(:backer, state: 'waiting_confirmation')
        create(:backer, state: 'waiting_confirmation')
        create(:backer, state: 'pending')
      end

      it { should have(2).item }
    end
  end

  describe ".can_refund" do
    subject{ Backer.can_refund.all }
    before do
      valid_refund
      sucessful_project_backer
      unfinished_project
      not_confirmed_backer
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end
    it{ should == [valid_refund] }
  end

  describe "#can_refund?" do
    subject{ backer.can_refund? }
    before do
      valid_refund
      sucessful_project_backer
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end

    context "when project is successful" do
      let(:backer){ sucessful_project_backer }
      it{ should be_false }
    end

    context "when project is not finished" do
      let(:backer){ unfinished_project_backer }
      it{ should be_false }
    end

    context "when backer is not confirmed" do
      let(:backer){ not_confirmed_backer }
      it{ should be_false }
    end

    context "when it's a valid refund" do
      let(:backer){ valid_refund }
      it{ should be_true }
    end
  end

  describe "#credits" do
    subject{ user.credits.to_f }
    context "when backs are confirmed and not done with credits but project is successful" do
      before do
        create(:backer, state: 'confirmed', user: user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should == 0 }
    end

    context "when backs are confirmed and not done with credits" do
      before do
        create(:backer, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 10 }
    end

    context "when backs are done with credits" do
      before do
        create(:backer, credits: true, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end

    context "when backs are not confirmed" do
      before do
        create(:backer, user: user, project: failed_project, state: 'pending')
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end
  end

  describe "#display_value" do
    context "when the value has decimal places" do
      subject{ build(:backer, value: 99.99).display_value }
      it{ should == "R$ 100" }
    end

    context "when the value does not have decimal places" do
      subject{ build(:backer, value: 1).display_value }
      it{ should == "R$ 1" }
    end
  end
end
