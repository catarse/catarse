require 'spec_helper'

describe PaymentDetail do
  before(:each) do
    @project = create(:project)
    @backer = create(:backer, :project => @project)
  end

  subject {
    @backer.payment_detail||@backer.build_payment_detail
  }

  describe '.update_from_service' do
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

# == Schema Information
#
# Table name: payment_details
#
#  id                     :integer         not null, primary key
#  backer_id              :integer
#  payer_name             :string(255)
#  payer_email            :string(255)
#  city                   :string(255)
#  uf                     :string(255)
#  payment_method         :string(255)
#  net_amount             :decimal(, )
#  total_amount           :decimal(, )
#  service_tax_amount     :decimal(, )
#  payment_status         :string(255)
#  service_code           :string(255)
#  institution_of_payment :string(255)
#  payment_date           :datetime
#  created_at             :datetime
#  updated_at             :datetime
#

