class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name_pt
  validates_uniqueness_of :name_pt

  def self.with_projects
    where("id IN (SELECT DISTINCT category_id FROM projects WHERE state <> 'draft' AND state <> 'rejected')")
  end

  def self.array
    order('name_'+ I18n.locale.to_s + ' ASC').collect { |c| [c.send('name_' + I18n.locale.to_s), c.id] }
  end

  def to_s
    self.send('name_' + I18n.locale.to_s)
  end
end
