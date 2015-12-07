require 'rails_helper'

RSpec.describe BalanceTransaction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:contribution) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it{ is_expected.to validate_presence_of(:amount) }
    it{ is_expected.to validate_presence_of(:event_name) }
    it{ is_expected.to validate_presence_of(:user_id) }
  end
end
