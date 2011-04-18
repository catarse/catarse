class Site < ActiveRecord::Base
  validates_presence_of :name, :title, :path, :host
  validates_uniqueness_of :name, :path, :host
  has_many :projects
  has_many :projects_sites
  has_many :present_projects, :through => :projects_sites, :source => :project
  has_many :backers
  has_many :users
  def the(capitalize = false)
    if gender == "male"
      "#{capitalize ? 'O' : 'o'}"
    elsif gender == "female"
      "#{capitalize ? 'A' : 'a'}"
    end
  end
  def the_name(capitalize = false)
    "#{the(capitalize)} #{name}"
  end
  def in_the
    if gender == "male"
      "no"
    elsif gender == "female"
      "na"
    end
  end
  def in_the_name
    "#{in_the} #{name}"
  end
  def in_the_twitter
    "#{in_the} @#{twitter}"
  end
  def to_the
    if gender == "male"
      "ao"
    elsif gender == "female"
      "à"
    end
  end
  def to_the_name
    "#{to_the} #{name}"
  end
end
