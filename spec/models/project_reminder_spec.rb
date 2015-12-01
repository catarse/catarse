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

  describe ".can_deliver" do
    context "when project is expiring" do
      let(:project) { create(:project, state: 'online', online_days: 1, expires_at: 1.hour.from_now) }

      before do
        4.times { create(:project_reminder, project: project) }
      end

      subject { ProjectReminder.can_deliver.count }

      it { is_expected.to eq(4) }
    end

    context "when project is not expiring" do
      let(:project) { create(:project, state: 'online', online_days: 10, expires_at: 60.hours.from_now) }

      before do
        4.times { create(:project_reminder, project: project) }
      end

      subject { ProjectReminder.can_deliver.count }

      it { is_expected.to eq(0) }
    end
  end
end
