# frozen_string_literal: true

module ENotas
  module ParamsBuilders
    class Client
      attr_reader :user

      ATTRIBUTES = %i[nome email cpfCnpj telefone].freeze

      def initialize(project_fiscal)
        @project_fiscal = project_fiscal
        @user = @project_fiscal.user
      end

      def build
        ATTRIBUTES.index_with { |attribute| send(attribute.to_s.underscore.to_sym) }
      end

      def nome
        user.name
      end

      def email
        user.email
      end

      def cpf_cnpj
        user.cpf.to_s.gsub(%r{[-./_\s]}, '')
      end

      def telefone
        user.phone_number
      end
    end
  end
end
