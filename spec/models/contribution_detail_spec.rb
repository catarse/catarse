require 'rails_helper'

RSpec.describe ContributionDetail, type: :model do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
    it{ should belong_to :reward }
    it{ should belong_to :contribution }
    it{ should belong_to :payment }
  end

  describe ".between_values" do
    let(:start_at) { 10 }
    let(:ends_at) { 20 }
    subject { ContributionDetail.between_values(start_at, ends_at) }
    before do
      create(:confirmed_contribution, value: 10)
      create(:confirmed_contribution, value: 15)
      create(:confirmed_contribution, value: 20)
      create(:confirmed_contribution, value: 21)
    end
    it { is_expected.to have(3).itens }
  end

  describe '.for_successful_projects' do
    let(:project) { create(:project, goal: 200, state: 'online') }

    subject { ContributionDetail.for_successful_projects }

    before do
      create(:confirmed_contribution, value: 100, project: project)
      create(:confirmed_contribution, value: 100, project: project)
      create(:confirmed_contribution, value: 10)
      create(:contribution, value: 100, project: project)

      project.update_attributes(state: 'successful')
    end

    it { is_expected.to have(2).itens }
  end

  describe '.for_failed_projects' do
    let(:project) { create(:project, goal: 200) }

    subject { ContributionDetail.for_failed_projects }

    before do
      create(:confirmed_contribution, project: project)
      create(:confirmed_contribution, project: project)
      create(:pending_refund_contribution, project: project)
      create(:refunded_contribution, project: project)
      create(:confirmed_contribution)
      create(:contribution, project: project)
      project.update_attributes(state: 'failed')
    end

    it { is_expected.to have(4).itens }
  end

  describe '#last_state_name' do
    let(:contribution) { create(:contribution) }
    let(:refunded_payment) { create(:payment, state: 'refunded', pending_refund_at: 2.days.ago, refunded_at: 1.day.ago, paid_at: 3.days.ago, value: contribution.value, contribution: contribution) }

    before do
      refunded_payment
    end

    subject do
      detail = contribution.details.first
      detail.last_state_name
    end

    it do
      is_expected.to eq('pending_refund')
    end
  end

end
