class ProjectsCuratedPage < ActiveRecord::Base
  belongs_to :project
  belongs_to :curated_page
  validates_presence_of :project, :curated_page
end

# == Schema Information
#
# Table name: projects_curated_pages
#
#  id              :integer         not null, primary key
#  project_id      :integer
#  curated_page_id :integer
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#

