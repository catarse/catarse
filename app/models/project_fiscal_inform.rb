# frozen_string_literal: true

class ProjectFiscalInform < ActiveRecord::Base
  self.table_name = 'public.project_fiscal_informs_view'
  belongs_to :project
  belongs_to :user

  def find(id)
    self
  end
end

#dont know why self.table_name didn't work
ProjectFiscalInform.table_name = 'public.project_fiscal_informs_view'