class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name
  validates_uniqueness_of :name
  def self.with_projects
    where("id IN (SELECT DISTINCT category_id FROM projects WHERE visible)")
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

