require 'spec_helper'

describe PaymentDetail do
  before(:each) do
    @project = create(:project)
    @backer = create(:backer, :project => @project)
  end

  subject {
    @backer.payment_detail||@backer.build_payment_detail
  }

  describe "instance_methods" do
    subject { create(:payment_detail) }
    its(:display_service_tax) { should == 'R$ 19,37' }
    its(:display_total_amount) { should == 'R$ 999,00' }
    its(:display_net_amount) { should == 'R$ 979,63' }
    its(:display_payment_date) { should == '30/09/2011, 09:33 h'}
  end

  describe "#update_from_service" do
    context "when MoIP" do
      before(:each) do
        @backer.update_attribute(:payment_method, 'MoIP')
        @backer.reload
      end

      context "with invalid Token" do
        before(:each) do
          @moip_response = MoIP::Client.stubs(:query).returns([])
        end

        it "should not call process_moip_response" do
          subject.expects(:process_moip_response).never
          subject.update_from_service
        end

        it "should not fill payment details" do
          subject.update_from_service

          subject.payer_name.should be_nil
          subject.payer_email.should be_nil
          subject.city.should be_nil
          subject.uf.should be_nil
          subject.payment_method.should be_nil
          subject.net_amount.should be_nil
          subject.total_amount.should be_nil
          subject.service_tax_amount.should be_nil
          subject.payment_status.should be_nil
          subject.service_code.should be_nil
          subject.institution_of_payment.should be_nil
          subject.payment_date.should be_nil
        end
      end

      context 'with valid Token and payment response contain a array' do
        before(:each) do
          @moip_response = MoIP::Client.stubs(:query).returns(moip_query_response_with_array)
        end

        it "should call process_moip_response" do
          subject.expects(:process_moip_response)
          subject.update_from_service
        end

        it "fill the payment_details" do
          subject.payer_name.should be_nil
          subject.payer_email.should be_nil
          subject.city.should be_nil
          subject.uf.should be_nil
          subject.payment_method.should be_nil
          subject.net_amount.should be_nil
          subject.total_amount.should be_nil
          subject.service_tax_amount.should be_nil
          subject.payment_status.should be_nil
          subject.service_code.should be_nil
          subject.institution_of_payment.should be_nil
          subject.payment_date.should be_nil

          subject.update_from_service

          subject.payer_name.should_not be_nil
          subject.payer_email.should_not be_nil
          subject.city.should_not be_nil
          subject.uf.should_not be_nil
          subject.payment_method.should_not be_nil
          subject.net_amount.should_not be_nil
          subject.total_amount.should_not be_nil
          subject.service_tax_amount.should_not be_nil
          subject.payment_status.should_not be_nil
          subject.service_code.should_not be_nil
          subject.institution_of_payment.should_not be_nil
          subject.payment_date.should_not be_nil
        end
      end

      context "with valid Token" do
        before(:each) do
          @moip_response = MoIP::Client.stubs(:query).returns(moip_query_response)
        end

        it "should call process_moip_response" do
          subject.expects(:process_moip_response)
          subject.update_from_service
        end

        it "fill the payment_details" do
          subject.payer_name.should be_nil
          subject.payer_email.should be_nil
          subject.city.should be_nil
          subject.uf.should be_nil
          subject.payment_method.should be_nil
          subject.net_amount.should be_nil
          subject.total_amount.should be_nil
          subject.service_tax_amount.should be_nil
          subject.payment_status.should be_nil
          subject.service_code.should be_nil
          subject.institution_of_payment.should be_nil
          subject.payment_date.should be_nil

          subject.update_from_service

          subject.payer_name.should_not be_nil
          subject.payer_email.should_not be_nil
          subject.city.should_not be_nil
          subject.uf.should_not be_nil
          subject.payment_method.should_not be_nil
          subject.net_amount.should_not be_nil
          subject.total_amount.should_not be_nil
          subject.service_tax_amount.should_not be_nil
          subject.payment_status.should_not be_nil
          subject.service_code.should_not be_nil
          subject.institution_of_payment.should_not be_nil
          subject.payment_date.should_not be_nil
        end
      end
    end
  end
end
