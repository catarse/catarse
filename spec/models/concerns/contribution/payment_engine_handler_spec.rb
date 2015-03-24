require 'rails_helper'

RSpec.describe Contribution::PaymentEngineHandler, type: :model do
  let(:contribution){ create(:contribution, payment_method: 'MoIP') }
  let(:moip_engine) { double }

  before do
    allow_any_instance_of(Contribution).to receive(:payment_engine).and_call_original
    PaymentEngines.clear

    allow(moip_engine).to receive(:name).and_return('MoIP')
    allow(moip_engine).to receive(:review_path).and_return("/#{contribution}")
    allow(moip_engine).to receive(:locale).and_return('pt')
    allow(moip_engine).to receive(:can_do_refund?).and_return(false)
    allow(moip_engine).to receive(:direct_refund).and_return(false)

  end

  let(:engine){ moip_engine }

  describe "#payment_engine" do
    subject { contribution.payment_engine }

    context "when contribution has a payment engine" do
      before { PaymentEngines.register engine }

      it { is_expected.to eq(engine) }
    end

    context "when contribution don't have a payment engine" do
      it { is_expected.to be_a_kind_of(PaymentEngines::Interface) }
    end
  end

  describe "#can_do_refund?" do
    subject { contribution.can_do_refund? }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        allow(moip_engine).to receive(:can_do_refund?).and_return(true)
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(true) }
    end

    context "when contribution has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "direct_refund" do
    subject { contribution.direct_refund }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        allow(moip_engine).to receive(:can_do_refund?).and_return(true)
        allow(moip_engine).to receive(:direct_refund).and_return(true)
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(true) }
    end

    context "when contribution has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "#review_path" do
    subject { contribution.review_path }

    context "when contribution has a payment engine" do
      before do
        allow(contribution).to receive(:payment_engine).and_return(engine)
        PaymentEngines.register engine
      end

      it { is_expected.to eq(engine.review_path(contribution)) }
    end

    context "when contribution don't have a payment engine" do
      it { is_expected.to eq(nil) }
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
    its(:payer_name) { should eq(user.name) }
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
    let(:user) { contribution.user }
    let(:contribution) { create(:contribution) }
    let(:contribution_attributes) {
      {
        country_id: (contribution.country_id || user.country_id),
        address_street: (contribution.address_street || user.address_street),
        address_number: (contribution.address_number || user.address_number),
        address_complement: (contribution.address_complement || user.address_complement),
        address_neighbourhood: (contribution.address_neighbourhood || user.address_neighbourhood),
        address_zip_code: (contribution.address_zip_code || user.address_zip_code),
        address_city: (contribution.address_city || user.address_city),
        address_state: (contribution.address_state || user.address_state),
        phone_number: (contribution.address_phone_number || user.phone_number),
        cpf: (contribution.payer_document || user.cpf),
        name: (contribution.payer_name || user.name)
      }
    }

    before do
      contribution.update_attributes payer_document: '123'
      contribution.reload
      expect(user).to receive(:update_attributes).with(contribution_attributes)
    end

    it("should update user billing info attributes") { contribution.update_user_billing_info}
  end

end
