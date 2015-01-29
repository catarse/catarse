class AuditedAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :bank

  validates_uniqueness_of :project
end
