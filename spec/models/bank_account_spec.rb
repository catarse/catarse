require 'spec_helper'

describe BankAccount do
  describe "associations" do
    it{ should belong_to :user }
  end

  describe "Validations" do
    it{ should validate_presence_of(:name) }
    it{ should validate_presence_of(:agency) }
    it{ should validate_presence_of(:agency_digit) }
    it{ should validate_presence_of(:account) }
    it{ should validate_presence_of(:account_digit) }
    it{ should validate_presence_of(:user_name) }
    it{ should validate_presence_of(:user_document) }
  end

  describe "#bank_code" do
    let(:bank_account) { BankAccount.new }
    context "when bank have the number" do
      before do
        bank_account.name = '237 - Banco do Bradesco S.A.'
      end

      it "should return the bank code" do
        expect(bank_account.bank_code).to eq("237")
      end
    end

    context "when bank don't have number" do
      before do
        bank_account.name = 'Banco do Bradesco S.A.'
      end

      it "should return nil" do
        expect(bank_account.bank_code).to eq(nil)
      end
    end
  end
end
