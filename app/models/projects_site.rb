class ProjectsSite < ActiveRecord::Base
  belongs_to :project
  belongs_to :site
  validates_presence_of :project, :site
end

# == Schema Information
#
# Table name: projects_sites
#
#  id          :integer         not null, primary key
#  project_id  :integer         not null
#  site_id     :integer         not null
#  visible     :boolean         default(FALSE), not null
#  rejected    :boolean         default(FALSE), not null
#  recommended :boolean         default(FALSE), not null
#  home_page   :boolean         default(FALSE), not null
#  order       :integer
#  created_at  :datetime
#  updated_at  :datetime
#

