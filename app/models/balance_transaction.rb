class BalanceTransaction < ActiveRecord::Base
  belongs_to :project
  belongs_to :contribution
  belongs_to :user

  validates :event_name, uniqueness: { scope: %i(user_id project_id) }
  validates :event_name, uniqueness: { scope: %i(user_id contribution_id) }
  validates :amount, :event_name, :user_id, presence: true
end
