# coding: utf-8
class ProjectReport < ActiveRecord::Base
  has_notifications
  belongs_to :project
  validates_presence_of :project_id, :email, :reason

end
