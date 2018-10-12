# frozen_string_literal: true

class ProjectFiscalData < ActiveRecord::Base
  self.table_name = 'public.project_fiscal_data_tbl'
  belongs_to :project
  belongs_to :user

  def find(id)
    self
  end
end

#dont know why self.table_name didn't work
ProjectFiscalData.table_name = 'public.project_fiscal_data_tbl'