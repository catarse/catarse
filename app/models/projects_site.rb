class ProjectsSite < ActiveRecord::Base
  belongs_to :project
  belongs_to :site
  validates_presence_of :project, :site
end
