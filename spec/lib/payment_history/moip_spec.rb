require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe PaymentHistory::Moip do
  before(:each) do
    MoIP::Client.stubs(:query).returns(moip_query_response)
  end

  describe "When receive params of POST request" do
    context "when create log" do

      it 'should have a payment log in backer after receive request' do
        backer = create(:backer, :value => 21.90, :confirmed => false)
        backer.update_attribute :key, 'ABCD'
        backer.reload

        params = post_moip_params.merge!({:id_transacao => 'ABCD', :status_pagamento => PaymentHistory::Moip::TransactionStatus::AUTHORIZED})
        backer.payment_logs.should be_empty
        moip_request = PaymentHistory::Moip.new(params).process_request!
        backer.reload
        moip_request.response_code.should == PaymentHistory::Moip::ResponseCode::SUCCESS
        backer.payment_logs.should have(1).item

        log = backer.payment_logs.first
        log.amount.should == 2190
        log.payment_status.should == PaymentHistory::Moip::TransactionStatus::AUTHORIZED
        log.payment_type.should == 'CartaoDeCredito'

        backer.payment_detail.should_not be_nil
      end
    end

    context "workflow" do
      before(:each) do
        @backer = create(:backer, :value => 21.90)
        @backer.update_attribute :key, 'ABCD'
        @backer.reload

        @backer_with_wrong_value = create(:backer, :value => 22.90)
        @backer_with_wrong_value.update_attribute :key, 'ABCDE'
        @backer_with_wrong_value.reload

        @params = post_moip_params
      end

      subject { PaymentHistory::Moip.new(@params.merge!({:status_pagamento => PaymentHistory::Moip::TransactionStatus::AUTHORIZED})) }

      context 'with wrong backer' do
        subject { PaymentHistory::Moip.new(@params.merge!({:id_transacao => 'ABCDE'})) }

        it {
          subject.process_request!
          subject.response_code.should == PaymentHistory::Moip::ResponseCode::NOT_PROCESSED
        }

        it 'should not call build log' do
          subject.expects(:find_backer).returns(@backer_with_wrong_value)
          subject.expects(:build_log).never
          subject.backer.expects(:confirm!).never
          subject.backer.expects(:build_payment_detail).never
        end

        after(:each) do
          subject.process_request!
        end
      end

      context "with confirmed backer" do
        it "should not update a payment detail" do
          subject.expects(:find_backer).returns(@backer)
          subject.stubs(:backer).returns(@backer)
          subject.backer.expects(:build_payment_detail).never
          subject.backer.expects(:confirm!).never
          subject.process_request!
        end
      end

      context "with not confirmed backer and authorization request" do
        before(:each) do
          @backer.update_attribute :confirmed, false
        end

        it 'should confirm and update paymend detail' do
          subject.expects(:find_backer).returns(@backer)
          subject.stubs(:backer).returns(@backer)
          subject.backer.expects(:confirm!).returns(true)
          # subject.backer.expects(:build_payment_detail)
          subject.process_request!
        end
      end

      context 'with correct backer' do
        subject { PaymentHistory::Moip.new(@params) }

        it 'should call find_backer and build_log' do
          subject.expects(:find_backer).returns(@backer)
          subject.expects(:build_log).returns(@backer.payment_logs.first)
        end

        it "with not found backer fill the response_code with 422" do
          moip = PaymentHistory::Moip.new(post_moip_params.merge!(:id_transacao => '1234'))
          moip.response_code.should be_nil
          moip.process_request!
          moip.response_code.should == PaymentHistory::Moip::ResponseCode::NOT_PROCESSED
        end

        after(:each) do
          subject.process_request!
        end
      end
    end
  end

  it 'Response code enum' do
    transaction = PaymentHistory::Moip::ResponseCode
    transaction::NOT_PROCESSED.should ==  422
    transaction::SUCCESS.should       ==  200
  end

  it 'Transaction status enum' do
    transaction = PaymentHistory::Moip::TransactionStatus
    transaction::AUTHORIZED.should      ==  1
    transaction::STARTED.should         ==  2
    transaction::PRINTED_BOLETO.should  ==  3
    transaction::FINISHED.should        ==  4
    transaction::CANCELED.should        ==  5
    transaction::PROCESS.should         ==  6
    transaction::WRITTEN_BACK.should    ==  7
  end
end