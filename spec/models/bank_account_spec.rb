require 'rails_helper'

RSpec.describe BankAccount, type: :model do
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
end
