class ProjectsCuratedPage < ActiveRecord::Base
  belongs_to :project
  belongs_to :curated_page
  validates_presence_of :project, :curated_page
end
