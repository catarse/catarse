# frozen_string_literal: true

class ProjectTotal < ApplicationRecord
  self.table_name = '"1".project_totals'
  self.primary_key = :project_id
end
