class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.with_projects
    where("id IN (SELECT DISTINCT category_id FROM projects WHERE state <> 'draft' AND state <> 'rejected')")
  end

  def self.array
    if I18n.locale == :pt
      order('name ASC').collect { |c| [c.name, c.id] }
    elsif I18n.locale == :en
      order('name_en ASC').collect { |c| [c.name_en, c.id] }
    end
  end

  def to_s
    I18n.locale == :pt ? name : name_en
  end
end
