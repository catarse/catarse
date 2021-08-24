# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ENotas::ParamsBuilders::Client, type: :params_builder do
  subject(:params_builder) { described_class.new(project_fiscal) }

  let(:project_fiscal) { ProjectFiscal.new(user: user) }
  let(:user) { create(:user) }

  describe 'ATTRIBUTES constant' do
    it 'returns params attributes' do
      expect(described_class::ATTRIBUTES).to eq %i[
        nome email cpfCnpj telefone
      ]
    end
  end

  describe '#build' do
    it 'returns all attributes with corresponding methods results' do
      expect(params_builder.build).to eq(
        nome: params_builder.nome,
        email: params_builder.email,
        cpfCnpj: params_builder.cpf_cnpj,
        telefone: params_builder.telefone
      )
    end
  end

  describe '#nome' do
    it 'returns user name' do
      expect(params_builder.nome).to eq user.name
    end
  end

  describe '#email' do
    it 'returns user email' do
      expect(params_builder.email).to eq user.email
    end
  end

  describe '#cpf_cnpj' do
    it 'returns user cpf or cnpj' do
      expect(params_builder.cpf_cnpj).to eq user.cpf.to_s.gsub(%r{[-./_\s]}, '')
    end
  end

  describe '#telefone' do
    it 'returns user phone number' do
      expect(params_builder.telefone).to eq user.phone_number
    end
  end
end
