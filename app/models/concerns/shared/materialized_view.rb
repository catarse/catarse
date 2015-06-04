module Shared
  module MaterializedView
    extend ActiveSupport::Concern

    included do
      def self.refresh_view
        connection.execute("REFRESH MATERIALIZED VIEW #{self.table_name}")
      end
    end
  end
end
