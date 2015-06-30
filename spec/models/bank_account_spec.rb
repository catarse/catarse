require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  let(:bank_account) { create(:bank_account) }
  describe "associations" do
    it{ is_expected.to belong_to :user }
  end

  describe "Validations" do
    it{ is_expected.to validate_presence_of(:bank_id) }
    it{ is_expected.to validate_presence_of(:agency) }
    it{ is_expected.to validate_presence_of(:account) }
    it{ is_expected.to validate_presence_of(:account_digit) }
    it{ is_expected.to validate_presence_of(:owner_name) }
    it{ is_expected.to validate_presence_of(:owner_document) }
  end

  describe "#complete_agency_string" do
    subject { bank_account.complete_agency_string }
    context "without a agency digit" do
      before do
        bank_account.update_column(:agency_digit, nil)
      end

      it { is_expected.to eq("#{bank_account.agency}") }
    end

    context "with agency digit" do
      it { is_expected.to eq("#{bank_account.agency} - #{bank_account.agency_digit}") }
    end
  end

  describe "#complete_account_string" do
    subject { bank_account.complete_account_string }
    it { is_expected.to eq("#{bank_account.account} - #{bank_account.account_digit}") }
  end
end
