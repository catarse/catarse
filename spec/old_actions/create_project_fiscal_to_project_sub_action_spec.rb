# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateProjectFiscalToProjectSubAction, type: :action do
  let(:value) { 700 }

  describe '#call' do
    subject(:result) do
      described_class.new(
        project_id: subscription_project.id,
        month: 6,
        year: 2020
      ).call
    end

    let(:subscription_project) { create(:subscription_project, state: 'online') }
    let(:contribution) do
      [
        create(:confirmed_contribution, value: value, project: subscription_project),
        create(:confirmed_contribution, value: value, project: subscription_project),
        create(:confirmed_contribution, value: value, project: subscription_project,
          created_at: '04/04/2020'.to_date
        ),
        create(:contribution, value: value, project: subscription_project)
      ]
    end
    let!(:payment) do
      [
        contribution[0].payments.last,
        contribution[1].payments.last,
        contribution[2].payments.last,
        create(:payment, state: 'chargeback', contribution: contribution[3],
          value: value, created_at: '04/06/2020'.to_date
        )
      ]
    end
    let!(:antifraud) do
      [
        create(:antifraud_analysis, payment: payment[0], created_at: '28/06/2020'.to_date),
        create(:antifraud_analysis, payment: payment[1], created_at: '11/06/2020'.to_date),
        create(:antifraud_analysis, payment: payment[2], created_at: '04/04/2020'.to_date),
        create(:antifraud_analysis, payment: contribution[3].payments.last, created_at: '06/06/2020'.to_date)
      ]
    end

    before do
      contribution[0].user.update(account_type: 'pj')
      contribution[1].user.update(account_type: 'pf')
      contribution[0].payments.last.update(created_at: '21/06/2020'.to_date)
      contribution[1].payments.last.update(created_at: '07/06/2020'.to_date)
      contribution[2].payments.last.update(created_at: '04/04/2020'.to_date)
    end

    it 'returns project fiscals attributes' do
      expect(result.attributes).to include(
        'user_id' => subscription_project.user_id,
        'project_id' => subscription_project.id,
        'total_irrf_cents' => (0.015 * (payment[1].value * 100)).to_i,
        'total_amount_to_pj_cents' => payment[0].value.to_i * 100,
        'total_amount_to_pf_cents' => payment[1].value.to_i * 100,
        'total_catarse_fee_cents' => (subscription_project.service_fee * (payment[0].value +
          payment[1].value)).to_i * 100,
        'total_gateway_fee_cents' => (payment[0].gateway_fee + payment[1].gateway_fee).to_i * 100,
        'total_antifraud_fee_cents' => (antifraud[0].cost + antifraud[1].cost).to_i * 100,
        'total_chargeback_cost_cents' => (payment[2].gateway_fee + antifraud[2].cost).to_i * 100
      )
    end

    context 'when project_fiscal generate invoice' do
      before do
        CatarseSettings[:enotes_initial_cut_off_date] = '01-01-2020'
        allow_any_instance_of(ENotas::Client).to receive(:create_nfe).and_return({ 'id' => '1' }) # rubocop:disable RSpec/AnyInstance
      end

      it 'capture invoice generation' do
        expect(ENotas::Client.new.create_nfe('invoice')).to eq({ 'id' => '1' })

        result
      end

      it 'updates metadata' do
        expect(result.metadata).to eq({ 'id' => '1' })
      end
    end
  end
end
