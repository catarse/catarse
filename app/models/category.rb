class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.with_projects
    where("id IN (SELECT DISTINCT category_id FROM projects WHERE state <> 'draft' AND state <> 'rejected')")
  end

  def self.array
    order('name ASC').collect { |c| [c.name, c.id] }
  end

  def to_s
    name
  end
end
