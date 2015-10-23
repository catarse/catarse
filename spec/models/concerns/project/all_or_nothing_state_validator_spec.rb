require 'rails_helper'

RSpec.describe Project::AllOrNothingStateValidator, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: project_state) }
  let!(:project_account) { create(:project_account, project: project) }

  context "when project is going to in_analysis to end state" do
    subject { project }

    context "in analysis validation" do
      let(:project_state) { 'in_analysis' }

      it { is_expected.to validate_presence_of :city }
      it { is_expected.to validate_length_of(:name).is_at_most(Project::NAME_MAXLENGTH) }
    end

    Project::ON_ANALYSIS_TO_END_STATES.each do |state| 
      context "#{state} project validations" do
        let(:project_state) { state }

        it { is_expected.to validate_presence_of :about_html }
        it { is_expected.to validate_presence_of :headline }
        it { is_expected.to validate_presence_of :goal }
        it { is_expected.to validate_presence_of :online_days }
        it { is_expected.to validate_presence_of :budget }
      end

      context "#{state} project relation validations" do
        let(:project_state) { state }

        context "when project account is present and missing some fields" do
          before do
            project.account.agency = 123

            project.valid?
          end

          it { expect(project.errors['account.agency_size']).not_to be_nil }
        end

        context "when user as missing some required fields" do
          before do
            project.user.uploaded_image = nil
            project.user.about_html = nil
            project.user.name = nil

            project.valid?
          end

          [:uploaded_image, :about_html, :name].each do |attr|
            it "should have error user.#{attr.to_s}" do
              expect(project.errors['user.' + attr.to_s]).not_to be_nil
            end
          end
        end
      end
    end
  end

  context "when project is going to online to end state" do
    subject { project }

    Project::ON_ONLINE_TO_END_STATES.each do |state| 
      context "#{state} project relation validations" do
        let(:project_state) { state }

        context "when account as missing some required fields" do
          before do
            project.account.email = nil
            project.account.address_state = nil
            project.account.address_street = nil
            project.account.address_number = nil
            project.account.address_city = nil
            project.account.address_zip_code= nil
            project.account.phone_number = nil
            project.account.bank = nil
            project.account.agency = nil
            project.account.account = nil
            project.account.account_digit = nil
            project.account.owner_name = nil
            project.account.owner_document = nil

            project.valid?
          end

          [
            :email, :address_street, :address_number, :address_city,
            :address_state, :address_zip_code, :phone_number, :bank,
            :agency, :account, :account_digit, :owner_name, :owner_document
          ].each do |attr|
            it "should have error project_account.#{attr.to_s}" do
              expect(project.errors['project_account.' + attr.to_s]).not_to be_nil
            end
          end
        end
      end
    end
  end
end
