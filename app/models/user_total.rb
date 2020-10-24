# frozen_string_literal: true

class UserTotal < ApplicationRecord
  include Shared::MaterializedView
  self.table_name = '"1".user_totals'
  self.primary_key = :id
end
