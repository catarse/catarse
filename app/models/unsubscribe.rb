class Unsubscribe < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification_type
  belongs_to :project
end
