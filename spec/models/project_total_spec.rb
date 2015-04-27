require 'rails_helper'

RSpec.describe ProjectTotal, type: :model do
  before do
    @project_id = create(:project, state: 'online').id
    create_contribution_with_payment(@project_id, 'pending')
    create_contribution_with_payment(@project_id, 'paid')
    create_contribution_with_payment(@project_id, 'refunded')
    create_contribution_with_payment(@project_id, 'pending_refund')
  end

  describe "#pledged" do
    subject{ ProjectTotal.where(project_id: @project_id).first.pledged }
    it{ is_expected.to eq(30) }
  end

  describe "#total_contributions" do
    subject{ ProjectTotal.where(project_id: @project_id).first.total_contributions }
    it{ is_expected.to eq(3) }
  end

  describe "#total_payment_service_fee" do
    subject { ProjectTotal.where(project_id: @project_id).first.total_payment_service_fee }
    it { is_expected.to eq(3) }
  end
end
