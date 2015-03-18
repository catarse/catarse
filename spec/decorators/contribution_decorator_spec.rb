require 'rails_helper'

RSpec.describe ContributionDecorator do
  include Draper::LazyHelpers
  before do
    I18n.locale = :pt
  end

  describe "#display_installments_details" do
    subject { contribution.decorate.display_installment_details }
    context "when I have 1 installment" do
      let(:contribution){ create(:contribution, installments: 1) }
      it{ is_expected.to eq "" }
    end

    context "when I have >1 installment" do
      let(:contribution){ create(:contribution, installments: 2, installment_value: '10') }
      it{ is_expected.to eq "#{contribution.installments} x #{number_to_currency contribution.installment_value}" }
    end

    context "when I have >1 installment and nil in installment value" do
      let(:contribution){ create(:contribution, installments: 2, installment_value: nil) }
      it{ is_expected.to eq "#{contribution.installments} x #{number_to_currency contribution.installment_value}" }
    end
  end

  describe "#display_payment_details" do
    subject { contribution.decorate.display_payment_details }
    context "when contribution is made with credits" do
      let(:contribution){ create(:contribution, credits: true) }
      it{ is_expected.to eq I18n.t("contribution.payment_details.creditos") }
    end

    context "when contribution is not made with credits and choice is null" do
      let(:contribution){ create(:contribution, credits: false, payment_choice: nil) }
      it{ is_expected.to eq "" }
    end

    context "when contribution is not made with credits" do
      let(:contribution){ create(:contribution, credits: false, payment_choice: 'CartaoDeCredito') }
      it{ is_expected.to eq I18n.t("contribution.payment_details.cartao_de_credito") }
    end
  end

  describe "#display_date" do
    [:confirmed_at, :refunded_at, :requested_refund_at].each do |field|
      context "displaying #{field.to_s}" do
        subject { contribution.decorate.display_date(field)}

        let(:contribution) do
          c = build(:contribution)
          c[field] = Time.now
          c
        end

        it{ is_expected.to eq(I18n.l(contribution.send(field).to_date)) }
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

  describe "#display_slip_url" do
    context "when slip_url is filled" do
      subject { build(:contribution, slip_url: 'http://foo.bar/').decorate.display_slip_url }
      it{ is_expected.to eq('http://foo.bar/')}
    end

    context "when slip_url is not filled" do
      subject { build(:contribution).decorate.display_slip_url }
      it{ is_expected.to match(/www\.moip\.com\.br/) }
    end
  end
end

