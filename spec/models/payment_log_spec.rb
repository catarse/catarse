require 'rails_helper'

RSpec.describe PaymentLog, type: :model do
  describe "Validations" do
    it{ is_expected.to validate_presence_of(:gateway_id) }
    it{ is_expected.to validate_presence_of(:data) }
  end
end
