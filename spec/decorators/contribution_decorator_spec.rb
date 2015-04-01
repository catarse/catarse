require 'rails_helper'

RSpec.describe ContributionDecorator do
  include Draper::LazyHelpers

  let(:contribution){ create(:confirmed_contribution) }
  let(:payment){ contribution.payments.last }

  before do
    I18n.locale = :pt
  end

  describe "#display_installments_details" do
    subject { contribution.decorate.display_installment_details }
    context "when I have 1 installment" do
      before do
        payment.update_attributes installments: 1
      end
      it{ is_expected.to eq "" }
    end

    context "when I have >1 installment" do
      before do
        payment.update_attributes installments: 2, installment_value: 10
      end
      it{ is_expected.to eq "#{payment.installments} x #{number_to_currency payment.installment_value}" }
    end
  end

  describe "#display_payment_details" do
    subject { contribution.decorate.display_payment_details }
    context "when contribution is made with credits" do
      before do
        payment.update_attributes gateway: 'Credits'
      end
      it{ is_expected.to eq I18n.t("contribution.payment_details.creditos") }
    end

    context "when contribution is not made with credits" do
      before do
        payment.update_attributes gateway: 'Pagarme', payment_method: 'CartaoDeCredito'
      end
      it{ is_expected.to eq I18n.t("contribution.payment_details.cartao_de_credito") }
    end
  end

  describe "#display_date" do
    [:paid_at, :refunded_at, :pending_refund_at].each do |field|
      context "displaying #{field.to_s}" do
        subject { contribution.decorate.display_date(field)}
        before do
          attributes = {}
          attributes[field] = Time.now
          payment.update_attributes attributes
        end

        it{ is_expected.to eq(I18n.l(payment.send(field).to_date)) }
      end
    end
  end

  describe "#display_value" do

    context "when the value has decimal places" do
      subject{ build(:contribution, value: 99.99).decorate.display_value }
      it{ is_expected.to eq("R$ 99,99") }
    end

    context "when the value does not have decimal places" do
      subject{ build(:contribution, value: 1).decorate.display_value }
      it{ is_expected.to eq("R$ 1,00") }
    end
  end

  describe "#display_status" do
    subject{ contribution.decorate.display_status }

    context "when payment is paid" do
      before do
        payment.update_attributes paid_at: Time.now
      end
      it{ is_expected.to eq I18n.t("payment.state.#{payment.state}", date: contribution.decorate.display_date(:paid_at)) }
    end

    context "when payment is pending" do
      let(:contribution){ create(:pending_contribution) }
      it{ is_expected.to eq I18n.t("payment.state.#{payment.state}", date: contribution.decorate.display_date(:paid_at)) }
    end
  end

  describe "#display_slip_url" do
    let(:contribution){ create(:confirmed_contribution) }
    context "when slip_url is filled" do
      before do
        contribution.payments.last.update_attributes gateway_data: {boleto_url: 'http://foo.bar/'}
      end

      subject { contribution.decorate.display_slip_url }
      it{ is_expected.to eq('http://foo.bar/')}
    end
  end
end

