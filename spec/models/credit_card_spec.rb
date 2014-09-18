require 'spec_helper'

describe CreditCard do
  describe "Associations" do
    it{ should belong_to :user }
  end

  describe "Validations" do
    it{ should validate_presence_of(:user) }
    it{ should validate_presence_of(:last_digits) }
    it{ should validate_presence_of(:card_brand) }
    it{ should validate_presence_of(:subscription_id) }
  end
end
