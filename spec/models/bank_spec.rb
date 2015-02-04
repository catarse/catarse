# coding: utf-8
require 'rails_helper'

RSpec.describe Bank, type: :model do
  describe ".order_popular" do
    subject { Bank.order_popular }
    let(:user_01) { create(:user_without_bank_data) }
    let(:bank_01) { create(:bank, name: "Foo") }
    let(:bank_02) { create(:bank, name: "Foo bar", code: "001") }

    before do
      user_01
      bank_01
      bank_02
    end

    context "we have bank accounts" do
      before do
        @bank_account01 = create(:bank_account, user: user_01, bank: bank_01)
        @bank_account02 = create(:bank_account, user: user_01, bank: bank_01)
        @bank_account03 = create(:bank_account, user: user_01, bank: bank_02)
      end

      it "should return a collection with banks in order of most used" do
        is_expected.to eq([bank_01, bank_02])
      end
    end
  end

end
