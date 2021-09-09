# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ENotas::Client, type: :client do
  subject(:client) { described_class.new }

  let(:api_key) { Faker::Lorem.word }

  before { allow(CatarseSettings).to receive(:get_without_cache).with(:enotas_test_api_key).and_return(api_key) }

  describe 'Configuration' do
    it 'sets e-notas base api' do
      expect(described_class.base_uri).to eq 'https://app.enotas.com.br/api'
    end
  end

  describe '#create_nfe' do
    let(:nfe_params) { { key: 'value' } }
    let(:request_response) { Hash[*Faker::Lorem.words(number: 4)] }
    let(:headers) do
      {
        Authorization: "Basic #{CatarseSettings.get_without_cache(:enotas_test_api_key)}",
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end

    context 'when request is successfull' do
      before do
        stub_request(:post, "#{described_class.base_uri}/vendas")
          .with(body: nfe_params.to_json, headers: headers)
          .to_return(body: request_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'doesn`t capture message via Sentry' do
        expect(Sentry).not_to receive(:capture_message)

        client.create_nfe(nfe_params)
      end

      it 'makes a post request to vendas and returns parsed body' do
        response = client.create_nfe(nfe_params)

        expect(response).to include request_response
      end
    end

    context 'when request fails' do
      let(:error_message) { 'Error in creating invoice' }

      before do
        stub_request(:post, "#{described_class.base_uri}/vendas")
          .with(body: nfe_params.to_json, headers: headers)
          .to_return(status: 500, body: request_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'captures error message via Sentry' do
        options = { level: :fatal, extra: { data: JSON.parse(request_response.to_json) } }
        expect(Sentry).to receive(:capture_message).with(error_message, options)

        client.create_nfe(nfe_params)
      end
    end
  end
end
