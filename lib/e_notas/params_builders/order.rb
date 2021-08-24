# frozen_string_literal: true

module ENotas
  module ParamsBuilders
    class Order
      attr_reader :project_fiscal, :project

      ATTRIBUTES = %i[
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
      ].freeze

      def initialize(project_fiscal)
        @project_fiscal = project_fiscal
        @project = @project_fiscal.project
      end

      def build
        ATTRIBUTES.index_with { |attribute| send(attribute.to_s.underscore.to_sym) }
      end

      def cliente
        ENotas::ParamsBuilders::Client.new(project_fiscal).build
      end

      def endereco
        ENotas::ParamsBuilders::Address.new(project_fiscal).build
      end

      def data
        I18n.l(Time.zone.today)
      end

      def vencimento
        I18n.l(Time.zone.today)
      end

      def produto
        ENotas::ParamsBuilders::Product.new(project_fiscal).build
      end

      def valor_total
        project_fiscal.total_debit_invoice.to_f
      end

      def enviar_n_fe_cliente
        true
      end

      def meio_pagamento
        # TransferenciaBancaria
        3
      end

      def data_competencia
        I18n.l(Time.zone.today)
      end

      def discriminacao
        %{
          Servico de intermediacao de negocios - plataforma Catarse -
          prestado ao projeto #{project.name} (id: #{project.id}).
        }.squish
      end

      def valor_total_n_fe
        project_fiscal.total_debit_invoice.to_f
      end

      def iss_retido_fonte
        false
      end

      def quando_emitir_n_fe
        # AposAGarantia
        1
      end
    end
  end
end
