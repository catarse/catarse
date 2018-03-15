# frozen_string_literal: true

class ProjectFiscalData < ActiveRecord::Base
  self.table_name = 'public.project_fiscal_datas'
  belongs_to :project
  belongs_to :user

  def find(id)
    self
  end
end
