require 'spec_helper'

describe Credits::Refund do
  let(:failed_project){ FactoryGirl.create(:project, state: 'failed')  }
  before(:each) do
    @backer = FactoryGirl.create(:backer, value: 20)
  end

  subject { Credits::Refund.new(@backer, @backer.user) }

  context "when user request a refund" do
    it do
      subject.expects(:check_refunded)
      subject.expects(:check_requested)
      subject.expects(:check_total_of_credits)
      subject.expects(:check_can_refund)
      subject.make_request!
      @backer.requested_refund.should be_true
      subject.message.should == I18n.t('credits.index.refunded')
    end

    context "when user doesn't have the necessary value" do
      it "should raise a exception with message" do

        lambda {
          subject.make_request!
        }.should raise_exception(I18n.t('credits.refund.no_credits'))
      end
    end

    context "when backer already refunded" do
      it "should raise a exception with message" do
        @backer.update_column :refunded, true
        @backer.reload

        lambda { 
          subject.make_request!
        }.should raise_exception(I18n.t('credits.refund.refunded'))
      end
    end
    context "when backer already requested to refund" do
      it "should raise a exception with message" do
        @backer.update_column :requested_refund, true
        @backer.reload

        lambda { 
          subject.make_request!
        }.should raise_exception(I18n.t('credits.refund.requested_refund'))
      end
    end
  end
end
