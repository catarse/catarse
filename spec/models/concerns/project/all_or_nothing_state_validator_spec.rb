# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project::AllOrNothingStateValidator, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: project_state) }

  context 'when project is going to online to end state' do
    subject { project }

    context 'online validation' do
      let(:project_state) { 'online' }

      it { is_expected.to validate_presence_of :city }
      it { is_expected.to validate_length_of(:name).is_at_most(Project::NAME_MAXLENGTH) }
      it { is_expected.to validate_numericality_of(:online_days).is_less_than_or_equal_to(60).is_greater_than_or_equal_to(1) }
    end

    Project::ON_ONLINE_TO_END_STATES.each do |state|
      context "#{state} project validations" do
        let(:project_state) { state }

        it { is_expected.to validate_presence_of :goal }
        it { is_expected.to validate_presence_of :online_days }
      end
    end
  end
end
