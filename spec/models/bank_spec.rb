# coding: utf-8
require 'rails_helper'

RSpec.describe Bank, type: :model do
  describe ".order_popular" do
    subject { Bank.order_popular }

    let(:user_01) { create(:user, :without_bank_data) }
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

  describe '.most_popular_collection' do
    subject { Bank.most_popular_collection }

    let(:user_01) { create(:user, :without_bank_data) }
    let(:bank_01) { create(:bank, name: "Foo") }
    let(:bank_02) { create(:bank, name: "Foo bar", code: "001") }
    let(:bank_03) { create(:bank, name: "Foo bar 2", code: "002") }

    let!(:bank_account01) { create(:bank_account, user: user_01, bank: bank_01) }
    let!(:bank_account02) { create(:bank_account, user: user_01, bank: bank_01) }
    let!(:bank_account03) { create(:bank_account, user: user_01, bank: bank_02) }

    before do
      stub_const("Bank::MOST_POPULAR_LIMIT", 2)
    end

    context "when we have a current_bank injected" do
      subject { Bank.most_popular_collection(bank_03) }
      it "returns a collection with banks in order of most used" do
        is_expected.to eq([[bank_01.to_s, bank_01.id],
                           [bank_02.to_s, bank_02.id],
                           [bank_03.to_s, bank_03.id],
                           [I18n.t('shared.no_bank_label'), 0]])
      end
    end
  end
end
