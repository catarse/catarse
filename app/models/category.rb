class Category < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  scope :with_projects, where("id IN (SELECT DISTINCT(category_id) FROM projects WHERE visible)")
end

