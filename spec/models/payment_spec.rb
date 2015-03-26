require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment){ create(:payment) }

  describe "associations" do
    it{ should have_and_belong_to_many :contributions }
  end

  describe "validations" do
    it{ should validate_presence_of :state }
    it{ should validate_presence_of :gateway }
    it{ should validate_presence_of :method }
    it{ should validate_presence_of :value }
    it{ should validate_presence_of :installments }
    it{ should validate_presence_of :installment_value }
  end

  describe "#contribution" do
    subject{ payment.contribution }
    it{ should eq payment.contributions.first }
  end

  describe "#valid?" do

    subject{ payment.valid? }

    context "when payment value is equal than what was pledged" do
      let(:payment){ build(:payment, value: 10, contributions: [create(:contribution, value: 10)]) }
      it{ is_expected.to eq true }
    end

    context "when payment value is lower than what was pledged" do
      let(:payment){ build(:payment, value: 9, contributions: [create(:contribution, value: 10)]) }
      it{ is_expected.to eq false }
    end

    it "should set key" do
      expect(payment.key).to_not be_nil
    end
  end
end
