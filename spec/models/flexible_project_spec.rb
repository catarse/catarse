require 'rails_helper'

RSpec.describe FlexibleProject, type: :model do
  let!(:project) { create(:project, permalink: 'foo', state: 'draft', expires_at: nil) }
  let!(:flexible_project) { create(:flexible_project, project: project) }

  describe "associations" do
    subject { flexible_project }

    it{ is_expected.to belong_to :project }
    it{ is_expected.to have_many :transitions }
  end

  describe "validations" do
    subject { flexible_project }

    it{ is_expected.to validate_presence_of :project_id }
    it{ is_expected.to validate_uniqueness_of :project_id }
  end

  describe "#state_machine" do
    subject { flexible_project.state_machine }

    it { is_expected.to be_an_instance_of(FlexProjectMachine) }
  end

  describe "#announce_expiration" do
    context "when expires_at is not defined" do
      before do
        flexible_project.announce_expiration
      end

      it "should set 7 days from now for expiration"do
        expect(flexible_project.expires_at >= 7.days.from_now).to eq(true)
      end
    end

    context "when expires_at is defined" do
      before do
        allow(flexible_project).to receive(:expires_at).and_return(2.days.from_now)
        flexible_project.announce_expiration
      end

      it "should not change the current expiration date" do
        expect(flexible_project.expires_at < 7.days.from_now).to eq(true)
      end
    end
  end
end
