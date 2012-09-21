require 'spec_helper'

describe BackerObserver do
  let(:backer){ Factory(:backer, :key => 'should be updated', :payment_method => 'should be updated', :confirmed => true, :confirmed_at => nil) }
  subject{ backer }

  describe "after_create" do
    before do 
      Kernel.stubs(:rand).returns(1)
      #Notification.expects(:payment_slip).with(:backer => backer)
    end

    its(:key){ should == Digest::MD5.new.update("#{backer.id}###{backer.created_at}##1").to_s }
    its(:payment_method){ should == 'MoIP' }
  end

  describe "before_save" do
    its(:confirmed_at) { should_not be_nil }
  end
end
