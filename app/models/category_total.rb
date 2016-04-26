class CategoryTotal < ActiveRecord::Base
  include Shared::MaterializedView
  self.table_name = '"1".category_totals'
end
