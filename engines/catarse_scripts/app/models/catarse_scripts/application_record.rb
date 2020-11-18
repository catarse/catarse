module CatarseScripts
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.implicit_order_column = :created_at
  end
end
