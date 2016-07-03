require 'rails_helper'

RSpec.describe ProjectTotal, type: :model do
  let(:project) { create(:project, state: 'online') }
  let(:project_total) { project.project_total }

  context "when project is failed" do
    before do
      create_contribution_with_payment(project.id, 'pending')
      create_contribution_with_payment(project.id, 'paid')
      create_contribution_with_payment(project.id, 'refunded')
      create_contribution_with_payment(project.id, 'pending_refund')
      project.update_attribute(:state, 'failed')
    end

    describe "#pledged" do
      subject{ project_total.pledged }
      it{ is_expected.to eq(30) }
    end

    describe "#total_contributions" do
      subject{ project_total.total_contributions }
      it{ is_expected.to eq(3) }
    end

    describe "#total_payment_service_fee" do
      subject { project_total.total_payment_service_fee }
      it { is_expected.to eq(3) }
    end
  end

  context "when project is online" do
    before do
      create_contribution_with_payment(project.id, 'pending')
      create_contribution_with_payment(project.id, 'paid')
      create_contribution_with_payment(project.id, 'refunded')
      create_contribution_with_payment(project.id, 'pending_refund')
    end

    describe "#pledged" do
      subject{ project_total.pledged }
      it{ is_expected.to eq(10) }
    end

    describe "#total_contributions" do
      subject{ project_total.total_contributions }
      it{ is_expected.to eq(1) }
    end

    describe "#total_payment_service_fee" do
      subject { project_total.total_payment_service_fee }
      it { is_expected.to eq(1) }
    end
  end

end
