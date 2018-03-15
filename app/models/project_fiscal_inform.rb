# frozen_string_literal: true

class ProjectFiscalInform < ActiveRecord::Base
  self.table_name = 'public.project_fiscal_informs'
  belongs_to :project
  belongs_to :user

  def find(id)
    self
  end
end
