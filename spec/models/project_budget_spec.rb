require 'rails_helper'

RSpec.describe ProjectBudget, :type => :model do
  describe "Associations" do
    it { is_expected.to belong_to(:project) }
  end

  describe "Validations" do
    it{ is_expected.to validate_presence_of(:name) }
    it{ is_expected.to validate_presence_of(:value) }
  end
end
