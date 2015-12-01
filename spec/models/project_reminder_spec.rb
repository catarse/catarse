require 'rails_helper'

RSpec.describe ProjectReminder, type: :model do
  describe "associations" do
    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :project }
  end

  describe "validations" do
    before do
      create(:project_reminder)
    end

    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :project_id }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:project_id) }
  end
end
