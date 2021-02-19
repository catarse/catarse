# frozen_string_literal: true

require 'ransack'

Ransack::Adapters::ActiveRecord::Base.class_eval('remove_method :search') # rubocop:disable Style/EvalWithLocation

module Arel
  module Nodes
    class ContainsArray < Arel::Nodes::Binary
      def operator
        :"@>"
      end
    end
  end

  module Visitors
    class PostgreSQL
      private

      def visit_Arel_Nodes_ContainsArray(other, collector) # rubocop:disable Naming/MethodName
        infix_value other, collector, ' @> '
      end
    end
  end

  module Predications
    def contains(other)
      Nodes::ContainsArray.new self, Nodes.build_quoted(other.tr('[]', '{}'), self)
    end
  end
end

Ransack.configure do |config|
  config.add_predicate :contains_array, arel_predicate: :contains
end
