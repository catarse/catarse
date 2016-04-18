class ProjectTransfer < ActiveRecord::Base
  self.table_name = '"1".project_transfers'
  self.primary_key = 'project_id'
end
