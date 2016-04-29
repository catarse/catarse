class UserTotal < ActiveRecord::Base
  include Shared::MaterializedView
  self.primary_key = :id
  self.table_name = '"1".user_totals'
end
