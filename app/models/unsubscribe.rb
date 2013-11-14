class Unsubscribe < ActiveRecord::Base
  schema_associations

  attr_accessor :subscribed

  def self.updates_unsubscribe project_id
    find_or_initialize_by(project_id: project_id)
  end
end
