# frozen_string_literal: true

class ProjectFiscalData < ApplicationRecord
  self.table_name = 'public.project_fiscal_data_tbl'
  self.implicit_order_column = :fiscal_date

  belongs_to :project
  belongs_to :user

  def find(id)
    self
  end
end
