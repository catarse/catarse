# frozen_string_literal: true

class ProjectFiscalInform < ApplicationRecord
  self.table_name = 'public.project_fiscal_informs_view'
  self.implicit_order_column = :fiscal_date

  belongs_to :project
  belongs_to :user

  def find(id)
    self
  end
end
