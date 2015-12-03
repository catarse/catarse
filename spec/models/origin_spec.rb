require 'rails_helper'

RSpec.describe Origin, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:contributions) }
  end
end
