require 'ransack'

Ransack::Adapters::ActiveRecord::Base.class_eval('remove_method :search')

module Arel
  class Nodes::ContainsArray < Arel::Nodes::Binary
    def operator
      :"@>"
    end
  end

  class Visitors::PostgreSQL
    private

    def visit_Arel_Nodes_ContainsArray(o, collector)
      infix_value o, collector, ' @> '
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
