# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TransfeeraController, type: :controller do
  let(:webhook_signature) { 'webhook_signature' }
  let(:timestamp) { Time.now.to_i }

  let(:successful_project) { create(:project, state: 'successful') }

  let(:processing_balance_transfer) do
    create(:balance_transfer, transition_state: 'processing', project_id: successful_project.id)
  end

  let(:transfer_update) do
    {
      data: {
        status: 'TRANSFERIDO',
        integration_id: processing_balance_transfer.id.to_s
      }
    }
  end

  def generate_signature(body)
    body_json = JSON.generate(body)
    to_hash = "#{timestamp}.#{body_json}"
    compute_hmac_sha256_hex(webhook_signature, to_hash)
  end

  before do
    webhook_valid_data = { signature_secret: webhook_signature }
    CatarseSettings[:transfeera_webhook_data] = JSON.generate(webhook_valid_data)
  end

  describe 'POST on webhook' do
    context 'when test signature' do
      it 'calculates the right signature' do
        body_signature = generate_signature(transfer_update)
        request.headers['Transfeera-Signature'] = "t=#{timestamp},v1=#{body_signature}"
        post :webhook, as: :json, params: transfer_update
        expect(response.code.to_i).to eq(200)
      end

      it 'calculates the wrong signature' do
        request.headers['Transfeera-Signature'] = "t=#{timestamp},v1=SOME_WRONG_VALUE"
        post :webhook, as: :json, params: transfer_update
        expect(response.code.to_i).to eq(406)
      end
    end

    context 'when updating the balance transfer' do
      it 'keeps processing with "TRANSFERIDO"' do
        transfer_update = { data: { status: 'TRANSFERIDO', integration_id: processing_balance_transfer.id } }
        body_signature = generate_signature(transfer_update)
        request.headers['Transfeera-Signature'] = "t=#{timestamp},v1=#{body_signature}"
        post :webhook, as: :json, params: transfer_update

        expect(processing_balance_transfer.state).to eq('processing')
      end

      it 'updates to success "FINALIZADO"' do
        transfer_update_final = { data: { status: 'FINALIZADO', integration_id: processing_balance_transfer.id } }
        body_signature = generate_signature(transfer_update_final)
        request.headers['Transfeera-Signature'] = "t=#{timestamp},v1=#{body_signature}"
        post :webhook, as: :json, params: transfer_update_final

        expect(processing_balance_transfer.state).to eq('transferred')
      end

      it 'updates to failed "DEVOLVIDO"' do
        transfer_update_final = { data: { status: 'DEVOLVIDO', integration_id: processing_balance_transfer.id } }
        body_signature = generate_signature(transfer_update_final)
        request.headers['Transfeera-Signature'] = "t=#{timestamp},v1=#{body_signature}"
        post :webhook, as: :json, params: transfer_update_final

        expect(processing_balance_transfer.state).to eq('error')
      end
    end
  end
end
