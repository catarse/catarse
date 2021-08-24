# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ENotas::ParamsBuilders::Address, type: :params_builder do
  subject(:params_builder) { described_class.new(project_fiscal) }

  let(:project_fiscal) { ProjectFiscal.new(user: user) }
  let(:user) { create(:user) }

  describe 'ATTRIBUTES constant' do
    it 'returns params attributes' do
      expect(described_class::ATTRIBUTES).to eq %i[
        cidade logradouro numero complemento bairro cep
      ]
    end
  end

  describe '#build' do
    it 'returns all attributes with corresponding methods results' do
      expect(params_builder.build).to eq(
        cidade: params_builder.cidade,
        logradouro: params_builder.logradouro,
        numero: params_builder.numero,
        complemento: params_builder.complemento,
        bairro: params_builder.bairro,
        cep: params_builder.cep
      )
    end
  end

  describe '#cidade' do
    it 'returns address city' do
      expect(params_builder.cidade).to eq user.address_city
    end
  end

  describe '#logradouro' do
    it 'returns address street' do
      expect(params_builder.logradouro).to eq user.address_street
    end
  end

  describe '#numero' do
    it 'returns address number' do
      expect(params_builder.numero).to eq user.address_number
    end
  end

  describe '#complemento' do
    it 'returns address complement' do
      expect(params_builder.complemento).to eq user.address_complement
    end
  end

  describe '#bairro' do
    it 'returns address neighbourhood' do
      expect(params_builder.bairro).to eq user.address_neighbourhood
    end
  end

  describe '#cep' do
    it 'returns address zipcode' do
      expect(params_builder.cep).to eq user.address_zip_code
    end
  end
end
