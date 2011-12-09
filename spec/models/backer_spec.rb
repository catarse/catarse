require 'spec_helper'

describe Backer do

  # it "should update user.credits when save a backer" do
  #   u = Factory(:user)
  #   u.save
  #   b = Factory.build(:backer, :value => 10, :credits => true, :can_refund => true, :user => u)
  #   b.save
  #   u.credits.should == 10
  #   b2 = Factory.build(:backer, :value => 10, :credits => true, :can_refund => true, :user => u)
  #   b2.save
  #   u.credits.should == 20
  # end

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
  it "should be valid from factory" do
    b = Factory(:backer)
    b.should be_valid
  end
  it "should have a project" do
    b = Factory.build(:backer, :project => nil)
    b.should_not be_valid
  end
  it "should have a user" do
    b = Factory.build(:backer, :user => nil)
    b.should_not be_valid
  end
  it "should have a value" do
    b = Factory.build(:backer, :value => nil)
    b.should_not be_valid
  end
  it "should have a rounded display_value" do
    b = Factory.build(:backer, :value => 99.99)
    b.display_value.should == "R$ 100"
    b = Factory.build(:backer, :value => 1)
    b.display_value.should == "R$ 1"
    b = Factory.build(:backer, :value => 0.01)
    b.display_value.should == "R$ 0"
  end
  it "should have greater than 10 value" do
    b = Factory.build(:backer)
    b.value = -0.01
    b.should_not be_valid
    b.value = 0.99
    b.should_not be_valid
    b.value = 9.99
    b.should_not be_valid
    b.value = 10.00
    b.should be_valid
    b.value = 10.01
    b.should be_valid
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
  it "should define a key after create" do
    Kernel.stubs(:rand).returns(1)
    Kernel.rand.should == 1
    backer = Factory(:backer)
    backer.key.should == Digest::MD5.new.update("#{backer.id}###{backer.created_at}##1").to_s
  end
  it "after create should define 'MoIP' how default payment_method" do
    backer = Factory(:backer)
    backer.payment_method.should == 'MoIP'
  end

  describe "#payment_service_fee" do
    before(:each) do
      @project = create(:project)
    end
    context "when payment is MoIP" do
      before(:each) do
        @backer = create(:backer, :project => @project, :payment_method => 'MoIP')
        create(:payment_detail, :backer => @backer)
      end

      it "get moip tax" do
        @backer.payment_service_fee.should == 19.37
      end
    end

    context "when payment is PayPal" do
      before(:each) do
        @backer = create(:backer, :project => @project, :payment_method => 'PayPal')
        @backer.reload
        HTTParty.stubs(:get).returns(FakeResponse.new)
      end

      it "get paypal tax" do
        @backer.payment_method = 'PayPal'
        @backer.save!
        @backer.payment_service_fee.should == 5.72
      end
    end
  end

  describe "#display_catarse_tax" do
    before(:each) do
      @backer = create(:backer, :value => 100)
    end

    it 'with default tax 7.5%'do
      @backer.display_catarse_tax.should == 'R$ 7,50'
    end

    it 'with another tax'do
      @backer.display_catarse_tax(5).should == 'R$ 5,00'
    end
  end

  describe "#catarse_tax" do
    before(:each) do
      @backer = create(:backer, :value => 100)
    end

    it 'with default tax 7.5%'do
      @backer.catarse_tax.should == 7.50
    end

    it 'with another tax'do
      @backer.catarse_tax(5).should == 5.00
    end
  end
end

# == Schema Information
#
# Table name: backers
#
#  id               :integer         not null, primary key
#  project_id       :integer         not null
#  user_id          :integer         not null
#  reward_id        :integer
#  value            :decimal(, )     not null
#  confirmed        :boolean         default(FALSE), not null
#  confirmed_at     :datetime
#  created_at       :datetime
#  updated_at       :datetime
#  display_notice   :boolean         default(FALSE)
#  anonymous        :boolean         default(FALSE)
#  key              :text
#  can_refund       :boolean         default(FALSE)
#  requested_refund :boolean         default(FALSE)
#  refunded         :boolean         default(FALSE)
#  credits          :boolean         default(FALSE)
#  notified_finish  :boolean         default(FALSE)
#  site_id          :integer         default(1), not null
#  payment_method   :text
#  payment_token    :text
#

