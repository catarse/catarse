# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ENotas::ParamsBuilders::Product, type: :params_builder do
  subject(:params_builder) { described_class.new(project_fiscal) }

  let(:project_fiscal) { create(:project_fiscal) }

  describe 'ATTRIBUTES constant' do
    it 'returns params attributes' do
      expect(described_class::ATTRIBUTES).to eq %i[
        nome idExterno valorTotal tags
      ]
    end
  end

  describe '#build' do
    it 'returns all attributes with corresponding methods results' do
      expect(params_builder.build).to eq(
        nome: params_builder.nome,
        idExterno: params_builder.id_externo,
        valorTotal: params_builder.valor_total,
        tags: params_builder.tags
      )
    end
  end

  describe '#nome' do
    it 'returns project name' do
      expect(params_builder.nome).to eq project_fiscal.project.name
    end
  end

  describe '#idExterno' do
    it 'returns project id' do
      expect(params_builder.id_externo).to eq project_fiscal.project.id.to_s
    end
  end

  describe '#valorTotal' do
    it 'returns project fiscal total debit invoice' do
      expect(params_builder.valor_total).to eq project_fiscal.total_debit_invoice.to_f
    end
  end

  describe '#tags' do
    it 'returns project fiscal tags' do
      expect(params_builder.tags).to eq project_fiscal.project.category.name_pt
    end
  end
end
