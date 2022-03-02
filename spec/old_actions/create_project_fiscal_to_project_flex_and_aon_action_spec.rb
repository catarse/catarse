# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateProjectFiscalToProjectFlexAndAonAction, type: :action do
  let(:value) { 700 }
  let(:project) { create(:project, state: 'online') }

  describe '#call' do
    subject(:result) { described_class.new(project_id: project.id).call }

    let(:contribution) do
      [
        create(:confirmed_contribution, value: value, project: project),
        create(:confirmed_contribution, value: value, project: project),
        create(:confirmed_contribution, value: value, project: project),
        create(:contribution, value: value, project: project)
      ]
    end
    let!(:payment) do
      [
        contribution[0].payments.last,
        contribution[1].payments.last,
        contribution[2].payments.last,
        create(:payment, state: 'chargeback', contribution: contribution[3], value: value,
          created_at: Time.zone.now - 1.month
        )
      ]
    end

    let!(:antifraud) do
      [
        create(:antifraud_analysis, payment: payment[0], created_at: Time.zone.now - 1.month),
        create(:antifraud_analysis, payment: payment[1], created_at: Time.zone.now - 1.month),
        create(:antifraud_analysis, payment: payment[2], created_at: Time.zone.now - 2.months),
        create(:antifraud_analysis, payment: payment[3], created_at: Time.zone.now - 1.month)
      ]
    end

    before do
      payment[0].update(created_at: Time.zone.now - 1.month)
      payment[1].update(created_at: Time.zone.now - 1.month)
      payment[2].update(created_at: Time.zone.now - 2.months)
      contribution[0].user.update(account_type: 'pf')
      contribution[1].user.update(account_type: 'pj')
      contribution[2].user.update(account_type: 'pf')
      contribution[3].user.update(account_type: 'pj')
    end

    it 'returns project fiscals attributes' do
      expect(result.reload.attributes).to include(
        'user_id' => project.user_id,
        'project_id' => project.id,
        'total_irrf_cents' => (0.015 * (payment[1].value * 100)).to_i,
        'total_amount_to_pj_cents' => payment[1].value.to_i * 100,
        'total_amount_to_pf_cents' => (payment[0].value + payment[2].value).to_i * 100,
        'total_catarse_fee_cents' => (project.service_fee *
          (payment[2].value + payment[1].value + payment[0].value)).to_i * 100,
        'total_gateway_fee_cents' => (payment[2].gateway_fee + payment[1].gateway_fee +
          payment[0].gateway_fee).to_i * 100,
        'total_antifraud_fee_cents' => (antifraud[0].cost + antifraud[1].cost + antifraud[2].cost).to_i * 100,
        'total_chargeback_cost_cents' => (payment[2].gateway_fee + antifraud[2].cost).to_i * 100
      )
    end

    context 'when there are already fiscal projects' do
      before do
        create(:project_fiscal, project: project, created_at: Time.zone.tomorrow - 2.months)
      end

      it 'returns project fiscals attributes' do
        expect(result.reload.attributes).to include(
          'user_id' => project.user_id,
          'project_id' => project.id,
          'total_irrf_cents' => (0.015 * (payment[1].value * 100)).to_i,
          'total_amount_to_pj_cents' => payment[1].value.to_i * 100,
          'total_amount_to_pf_cents' => payment[0].value.to_i * 100,
          'total_catarse_fee_cents' => (project.service_fee * (payment[1].value + payment[0].value)).to_i * 100,
          'total_gateway_fee_cents' => (payment[0].gateway_fee + payment[1].gateway_fee).to_i * 100,
          'total_antifraud_fee_cents' => (antifraud[0].cost + antifraud[1].cost).to_i * 100,
          'total_chargeback_cost_cents' => (payment[2].gateway_fee + antifraud[2].cost).to_i * 100
        )
      end
    end
  end
end
