require 'spec_helper'

describe Backer do
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

  describe "#credits" do
    let(:user){ Factory(:user) }
    let(:project){ Factory(:project, :finished => true, :successful => false) }
    let(:successful_project){ Factory(:project, :finished => true, :successful => true) }
    subject{ user.credits }
    context "when backs are confirmed and not done with credits but project is successful" do
      before do
        Factory(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => successful_project)
      end
      it{ should == 0 }
    end

    context "when backs are confirmed and not done with credits" do
      before do
        Factory(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => true, :user => user, :project => project)
      end
      it{ should == 10 }
    end

    context "when backs are done with credits" do
      before do
        Factory(:backer, :value => 10, :credits => true, :requested_refund => false, :confirmed => true, :user => user, :project => project)
      end
      it{ should == 0 }
    end

    context "when backs are not confirmed" do
      before do
        Factory(:backer, :value => 10, :credits => false, :requested_refund => false, :confirmed => false, :user => user, :project => project)
      end
      it{ should == 0 }
    end
  end


  it "should have reward from the same project only" do
    backer = Factory.build(:backer)
    project1 = Factory(:project)
    project2 = Factory(:project)
    backer.project = project1
    reward = Factory(:reward, :project => project2)
    backer.should be_valid
    backer.reward = reward
    backer.should_not be_valid
  end

  it "should have a value at least equal to reward's minimum value" do
    project = Factory(:project)
    reward = Factory(:reward, :minimum_value => 500, :project => project)
    backer = Factory.build(:backer, :reward => reward, :project => project)
    backer.value = 499.99
    backer.should_not be_valid
    backer.value = 500.00
    backer.should be_valid
    backer.value = 500.01
    backer.should be_valid
  end

  it "should not be able to back if reward's maximum backers' been reached (and maximum backers > 0)" do
    project = Factory(:project)
    reward1 = Factory(:reward, :maximum_backers => nil, :project => project)
    reward2 = Factory(:reward, :maximum_backers => 1, :project => project)
    reward3 = Factory(:reward, :maximum_backers => 2, :project => project)
    backer = Factory.build(:backer, :reward => reward1, :project => project)
    backer.should be_valid
    backer.save
    backer = Factory.build(:backer, :reward => reward1, :project => project)
    backer.should be_valid
    backer.save
    backer = Factory.build(:backer, :reward => reward2, :project => project)
    backer.should be_valid
    backer.save
    backer = Factory.build(:backer, :reward => reward2, :project => project)
    backer.should_not be_valid
    backer = Factory.build(:backer, :reward => reward3, :project => project)
    backer.should be_valid
    backer.save
    backer = Factory.build(:backer, :reward => reward3, :project => project)
    backer.should be_valid
    backer.save
    backer = Factory.build(:backer, :reward => reward3, :project => project)
    backer.should_not be_valid
  end

  describe "#refund!" do
    subject{ Factory.build(:backer, :value => 99.99, :refunded => false) }
    it "should set refunded to true" do
      subject.refund!
      subject.refunded.should == true
    end
  end

  describe "#confirm!" do
    subject{ Factory.build(:backer, :value => 99.99, :confirmed => false) }

    its(:confirmed){ should == false }

    it "should confirm the back" do
      subject.confirm!
      subject.confirmed.should == true
    end

    it "should send notify email when confirmed" do
      subject.confirm!
      ActionMailer::Base.deliveries.should_not be_empty
    end
  end

  describe "#display_value" do
    context "when the value has decimal places" do
      subject{ Factory.build(:backer, :value => 99.99).display_value }
      it{ should == "R$ 100" }
    end

    context "when the value does not have decimal places" do
      subject{ Factory.build(:backer, :value => 1).display_value }
      it{ should == "R$ 1" }
    end
  end

  describe "#display_platform_fee" do
    before(:each) do
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
