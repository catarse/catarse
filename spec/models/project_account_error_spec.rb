require "rails_helper"

RSpec.describe ProjectAccountError, type: :model do
  describe "associations" do
    it { is_expected.to belong_to :project_account }
  end
end
