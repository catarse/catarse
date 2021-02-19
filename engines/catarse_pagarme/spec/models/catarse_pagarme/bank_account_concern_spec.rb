# frozen_string_literal: true

require 'spec_helper'

class FakeBankAccount < BankAccount
  include CatarsePagarme::BankAccountConcern
end

describe FakeBankAccount do
  let(:user) { create(:user) }
  let(:bank) { create(:bank) }

  let(:valid_attr) do
    vb = build(:bank_account, bank: bank, owner_name: 'fo', user: user)
    vb.attributes
  end

  let(:valid_attr_on_pagarme) do
    {
      bank_id: bank.id,
      agency: '1732',
      agency_dv: '8',
      account: '25483',
      account_dv: 'X',
      owner_name: 'Lorem Ipsum',
      owner_document: '111.111.111-11'
    }
  end

  describe "validate :must_be_valid_on_pagarme" do
    context "when bank account has invalid data on pagarme" do
      let(:bank_account_on_pagarme) { FakeBankAccount.new(valid_attr) }
      let(:local_bank_account) { BankAccount.new(valid_attr) }

      it "local_bank_account should be valid" do
        expect(local_bank_account.valid?).to be_truthy
      end

      it "bank_account_on_pagarme should be not valid with these attrs" do
        expect(bank_account_on_pagarme.valid?).to be_falsey
      end

      it "bank_account_on_pagarme should be valid with another attrs" do
        subject { FakeBankAccount.new(valid_attr_on_pagarme).valid? }
        expect(subject).to be_truthy
      end
    end
  end
end
