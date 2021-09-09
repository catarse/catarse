# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ENotas::ParamsBuilders::Order, type: :params_builder do
  subject(:params_builder) { described_class.new(project_fiscal) }

  let(:project_fiscal) { create(:project_fiscal) }
  let(:project) { project_fiscal.project }

  describe 'ATTRIBUTES constant' do
    it 'returns params attributes' do
      expect(described_class::ATTRIBUTES).to eq %i[
        cliente
        endereco
        data
        vencimento
        produto
        valorTotal
        enviarNFeCliente
        meioPagamento
        dataCompetencia
        discriminacao
        valorTotalNFe
        issRetidoFonte
        quandoEmitirNFe
      ]
    end
  end

  describe '#build' do
    it 'returns all attributes with corresponding methods results' do
      expect(params_builder.build).to eq(
        cliente: params_builder.cliente,
        endereco: params_builder.endereco,
        data: params_builder.data,
        vencimento: params_builder.vencimento,
        produto: params_builder.produto,
        valorTotal: params_builder.valor_total,
        enviarNFeCliente: params_builder.enviar_n_fe_cliente,
        meioPagamento: params_builder.meio_pagamento,
        dataCompetencia: params_builder.data_competencia,
        discriminacao: params_builder.discriminacao,
        valorTotalNFe: params_builder.valor_total_n_fe,
        issRetidoFonte: params_builder.iss_retido_fonte,
        quandoEmitirNFe: params_builder.quando_emitir_n_fe
      )
    end
  end

  describe '#cliente' do
    it 'returns client' do
      expect(params_builder.cliente).to eq ENotas::ParamsBuilders::Client.new(project_fiscal).build
    end
  end

  describe '#endereco' do
    it 'returns address' do
      expect(params_builder.endereco).to eq ENotas::ParamsBuilders::Address.new(project_fiscal).build
    end
  end

  describe '#data' do
    it 'returns date invoice' do
      expect(params_builder.data).to eq I18n.l(Time.zone.today)
    end
  end

  describe '#vencimento' do
    it 'returns due date invoice' do
      expect(params_builder.vencimento).to eq I18n.l(Time.zone.today)
    end
  end

  describe '#produto' do
    it 'returns product' do
      expect(params_builder.produto).to eq ENotas::ParamsBuilders::Product.new(project_fiscal).build
    end
  end

  describe '#valor_total' do
    it 'returns project fiscal total debit invoice' do
      expect(params_builder.valor_total).to eq project_fiscal.total_debit_invoice.to_f
    end
  end

  describe '#enviar_n_fe_cliente' do
    it 'returns true' do
      expect(params_builder.enviar_n_fe_cliente).to eq true
    end
  end

  describe '#meio_pagamento' do
    it 'returns payment method' do
      expect(params_builder.meio_pagamento).to eq 3
    end
  end

  describe '#data_competencia' do
    it 'returns competence date' do
      expect(params_builder.data_competencia).to eq I18n.l(Time.zone.today)
    end
  end

  describe '#discriminacao' do
    it 'returns discrimination' do
      description = %{
        Servico de intermediacao de negocios - plataforma Catarse -
        prestado ao projeto #{project.name} (id: #{project.id}).
      }.squish
      expect(params_builder.discriminacao).to eq description
    end
  end

  describe '#valor_total_n_fe' do
    it 'returns project fiscal total debit invoice' do
      expect(params_builder.valor_total_n_fe).to eq project_fiscal.total_debit_invoice.to_f
    end
  end

  describe '#iss_retido_fonte' do
    it 'returns false' do
      expect(params_builder.iss_retido_fonte).to eq false
    end
  end

  describe '#quando_emitir_n_fe' do
    it 'returns 1' do
      expect(params_builder.quando_emitir_n_fe).to eq 1
    end
  end
end
