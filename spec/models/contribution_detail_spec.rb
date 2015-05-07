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

  describe ".was_confirmed" do
    subject{ ContributionDetail.was_confirmed }

    before do
      @contribution = create(:confirmed_contribution)
      @refunded_contribution = create(:refunded_contribution)
      create(:pending_contribution)
    end
    it{ is_expected.to match_array [@contribution.details.first, @refunded_contribution.details.first] }
  end

  describe ".pending" do
    subject{ ContributionDetail.pending }

    before do
      @contribution = create(:pending_contribution)
      create(:confirmed_contribution)
    end
    it{ is_expected.to match_array [@contribution.details.first] }
  end

  describe ".with_state" do
    subject{ ContributionDetail.with_state(:paid) }

    before do
      @contribution = create(:confirmed_contribution)
      create(:pending_contribution)
    end

    it{ is_expected.to match_array [@contribution.details.first] }
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

  describe ".total_confirmed_amount_by_day" do
    subject { ContributionDetail.total_confirmed_by_day }
    before do
      @contribution_01 = create(:confirmed_contribution)
      @contribution_01.payments.update_all(paid_at: 2.day.ago.to_date)
      @payment_01 = @contribution_01.payments.first

      @contribution_02 = create(:confirmed_contribution)
      @contribution_02.payments.update_all(paid_at: Date.today)
      @payment_02 = @contribution_02.payments.first

      create(:pending_contribution)
    end

    it { is_expected.to eq({
      @payment_01.paid_at.strftime("%Y-%m-%d %H:%M:%S UTC").to_time => 1,
      @payment_02.paid_at.strftime("%Y-%m-%d %H:%M:%S UTC").to_time => 1,
    })}
  end

  describe ".total_confirmed_amount_by_day" do
    subject { ContributionDetail.total_confirmed_amount_by_day }
    before do
      @contribution_01 = create(:confirmed_contribution, value: 10)
      @contribution_01.payments.update_all(paid_at: 2.day.ago.to_date)
      @payment_01 = @contribution_01.payments.first

      @contribution_02 = create(:confirmed_contribution, value: 30)
      @contribution_02.payments.update_all(paid_at: Date.today)
      @payment_02 = @contribution_02.payments.first

      create(:pending_contribution)
    end

    it { is_expected.to eq({
      @payment_01.paid_at.strftime("%Y-%m-%d %H:%M:%S UTC").to_time => 10,
      @payment_02.paid_at.strftime("%Y-%m-%d %H:%M:%S UTC").to_time => 30,
    })}
  end

  describe ".total_by_address_state" do
    subject { ContributionDetail.total_by_address_state }
    before do
      @user_01 = create(:user, address_state: 'MG')
      @contribution_01 = create(:confirmed_contribution, user: @user_01)
      @contribution_01.payments.update_all(paid_at: 2.day.ago.to_date)
      @payment_01 = @contribution_01.payments.first

      @user_02 = create(:user, address_state: 'RJ')
      @contribution_02 = create(:confirmed_contribution, user: @user_02)
      @contribution_02.payments.update_all(paid_at: Date.today)
      @payment_02 = @contribution_02.payments.first

      create(:pending_contribution)
    end

    it { is_expected.to eq({
      @contribution_01.user.address_state => 1,
      @contribution_02.user.address_state => 1,
    })}
  end
end
