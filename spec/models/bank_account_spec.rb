require 'spec_helper'

describe BankAccount do
  describe "associations" do
    it{ should belong_to :user }
  end

  describe "Validations" do
    it{ should validate_presence_of(:name) }
    it{ should validate_presence_of(:agency) }
    it{ should validate_presence_of(:account) }
    it{ should validate_presence_of(:account_digit) }
    it{ should validate_presence_of(:user_name) }
    it{ should validate_presence_of(:user_document) }
  end
end
