# frozen_string_literal: true

module ENotas
  module ParamsBuilders
    class Product
      ATTRIBUTES = %i[nome idExterno valorTotal tags].freeze

      def initialize(project_fiscal)
        @project_fiscal = project_fiscal
      end

      def build
        ATTRIBUTES.index_with { |attribute| send(attribute.to_s.underscore.to_sym) }
      end

      def nome
        @project_fiscal.project.name
      end

      def id_externo
        @project_fiscal.project.id.to_s
      end

      def valor_total
        @project_fiscal.total_debit_invoice.to_f
      end

      def tags
        @project_fiscal.project.category.name_pt
      end
    end
  end
end
