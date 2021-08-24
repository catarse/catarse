# frozen_string_literal: true

module ENotas
  module ParamsBuilders
    class Address
      attr_reader :user

      ATTRIBUTES = %i[cidade logradouro numero complemento bairro cep].freeze

      def initialize(project_fiscal)
        @user = project_fiscal.user
      end

      def build
        ATTRIBUTES.index_with { |attribute| send(attribute.to_s.underscore.to_sym) }
      end

      def cidade
        user.address_city
      end

      def logradouro
        user.address_street
      end

      def numero
        user.address_number
      end

      def complemento
        user.address_complement
      end

      def bairro
        user.address_neighbourhood
      end

      def cep
        user.address_zip_code
      end
    end
  end
end
