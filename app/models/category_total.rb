# frozen_string_literal: true

class CategoryTotal < ApplicationRecord
  include Shared::MaterializedView

  self.table_name = '"1".category_totals'
  self.primary_key = :category_id
end
