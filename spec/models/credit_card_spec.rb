require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  describe "Associations" do
    it{ is_expected.to belong_to :user }
  end

  describe "Validations" do
    it{ is_expected.to validate_presence_of(:user) }
    it{ is_expected.to validate_presence_of(:last_digits) }
    it{ is_expected.to validate_presence_of(:card_brand) }
  end
end
