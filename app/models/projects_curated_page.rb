class ProjectsCuratedPage < ActiveRecord::Base
  belongs_to :project
  belongs_to :curated_page
end
