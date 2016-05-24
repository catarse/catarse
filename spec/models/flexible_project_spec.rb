require 'rails_helper'

RSpec.describe FlexibleProject, type: :model do
  let!(:flexible_project) { create(:flexible_project, permalink: 'foo', state: 'draft', online_days: nil, expires_at: nil) }

  describe "associations" do
    subject { flexible_project }

    it{ is_expected.to have_many :project_transitions }
  end

  describe "validations" do
    subject { flexible_project }

    it{ is_expected.to allow_value(1).for(:online_days) }
    it{ is_expected.not_to allow_value(0).for(:online_days) }
    it{ is_expected.not_to allow_value(400).for(:online_days) }
    it{ is_expected.to allow_value(61).for(:online_days) }
    it{ is_expected.to validate_presence_of :name }
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
