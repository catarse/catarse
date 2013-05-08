require 'spec_helper'

describe Credits::Refund do
  let(:failed_project){ FactoryGirl.create(:project, state: 'failed')  }
  let(:backer) { FactoryGirl.create(:backer, state: 'confirmed') }

  subject { Credits::Refund.new(backer, backer.user) }

  context "when user request a refund" do
    it do
      subject.expects(:check_refunded)
      subject.expects(:check_requested)
      subject.expects(:check_total_of_credits)
      subject.expects(:check_can_refund)
      subject.make_request!
      backer.requested_refund?.should be_true
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
      let(:backer) { FactoryGirl.create(:backer, state: 'refunded') }
      it "should raise a exception with message" do
        lambda { 
          subject.make_request!
        }.should raise_exception(I18n.t('credits.refund.refunded'))
      end
    end
    context "when backer already requested to refund" do
      let(:backer) { FactoryGirl.create(:backer, state: 'requested_refund') }      
      it "should raise a exception with message" do
        lambda { 
          subject.make_request!
        }.should raise_exception(I18n.t('credits.refund.requested_refund'))
      end
    end
  end
end
