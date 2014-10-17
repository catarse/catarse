require 'rails_helper'

RSpec.describe ProjectTotal, type: :model do
  before do
    @project_id = create(:contribution, value: 10.0, payment_service_fee: 1, state: 'pending').project_id
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'confirmed', project_id: @project_id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'waiting_confirmation', project_id: @project_id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'refunded', project_id: @project_id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'requested_refund', project_id: @project_id)
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
