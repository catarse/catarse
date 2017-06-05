# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project::BaseValidator, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: project_state, mode: 'flex') }

  context 'when project is going to online to end state' do
    subject { project }

    Project::ON_ONLINE_TO_END_STATES.each do |state|
      context "#{state} project validations" do
        let(:project_state) { state }

        it { is_expected.to validate_presence_of :about_html }
        it { is_expected.to validate_presence_of :headline }
        it { is_expected.to validate_numericality_of(:online_days).is_less_than_or_equal_to(365).is_greater_than_or_equal_to(1).allow_nil }
      end

      context "#{state} project relation validations" do
        let(:project_state) { state }

        context 'when user bank account is not present' do
          before do
            project.user.bank_account = nil

            project.valid?
          end

          it { expect(project.errors['bank_account']).not_to be_nil }
        end

        context 'when user as missing some required fields' do
          before do
            project.user.uploaded_image = nil
            project.user.about_html = nil
            project.user.name = nil

            project.valid?
          end

          %i[uploaded_image about_html name].each do |attr|
            it "should have error user.#{attr}" do
              expect(project.errors['user.' + attr.to_s]).not_to be_nil
            end
          end
        end
      end
    end
  end
end
