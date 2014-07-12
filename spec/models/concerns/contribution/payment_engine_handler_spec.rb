require 'spec_helper'

describe Contribution::PaymentEngineHandler do
  let(:contribution){ create(:contribution, payment_method: 'MoIP') }
  let(:moip_engine) { double }

  before do
    Contribution.any_instance.unstub(:payment_engine)
    PaymentEngines.clear

    moip_engine.stub(:name).and_return('MoIP')
    moip_engine.stub(:review_path).and_return("/#{contribution}")
    moip_engine.stub(:locale).and_return('pt')
    moip_engine.stub(:can_do_refund?).and_return(false)
    moip_engine.stub(:direct_refund).and_return(false)

  end

  let(:engine){ moip_engine }

  describe "#payment_engine" do
    subject { contribution.payment_engine }

    context "when contribution has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine) }
    end

    context "when contribution don't have a payment engine" do
      it { should be_a_kind_of(PaymentEngines::Interface) }
    end
  end

  describe "#can_do_refund?" do
    subject { contribution.can_do_refund? }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        moip_engine.stub(:can_do_refund?).and_return(true)
        PaymentEngines.register(engine)
      end

      it { should be_true }
    end

    context "when contribution has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { should be_false }
    end
  end

  describe "direct_refund" do
    subject { contribution.direct_refund }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        moip_engine.stub(:can_do_refund?).and_return(true)
        moip_engine.stub(:direct_refund).and_return(true)
        PaymentEngines.register(engine)
      end

      it { should be_true }
    end

    context "when contribution has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { should be_false }
    end
  end

  describe "#review_path" do
    subject { contribution.review_path }

    context "when contribution has a payment engine" do
      before do
        contribution.stub(:payment_engine).and_return(engine)
        PaymentEngines.register engine
      end

      it { should eq(engine.review_path(contribution)) }
    end

    context "when contribution don't have a payment engine" do
      it { should eq(nil) }
    end
  end

  describe "#update_current_billing_info" do
    let(:contribution) { build(:contribution, user: user) }
    let(:user) {
      build(:user, {
        address_street: 'test stret',
        address_number: '123',
        address_neighbourhood: 'test area',
        address_zip_code: 'test zipcode',
        address_city: 'test city',
        address_state: 'test state',
        phone_number: 'test phone',
        cpf: 'test doc number'
      })
    }
    subject{ contribution }
    before do
      contribution.update_current_billing_info
    end
    its(:payer_name) { should eq(user.display_name) }
    its(:address_street){ should eq(user.address_street) }
    its(:address_number){ should eq(user.address_number) }
    its(:address_neighbourhood){ should eq(user.address_neighbourhood) }
    its(:address_zip_code){ should eq(user.address_zip_code) }
    its(:address_city){ should eq(user.address_city) }
    its(:address_state){ should eq(user.address_state) }
    its(:address_phone_number){ should eq(user.phone_number) }
    its(:payer_document){ should eq(user.cpf) }
  end

  describe "#update_user_billing_info" do
    let(:contribution) { create(:contribution) }
    let(:contribution_attributes) {
      {
        address_street: contribution.address_street,
        address_number: contribution.address_number,
        address_neighbourhood: contribution.address_neighbourhood,
        address_zip_code: contribution.address_zip_code,
        address_city: contribution.address_city,
        address_state: contribution.address_state,
        phone_number: contribution.address_phone_number,
        cpf: contribution.payer_document
      }
    }
    context "when cpf on contribution is not null" do
      let(:user) { contribution.user }
      let(:contribution_attributes) {
        {
          address_street: contribution.address_street,
          address_number: contribution.address_number,
          address_neighbourhood: contribution.address_neighbourhood,
          address_zip_code: contribution.address_zip_code,
          address_city: contribution.address_city,
          address_state: contribution.address_state,
          phone_number: contribution.address_phone_number,
          cpf: contribution.payer_document
        }
      }

      before do
        contribution.update_attributes payer_document: '123'
        contribution.reload
        user.should_receive(:update_attributes).with(contribution_attributes)
      end

      it("should update user billing info attributes") { contribution.update_user_billing_info}
    end

    context "when cpf on contributions is null" do
      let(:contribution) { create(:contribution, payer_document: '') }
      let(:user) { contribution.user }

      before do
        user.update_column :cpf, '000'
        user.reload
        user.should_receive(:update_attributes).with(contribution_attributes.merge!({cpf: user.cpf}))
      end

      it("should update user billing info attributes") { contribution.update_user_billing_info }
    end
  end

end
