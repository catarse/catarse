require 'spec_helper'

describe BackerObserver do
  describe "after_create" do
    before{ Kernel.stubs(:rand).returns(1) }

    subject{ @backer = Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated') }

    its(:key){ should == Digest::MD5.new.update("#{@backer.id}###{@backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end

  describe "before_save" do
    subject{ @backer = Factory(:backer, confirmed: true, confirmed_at: nil) }

    its(:confirmed_at) { should_not be_nil }
  end
end
