require 'rails_helper'

RSpec.describe BalanceTransaction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:contribution) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it{ is_expected.to validate_presence_of(:amount) }
    it{ is_expected.to validate_presence_of(:event_name) }
    it{ is_expected.to validate_presence_of(:user_id) }
    it{ is_expected.to validate_inclusion_of(:event_name).in_array(%w(transfered_project_pledged successful_project_pledged catarse_project_service_fee irrf_tax_project)) }
  end

  describe "#insert_successful_project_transactions" do
    let(:project) { create(:project, goal: 30, state: 'online')}
    let!(:contribution) { create(:confirmed_contribution, value: 20000, project: project) }

    context "when given project is finished" do
      before do
        project.update_attributes(expires_at: 2.minutes.ago)
        expect(BalanceTransaction).to receive(:insert_successful_project_transactions).with(project.id).and_call_original
        project.finish
      end

      it "should create successful_project_pledged transaction" do
        expect(BalanceTransaction.find_by(event_name: 'successful_project_pledged', project_id: project.id, user_id: project.user_id, amount: project.project_transfer.pledged)).not_to be_nil
      end

      it "should create catarse_project_service_fee transaction" do
        expect(BalanceTransaction.find_by(event_name: 'catarse_project_service_fee', project_id: project.id, user_id: project.user_id, amount: project.project_transfer.catarse_fee * -1)).not_to be_nil
      end

    end

    context "when project owner is pj" do
      before do
        contribution.payments.last.update_attributes(gateway_fee: '400')
        project.user.update_attributes(account_type: 'pj', cpf: '38.414.365/0001-35')
        project.update_attributes(expires_at: 2.minutes.ago)
        project.finish
      end

      it "should create irrf_tax_project transaction" do
        expect(BalanceTransaction.find_by(event_name: 'irrf_tax_project', project_id: project.id, user_id: project.user_id, amount: project.project_transfer.irrf_tax)).not_to be_nil
      end
    end

    context "when project is not successful yet" do
      let(:project) { create(:project, state: 'online') }
      subject { BalanceTransaction.insert_successful_project_transactions(project.id) }
      it "should return nothing" do
        is_expected.to eq(nil)
      end
    end
  end
end
