require 'spec_helper'

describe Backer do
  let(:user){ FactoryGirl.create(:user) }
  let(:project){ FactoryGirl.create(:project, state: 'failed') }
  let(:unfinished_project){ FactoryGirl.create(:project, state: 'online') }
  let(:successful_project){ FactoryGirl.create(:project, state: 'successful') }
  let(:unfinished_project_backer){ FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => unfinished_project) }
  let(:sucessful_project_backer){ FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => successful_project) }
  let(:not_confirmed_backer){ FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => false, :user => user, :project => unfinished_project) }
  let(:older_than_180_days_backer){ FactoryGirl.create(:backer, :created_at => (Date.today - 181.days),:value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => unfinished_project) }
  let(:valid_refund){ FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => project) }

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
      backer = FactoryGirl.build(:backer)
      project1 = FactoryGirl.create(:project)
      project2 = FactoryGirl.create(:project)
      backer.project = project1
      reward = FactoryGirl.create(:reward, :project => project2)
      backer.should be_valid
      backer.reward = reward
      backer.should_not be_valid
    end

    it "should have a value at least equal to reward's minimum value" do
      project = FactoryGirl.create(:project)
      reward = FactoryGirl.create(:reward, :minimum_value => 500, :project => project)
      backer = FactoryGirl.build(:backer, :reward => reward, :project => project)
      backer.value = 499.99
      backer.should_not be_valid
      backer.value = 500.00
      backer.should be_valid
      backer.value = 500.01
      backer.should be_valid
    end

    it "should not be able to back if reward's maximum backers' been reached (and maximum backers > 0)" do
      project = FactoryGirl.create(:project)
      reward1 = FactoryGirl.create(:reward, :maximum_backers => nil, :project => project)
      reward2 = FactoryGirl.create(:reward, :maximum_backers => 1, :project => project)
      reward3 = FactoryGirl.create(:reward, :maximum_backers => 2, :project => project)
      backer = FactoryGirl.build(:backer, :reward => reward1, :project => project)
      backer.should be_valid
      backer.save
      backer = FactoryGirl.build(:backer, :reward => reward1, :project => project)
      backer.should be_valid
      backer.save
      backer = FactoryGirl.build(:backer, :reward => reward2, :project => project)
      backer.should be_valid
      backer.save
      backer = FactoryGirl.build(:backer, :reward => reward2, :project => project)
      backer.should_not be_valid
      backer = FactoryGirl.build(:backer, :reward => reward3, :project => project)
      backer.should be_valid
      backer.save
      backer = FactoryGirl.build(:backer, :reward => reward3, :project => project)
      backer.should be_valid
      backer.save
      backer = FactoryGirl.build(:backer, :reward => reward3, :project => project)
      backer.should_not be_valid
    end
  end
  
  describe "#refund!" do
    subject{ FactoryGirl.build(:backer, :value => 99.99, :refunded => false) }
    it "should set refunded to true" do
      subject.refund!
      subject.refunded.should == true
    end
  end  

  describe '.pending_to_refund' do
    subject { Backer.pending_to_refund }

    context 'when backer is confirmed and as requested refund' do
      before do
        FactoryGirl.create(:backer, confirmed: true, requested_refund: true, refunded: true)
        FactoryGirl.create(:backer, confirmed: true, requested_refund: true, refunded: false)
      end

      it { should have(1).item }
    end

    context 'when backer is confirmed and already have refunded' do
      before do
        FactoryGirl.create(:backer, confirmed: true, requested_refund: true, refunded: true)
        FactoryGirl.create(:backer, confirmed: true, requested_refund: true, refunded: false)
      end

      it { should have(1).item }
    end

    context 'when backer is not confirmed' do
      before do
        FactoryGirl.create(:backer, confirmed: false, requested_refund: true, refunded: false)
      end

      it { should have(0).item }
    end
  end

  describe '.in_time_to_confirm' do
    subject { Backer.in_time_to_confirm}
    
    context 'when we have backers with DebitoBancario and BoletoBancario in time to confirm' do
      before do
        FactoryGirl.create(:backer, confirmed: false, payment_token: 'ABC', payment_choice: 'DebitoBancario', created_at: 1.days.ago)
        FactoryGirl.create(:backer, confirmed: false, payment_token: 'ABC', payment_choice: 'DebitoBancario', created_at: 2.days.ago)
        FactoryGirl.create(:backer, confirmed: false, payment_token: 'ABC', payment_choice: 'BoletoBancario', created_at: 3.days.ago)        
      end
      
      it { should have(2).item }      
    end

    context "when backer is just a ghost" do
      before { FactoryGirl.create(:backer, confirmed: false, payment_token: nil, created_at: 3.days.ago) }
      it { should have(0).item }
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
    subject{ user.credits }
    context "when backs are confirmed and not done with credits but project is successful" do
      before do
        FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => successful_project)
      end
      it{ should == 0 }
    end

    context "when backs are confirmed and not done with credits" do
      before do
        FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => project)
      end
      it{ should == 10 }
    end

    context "when backs are done with credits" do
      before do
        FactoryGirl.create(:backer, :value => 10, :credits => true, :requested_refund => false, :confirmed => true, :user => user, :project => project)
      end
      it{ should == 0 }
    end

    context "when backs are not confirmed" do
      before do
        FactoryGirl.create(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => false, :user => user, :project => project)
      end
      it{ should == 0 }
    end
  end

  describe "#confirm!" do
    subject{ FactoryGirl.build(:backer, :value => 99.99, :confirmed => false) }

    its(:confirmed){ should == false }

    it "should confirm the back" do
      subject.confirm!
      subject.confirmed.should == true
    end
  end

  describe "#display_value" do
    context "when the value has decimal places" do
      subject{ FactoryGirl.build(:backer, :value => 99.99).display_value }
      it{ should == "R$ 100" }
    end

    context "when the value does not have decimal places" do
      subject{ FactoryGirl.build(:backer, :value => 1).display_value }
      it{ should == "R$ 1" }
    end
  end

  describe "#display_platform_fee" do
    before(:each) do
      I18n.locale = :pt
      @backer = create(:backer, :value => 100)
    end

    it 'with default tax 7.5%'do
      @backer.display_platform_fee.should == 'R$ 7,50'
    end

    it 'with another tax'do
      @backer.display_platform_fee(5).should == 'R$ 5,00'
    end
  end

  describe "#platform_fee" do
    before(:each) do
      @backer = create(:backer, :value => 100)
    end

    it 'with default tax 7.5%'do
      @backer.platform_fee.should == 7.50
    end

    it 'with another tax'do
      @backer.platform_fee(5).should == 5.00
    end
  end
end
