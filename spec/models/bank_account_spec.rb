require 'spec_helper'

describe BankAccount do
  describe "associations" do
    it{ should belong_to :user }
  end

  describe "Validations" do
    it{ should validate_presence_of(:bank_id) }
    it{ should validate_presence_of(:agency) }
    it{ should validate_presence_of(:account) }
    it{ should validate_presence_of(:account_digit) }
    it{ should validate_presence_of(:owner_name) }
    it{ should validate_presence_of(:owner_document) }
  end
end
