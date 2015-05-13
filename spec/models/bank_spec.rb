# coding: utf-8
require 'rails_helper'

RSpec.describe Bank, type: :model do
  describe ".order_popular" do
    subject { Bank.order_popular }

    let(:user_01) { create(:user_without_bank_data) }
    let(:bank_01) { create(:bank, name: "Foo") }
    let(:bank_02) { create(:bank, name: "Foo bar", code: "001") }

    context "we have bank accounts" do
      let!(:bank_account01) { create(:bank_account, user: user_01, bank: bank_01) }
      let!(:bank_account02) { create(:bank_account, user: user_01, bank: bank_01) }
      let!(:bank_account03) { create(:bank_account, user: user_01, bank: bank_02) }

      it "returns a collection with banks in order of most used" do
        is_expected.to eq([bank_01, bank_02])
      end
    end
  end
end
