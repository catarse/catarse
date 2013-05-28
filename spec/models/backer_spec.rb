require 'spec_helper'

describe Backer do
  let(:user){ create(:user) }
  let(:project){ create(:project, state: 'failed') }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'successful') }
  let(:unfinished_project_backer){ create(:backer, state: 'confirmed', user: user, project: unfinished_project) }
  let(:sucessful_project_backer){ create(:backer, state: 'confirmed', user: user, project: successful_project) }
  let(:not_confirmed_backer){ create(:backer, user: user, project: unfinished_project) }
  let(:older_than_180_days_backer){ create(:backer, created_at: (Date.today - 181.days), state: 'confirmed', user: user, project: unfinished_project) }
  let(:valid_refund){ create(:backer, state: 'confirmed', user: user, project: project) }

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

    it "should have reward from the same project only" do
      backer = build(:backer)
      project1 = create(:project)
      project2 = create(:project)
      backer.project = project1
      reward = create(:reward, project: project2)
      backer.should be_valid
      backer.reward = reward
      backer.should_not be_valid
    end

    it "should have a value at least equal to reward's minimum value" do
      project = create(:project)
      reward = create(:reward, minimum_value: 500, project: project)
      backer = build(:backer, reward: reward, project: project)
      backer.value = 499.99
      backer.should_not be_valid
      backer.value = 500.00
      backer.should be_valid
      backer.value = 500.01
      backer.should be_valid
    end

    it "should not be able to back if reward's maximum backers' been reached (and maximum backers > 0)" do
      project = create(:project)
      reward1 = create(:reward, maximum_backers: nil, project: project)
      reward2 = create(:reward, maximum_backers: 1, project: project)
      reward3 = create(:reward, maximum_backers: 2, project: project)
      backer = build(:backer, state: 'confirmed', reward: reward1, project: project)
      backer.should be_valid
      backer.save
      backer = build(:backer, state: 'confirmed', reward: reward1, project: project)
      backer.should be_valid
      backer.save
      backer = build(:backer, state: 'confirmed', reward: reward2, project: project)
      backer.should be_valid
      backer.save
      backer = build(:backer, state: 'confirmed', reward: reward2, project: project)
      backer.should_not be_valid
      backer = build(:backer, state: 'confirmed', reward: reward3, project: project)
      backer.should be_valid
      backer.save
      backer = build(:backer, state: 'confirmed', reward: reward3, project: project)
      backer.should be_valid
      backer.save
      backer = build(:backer, state: 'confirmed', reward: reward3, project: project)
      backer.should_not be_valid
    end
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
    let(:waiting_confirmation_backer) { create(:backer, state: 'waiting_confirmation', created_at: 3.weekdays_ago) }
    let(:waiting_confirmation_backer_1) { create(:backer, state: 'waiting_confirmation', created_at: 6.weekdays_ago) }
    let(:waiting_confirmation_backer_2) { create(:backer, state: 'waiting_confirmation', created_at: 4.weekdays_ago) }

    subject { Backer.can_cancel}

    context "when backer is in time to wait the confirmation" do
      before { waiting_confirmation_backer }
      it { should have(0).item }
    end

    context "when we have backers that is passed the confirmation time" do
      before do
        waiting_confirmation_backer
        waiting_confirmation_backer_1
        waiting_confirmation_backer_2
      end

      it { should have(2).itens }
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
    before{ valid_refund }

    subject{ Backer.can_refund.all }

    context "when project is successful" do
      before{ sucessful_project_backer }
      it{ should == [valid_refund] }
    end

    context "when project is not finished" do
      before{ unfinished_project }
      it{ should == [valid_refund] }
    end

    context "when backer is not confirmed" do
      before{ not_confirmed_backer }
      it{ should == [valid_refund] }
    end

    context "when backer is older than 180 days" do
      before{ older_than_180_days_backer } 
      it{ should == [valid_refund] }
    end
  end

  describe "#can_refund?" do
    subject{ backer.can_refund? }

    context "when project is successful" do
      let(:backer){ sucessful_project_backer }
      it{ should be_false }
    end

    context "when project is not finished" do
      let(:backer){ unfinished_project_backer }
      it{ should be_false }
    end

    context "when backer is older than 180 days" do
      let(:backer){ older_than_180_days_backer }
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
      end
      it{ should == 0 }
    end

    context "when backs are confirmed and not done with credits" do
      before do
        create(:backer, state: 'confirmed', user: user, project: project)
      end
      it{ should == 10 }
    end

    context "when backs are done with credits" do
      before do
        create(:backer, credits: true, state: 'confirmed', user: user, project: project)
      end
      it{ should == 0 }
    end

    context "when backs are not confirmed" do
      before do
        create(:backer, user: user, project: project, state: 'pending')
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
