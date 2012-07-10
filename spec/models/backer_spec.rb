require 'spec_helper'

describe Backer do
  it "should not add backer value as credits for user if could not be refunded" do
    u = Factory(:user)
    u.save
    b = Factory.build(:backer, :value => 10, :credits => true, :can_refund => false, :user => u)
    b.save
    u.credits.should == 0
    b2 = Factory.build(:backer, :value => 10, :credits => true, :can_refund => false, :user => u)
    b2.save
    u.credits.should == 0
  end

  it "should not add backer value as credits for user if not confirmed" do
    u = Factory(:user)
    u.save
    b = Factory.build(:backer, :value => 10, :credits => true, :can_refund => true, :confirmed => false, :user => u)
    b.save
    u.credits.should == 0
    b2 = Factory.build(:backer, :value => 10, :credits => true, :can_refund => true, :confirmed => false, :user => u)
    b2.save
    u.credits.should == 0
  end

  it { should have_many(:payment_logs) }

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

  describe "after_create" do
    before{ Kernel.stubs(:rand).returns(1) }

    subject{ @backer = Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated') }

    its(:key){ should == Digest::MD5.new.update("#{@backer.id}###{@backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end

  describe "#valid?" do
    it{ should validate_presence_of(:project) }
    it{ should validate_presence_of(:user) }
    it{ should validate_presence_of(:value) }
    it{ should_not allow_value(9.99).for(:value) }
    it{ should allow_value(10).for(:value) }
    it{ should allow_value(20).for(:value) }
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

  describe "#payment_service_fee" do
    let(:backer){ Backer.new }
    subject{ backer.payment_service_fee }
    context "when there is a payment detail" do
      before(:each) do
        backer.build_payment_detail
        backer.payment_detail.stubs(:service_tax_amount).returns('5.75')
      end
      it{ should == 5.75 }
    end

    context "when there is not a payment detail" do
      before(:each) do
        payment_detail = mock()
        payment_detail.expects(:update_from_service).returns(payment_detail)
        backer.expects(:build_payment_detail).returns(payment_detail)
        payment_detail.stubs(:service_tax_amount).returns('5.75')
      end
      it{ should == 5.75 }
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
