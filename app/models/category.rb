class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name
  validates_uniqueness_of :name
  def self.with_projects(site)
    where("id IN (SELECT DISTINCT category_id FROM projects INNER JOIN projects_sites ON projects_sites.project_id = projects.id WHERE projects_sites.site_id = #{site.id} AND projects_sites.visible = true)")
  end
end


# == Schema Information
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  name       :text            not null
#  created_at :datetime
#  updated_at :datetime
#

