class Unsubscribe < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_accessor :subscribed

  scope :by_project_id, ->(project_id) { where(project_id: project_id) }

  def self.posts_unsubscribe project_id
    find_or_initialize_by(project_id: project_id)
  end

  def self.drop_all_for_project(project_id)
    by_project_id(project_id).destroy_all
  end

end
